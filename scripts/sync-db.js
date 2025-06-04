import PocketBase from 'pocketbase';
import fs from 'fs';
import path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const main = async () => {
  const args = parseArgs();
  validateArgs(args);
  
  const pb = new PocketBase(args.host);
  const pbDataDir = ensurePbDataDir();
  
  try {
    await authenticateAdmin(pb, args.email, args.password);

    const currentLocalVersion = readCurrentLocalBackupVersion(pbDataDir);
    const latestRemoteBackup = await getLatestBackup(pb);

    if (currentLocalVersion && latestRemoteBackup.key === currentLocalVersion) {
      console.log(`✅ Local backup (${currentLocalVersion}) is already up-to-date with the latest remote backup (${latestRemoteBackup.key}). No sync needed.`);
      process.exit(0);
    }

    if (currentLocalVersion) {
      console.log(`ℹ️ Current local backup: ${currentLocalVersion}. New remote backup available: ${latestRemoteBackup.key}.`);
    } else {
      console.log(`ℹ️ No local backup version found. Proceeding with download of latest remote backup: ${latestRemoteBackup.key}.`);
    }

    await downloadAndExtractBackup(pb, latestRemoteBackup, pbDataDir);
    await writeCurrentLocalBackupVersion(pbDataDir, latestRemoteBackup.key);

    console.log(`✅ Backup ${latestRemoteBackup.key} downloaded and extracted successfully. Local version updated.`);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

const parseArgs = () => {
  const args = {};
  const argv = process.argv.slice(2);
  
  argv.forEach(arg => {
    if (arg.startsWith('--')) {
      const [key, value] = arg.split('=');
      const cleanKey = key.substring(2);
      args[cleanKey] = value;
    }
  });
  
  return args;
};

const validateArgs = (args) => {
  if (!args.host || !args.email || !args.password) {
    console.error('Missing required arguments:');
    console.error('Usage: node sync-db.js --host=<pb_host> --email=<admin_email> --password=<admin_password>');
    process.exit(1);
  }
};

const authenticateAdmin = async (pb, email, password) => {
  console.log('Authenticating as superuser...');
  await pb.collection('_superusers').authWithPassword(email, password);
};

const getLatestBackup = async (pb) => {
  console.log('Fetching backup list...');
  const backups = await pb.backups.getFullList();
  
  if (backups.length === 0) {
    console.log('No backups found');
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
  const downloadUrl = pb.backups.getDownloadUrl(token, backup.key);
  const outputPath = await downloadBackupFile(downloadUrl, backup.key, pbDataDir);
  
  if (backup.key.endsWith('.zip')) {
    await extractBackup(outputPath);
  }
};

const getFileToken = async (pb) => {
  console.log('Getting file token...');
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
  const pbDataDir = path.resolve('./pocketbase/pb_data');
  if (!fs.existsSync(pbDataDir)) {
    fs.mkdirSync(pbDataDir, { recursive: true });
  }
  return pbDataDir;
};

const readCurrentLocalBackupVersion = (pbDataDir) => {
  const versionFilePath = path.join(pbDataDir, 'current_backup_version.txt');
  if (fs.existsSync(versionFilePath)) {
    try {
      return fs.readFileSync(versionFilePath, 'utf-8').trim();
    } catch (error) {
      console.warn(`⚠️ Could not read local backup version file: ${error.message}`);
      return null;
    }
  }
  return null;
};

const writeCurrentLocalBackupVersion = async (pbDataDir, backupKey) => {
  const versionFilePath = path.join(pbDataDir, 'current_backup_version.txt');
  try {
    fs.writeFileSync(versionFilePath, backupKey);
    console.log(`📝 Updated local backup version file to: ${backupKey}`);
  } catch (error) {
    console.error(`❌ Failed to write local backup version file: ${error.message}`);
  }
};

const extractBackup = async (outputPath) => {
  console.log('📦 Extracting backup...');
  const pbDataDir = path.dirname(outputPath);
  
  try {
    await execAsync(`unzip -o "${outputPath}" -d "${pbDataDir}"`);
    console.log(`📂 Extracted to: ${pbDataDir}`);
    
    fs.unlinkSync(outputPath);
    console.log('🗑️  Removed zip file');
  } catch (error) {
    console.error('❌ Extraction failed:', error.message);
    console.log('💾 Zip file preserved at:', outputPath);
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
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            fileStream.write(value);
          }
          fileStream.end();
          resolve();
        } catch (error) {
          fileStream.destroy();
          fs.unlink(outputPath, () => {});
          reject(error);
        }
      };

      fileStream.on('error', (err) => {
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