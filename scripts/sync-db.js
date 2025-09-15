/*
  This file is mostly generated. Its sole purpose is to sync the production database on boot,
  so that a copy can be worked with locally. There is no need to understand or modify the code within,
  as it is AI slop.
  Original Author: Martin Kleiven & 🤖.
*/

import PocketBase from "pocketbase";
import fs from "fs";
import path from "path";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const main = async () => {
  const args = parseArgs();
  validateArgs(args);

  const pb = new PocketBase(args.host);
  const pbDataDir = ensurePbDataDir();

  try {
    await ensureSafeToWrite(pbDataDir, args);
    if (args.email && args.password) {
      await authenticateAdmin(pb, args.email, args.password);
    } else {
      const used = await fallbackFromGithubRelease(pbDataDir, args);
      if (used) {
        console.log("✅ Fallback from GitHub release succeeded.");
        process.exit(0);
      }
      console.error("❌ Fallback from GitHub release did not find a usable artifact.");
      process.exit(1);
    }

    const currentLocalVersion = readCurrentLocalBackupVersion(pbDataDir);
    const latestRemoteBackup = await getLatestBackup(pb);

    if (currentLocalVersion && latestRemoteBackup.key === currentLocalVersion) {
      console.log(
        `✅ Local backup (${currentLocalVersion}) is already up-to-date with the latest remote backup (${latestRemoteBackup.key}). No sync needed.`
      );
      process.exit(0);
    }

    if (currentLocalVersion) {
      console.log(
        `ℹ️ Current local backup: ${currentLocalVersion}. New remote backup available: ${latestRemoteBackup.key}.`
      );
    } else {
      console.log(
        `ℹ️ No local backup version found. Proceeding with download of latest remote backup: ${latestRemoteBackup.key}.`
      );
    }

    await downloadAndExtractBackup(pb, latestRemoteBackup, pbDataDir);
    await writeCurrentLocalBackupVersion(pbDataDir, latestRemoteBackup.key);

    console.log(
      `✅ Backup ${latestRemoteBackup.key} downloaded and extracted successfully. Local version updated.`
    );
  } catch (error) {
    console.error("❌ Error:", error.message, error);
    try {
      const used = await fallbackFromGithubRelease(pbDataDir, args);
      if (used) {
        console.log("✅ Fallback from GitHub release succeeded.");
        process.exit(0);
      }
      console.error("❌ Fallback from GitHub release did not find a usable artifact.");
      process.exit(1);
    } catch (fallbackError) {
      console.error("❌ Fallback failed:", fallbackError.message, fallbackError);
      process.exit(1);
    }
  }
};

const parseArgs = () => {
  const args = {};
  const argv = process.argv.slice(2);

  argv.forEach((arg) => {
    if (arg.startsWith("--")) {
      const [key, value] = arg.split("=");
      const cleanKey = key.substring(2);
      args[cleanKey] = value;
    }
  });

  return args;
};

const validateArgs = (args) => {
  if (!args.host) {
    console.error("Missing required arguments:");
    console.error(
      "Usage: node sync-db.js --host=<pb_host> [--email=<admin_email> --password=<admin_password>]"
    );
    process.exit(1);
  }
};

const authenticateAdmin = async (pb, email, password) => {
  console.log("Authenticating as superuser...");
  await pb.admins.authWithPassword(email, password);
};

const getLatestBackup = async (pb) => {
  console.log("Fetching backup list...");
  const backups = await pb.backups.getFullList();

  if (backups.length === 0) {
    console.log("No backups found");
    process.exit(1);
  }

  const latestBackup = backups.reduce((latest, current) => {
    return new Date(current.modified) > new Date(latest.modified) ? current : latest;
  });

  logBackupInfo(latestBackup);
  return latestBackup;
};

const logBackupInfo = (backup) => {
  console.log(`📦 Latest backup: ${backup.key}`);
  console.log(`📅 Modified: ${backup.modified}`);
  console.log(`📏 Size: ${(backup.size / (1024 * 1024)).toFixed(2)} MB`);
};

const downloadAndExtractBackup = async (pb, backup, pbDataDir) => {
  const token = await getFileToken(pb);
  const downloadUrl = pb.backups.getDownloadURL(token, backup.key);
  const outputPath = await downloadBackupFile(downloadUrl, backup.key, pbDataDir);
  const tempExtractDir = path.join(pbDataDir, `tmp_extract_${Date.now()}`);
  fs.rmSync(tempExtractDir, { recursive: true, force: true });
  fs.mkdirSync(tempExtractDir, { recursive: true });
  if (backup.key.endsWith(".zip")) {
    await extractBackupToDir(outputPath, tempExtractDir);
    await copyExtractedToPbData(tempExtractDir, pbDataDir);
    fs.rmSync(tempExtractDir, { recursive: true, force: true });
  }
};

const fetchGithubRelease = async (repo, tag) => {
  const url =
    tag && tag !== "latest"
      ? `https://api.github.com/repos/${repo}/releases/tags/${encodeURIComponent(tag)}`
      : `https://api.github.com/repos/${repo}/releases/latest`;
  const res = await fetch(url, {
    headers: {
      Accept: "application/vnd.github+json",
      "User-Agent": "kaffediem-sync-db"
    }
  });
  if (!res.ok) {
    throw new Error(`GitHub API ${res.status}: ${res.statusText}`);
  }
  return await res.json();
};

const fallbackFromGithubRelease = async (pbDataDir, args) => {
  const repo = args.githubRepo || "Kaffe-diem/kaffediem";
  const tag = args.githubReleaseTag || "latest";
  console.log(`Attempting fallback from GitHub release ${repo} @ ${tag}`);
  const release = await fetchGithubRelease(repo, tag);
  const assets = Array.isArray(release.assets) ? release.assets : [];
  const zipAsset = assets.find(
    (a) =>
      typeof a === "object" &&
      a &&
      typeof a.name === "string" &&
      a.name.endsWith(".zip") &&
      a.browser_download_url
  );
  if (!zipAsset) {
    return false;
  }
  const outputPath = await downloadBackupFile(
    zipAsset.browser_download_url,
    zipAsset.name,
    pbDataDir
  );
  const tempExtractDir = path.join(pbDataDir, `tmp_extract_${Date.now()}`);
  fs.rmSync(tempExtractDir, { recursive: true, force: true });
  fs.mkdirSync(tempExtractDir, { recursive: true });
  await extractBackupToDir(outputPath, tempExtractDir);
  await copyExtractedToPbData(tempExtractDir, pbDataDir);
  fs.rmSync(tempExtractDir, { recursive: true, force: true });
  const versionLabel = `release:${release.tag_name || tag}:${zipAsset.name}`;
  await writeCurrentLocalBackupVersion(pbDataDir, versionLabel);
  return true;
};

const getFileToken = async (pb) => {
  console.log("Getting file token...");
  return await pb.files.getToken();
};

const downloadBackupFile = async (downloadUrl, backupKey, pbDataDir) => {
  console.log(`🔗 Download URL: ${downloadUrl}`);

  const outputPath = path.join(pbDataDir, backupKey);

  await downloadFile(downloadUrl, outputPath);
  console.log(`📁 Saved to: ${outputPath}`);

  return outputPath;
};

const ensurePbDataDir = () => {
  const pbDataDir = path.resolve("./pb_data");
  if (!fs.existsSync(pbDataDir)) {
    fs.mkdirSync(pbDataDir, { recursive: true });
  }
  return pbDataDir;
};

const readCurrentLocalBackupVersion = (pbDataDir) => {
  const versionFilePath = path.join(pbDataDir, "current_backup_version.txt");
  if (fs.existsSync(versionFilePath)) {
    try {
      return fs.readFileSync(versionFilePath, "utf-8").trim();
    } catch (error) {
      console.warn(`⚠️ Could not read local backup version file: ${error.message}`);
      return null;
    }
  }
  return null;
};

const writeCurrentLocalBackupVersion = async (pbDataDir, backupKey) => {
  const versionFilePath = path.join(pbDataDir, "current_backup_version.txt");
  try {
    fs.writeFileSync(versionFilePath, backupKey);
    console.log(`📝 Updated local backup version file to: ${backupKey}`);
  } catch (error) {
    console.error(`❌ Failed to write local backup version file: ${error.message}`);
  }
};

const extractBackupToDir = async (zipPath, targetDir) => {
  console.log("📦 Extracting backup...");
  await execAsync(`unzip -o "${zipPath}" -d "${targetDir}"`);
  console.log(`📂 Extracted to: ${targetDir}`);
};

const copyExtractedToPbData = async (srcDir, dstDir) => {
  const resolveEntries = (dir) => fs.readdirSync(dir, { withFileTypes: true });
  const shouldSkip = (p) => {
    const base = path.basename(p);
    if (base === "auxiliary.db") return true;
    if (base === "auxiliary.db-wal") return true;
    if (base === "auxiliary.db-shm") return true;
    return false;
  };
  const copyRecursive = (from, to) => {
    if (shouldSkip(from)) return;
    const stat = fs.statSync(from);
    if (stat.isDirectory()) {
      if (!fs.existsSync(to)) fs.mkdirSync(to, { recursive: true });
      for (const entry of resolveEntries(from)) {
        copyRecursive(path.join(from, entry.name), path.join(to, entry.name));
      }
      return;
    }
    fs.copyFileSync(from, to);
  };
  for (const entry of resolveEntries(srcDir)) {
    copyRecursive(path.join(srcDir, entry.name), path.join(dstDir, entry.name));
  }
};

const ensureSafeToWrite = async (pbDataDir, args) => {
  const lockPath = path.join(pbDataDir, ".sync_db.lock");
  if (fs.existsSync(lockPath)) {
    console.error("Another sync appears to be running. Found .sync_db.lock");
    process.exit(1);
  }
  fs.writeFileSync(lockPath, String(Date.now()));
  const cleanup = () => {
    try {
      fs.unlinkSync(lockPath);
    } catch (e) {
      void e;
    }
  };
  process.on("exit", cleanup);
  process.on("SIGINT", () => {
    cleanup();
    process.exit(1);
  });
  process.on("SIGTERM", () => {
    cleanup();
    process.exit(1);
  });
  const localHealth = args.localHealth || "http://localhost:8081/api/health";
  try {
    const res = await fetch(localHealth, { method: "HEAD" });
    if (res.ok && args.force !== "true") {
      console.error(
        `Refusing to modify pb_data while PocketBase is running at ${localHealth}. Re-run with --force=true if you know what you're doing.`
      );
      process.exit(1);
    }
  } catch (e) {
    void e;
  }
};

const downloadFile = async (url, outputPath) => {
  try {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const fileStream = fs.createWriteStream(outputPath);
    const reader = response.body.getReader();

    return new Promise((resolve, reject) => {
      const pump = async () => {
        try {
          const expectedLength = Number(response.headers.get("content-length") || 0);
          let bytesWritten = 0;
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            fileStream.write(value);
            bytesWritten += value.length || 0;
          }
          fileStream.end();
          fileStream.on("finish", () => {
            try {
              if (expectedLength > 0 && bytesWritten !== expectedLength) {
                throw new Error(
                  `Downloaded size ${bytesWritten} does not match expected ${expectedLength}`
                );
              }
              resolve();
            } catch (validationError) {
              fileStream.destroy();
              fs.unlink(outputPath, () => {});
              reject(validationError);
            }
          });
        } catch (error) {
          fileStream.destroy();
          fs.unlink(outputPath, () => {});
          reject(error);
        }
      };

      fileStream.on("error", (err) => {
        fs.unlink(outputPath, () => {});
        reject(err);
      });

      pump();
    });
  } catch (error) {
    throw new Error(`Download failed: ${error.message}`);
  }
};

main().catch(console.error);
