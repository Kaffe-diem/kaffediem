repo_config = Application.fetch_env!(:kaffebase, Kaffebase.Repo)
test_db = Keyword.fetch!(repo_config, :database)
source_db = Path.join(Path.dirname(test_db), "data.db")

if File.exists?(source_db) do
  for suffix <- ["", "-wal", "-shm"] do
    File.rm_rf!(test_db <> suffix)
  end

  File.cp!(source_db, test_db)
else
  File.touch!(test_db)
end

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Kaffebase.Repo, :manual)
