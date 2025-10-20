defmodule Kaffebase.Repo.Migrations.AllowNullItemImage do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE item_new (
      created TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL,
      id TEXT PRIMARY KEY DEFAULT ('r'||lower(hex(randomblob(7)))) NOT NULL,
      name TEXT DEFAULT '' NOT NULL,
      updated TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL,
      image TEXT DEFAULT NULL,
      price_nok NUMERIC DEFAULT 0 NOT NULL,
      category TEXT DEFAULT '' NOT NULL,
      enable BOOLEAN DEFAULT FALSE NOT NULL,
      sort_order NUMERIC DEFAULT 0 NOT NULL
    )
    """

    execute "INSERT INTO item_new SELECT * FROM item"
    execute "DROP TABLE item"
    execute "ALTER TABLE item_new RENAME TO item"
  end

  def down do
    execute """
    CREATE TABLE item_new (
      created TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL,
      id TEXT PRIMARY KEY DEFAULT ('r'||lower(hex(randomblob(7)))) NOT NULL,
      name TEXT DEFAULT '' NOT NULL,
      updated TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%fZ')) NOT NULL,
      image TEXT DEFAULT '' NOT NULL,
      price_nok NUMERIC DEFAULT 0 NOT NULL,
      category TEXT DEFAULT '' NOT NULL,
      enable BOOLEAN DEFAULT FALSE NOT NULL,
      sort_order NUMERIC DEFAULT 0 NOT NULL
    )
    """

    execute "INSERT INTO item_new SELECT * FROM item"
    execute "DROP TABLE item"
    execute "ALTER TABLE item_new RENAME TO item"
  end
end
