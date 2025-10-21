defmodule Kaffebase.Repo.Migrations.AllowNullMessageSubtitle do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE message_new (
      created TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL,
      id TEXT PRIMARY KEY DEFAULT ('r'||lower(hex(randomblob(7)))) NOT NULL,
      subtitle TEXT DEFAULT NULL,
      title TEXT DEFAULT '' NOT NULL,
      updated TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL
    )
    """

    execute "INSERT INTO message_new SELECT * FROM message"
    execute "DROP TABLE message"
    execute "ALTER TABLE message_new RENAME TO message"
  end

  def down do
    execute """
    CREATE TABLE message_new (
      created TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL,
      id TEXT PRIMARY KEY DEFAULT ('r'||lower(hex(randomblob(7)))) NOT NULL,
      subtitle TEXT DEFAULT '' NOT NULL,
      title TEXT DEFAULT '' NOT NULL,
      updated TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL
    )
    """

    execute "INSERT INTO message_new SELECT * FROM message"
    execute "DROP TABLE message"
    execute "ALTER TABLE message_new RENAME TO message"
  end
end
