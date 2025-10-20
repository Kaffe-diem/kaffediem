defmodule Kaffebase.Repo.Migrations.MigrateToEctoConventions do
  use Ecto.Migration

  def up do
    # Migrate category table
    execute """
    CREATE TABLE category_new (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      sort_order INTEGER DEFAULT 0 NOT NULL,
      enable BOOLEAN DEFAULT FALSE NOT NULL,
      valid_customizations TEXT DEFAULT '[]' NOT NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO category_new (id, name, sort_order, enable, valid_customizations, inserted_at, updated_at)
    SELECT id, name, sort_order, enable, valid_customizations, created, updated FROM category
    """

    execute "DROP TABLE category"
    execute "ALTER TABLE category_new RENAME TO category"

    # Migrate item table
    execute """
    CREATE TABLE item_new (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      price_nok NUMERIC NOT NULL,
      category TEXT NOT NULL,
      image TEXT,
      enable BOOLEAN DEFAULT FALSE NOT NULL,
      sort_order INTEGER DEFAULT 0 NOT NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO item_new (id, name, price_nok, category, image, enable, sort_order, inserted_at, updated_at)
    SELECT id, name, price_nok, category, NULLIF(image, ''), enable, sort_order, created, updated FROM item
    """

    execute "DROP TABLE item"
    execute "ALTER TABLE item_new RENAME TO item"
    execute "CREATE UNIQUE INDEX item_name_unique_index ON item (name)"

    # Migrate customization_key table
    execute """
    CREATE TABLE customization_key_new (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      enable BOOLEAN DEFAULT FALSE NOT NULL,
      label_color TEXT,
      default_value TEXT,
      multiple_choice BOOLEAN DEFAULT FALSE NOT NULL,
      sort_order INTEGER DEFAULT 0 NOT NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO customization_key_new (id, name, enable, label_color, default_value, multiple_choice, sort_order, inserted_at, updated_at)
    SELECT id, name, enable, NULLIF(label_color, ''), NULLIF(default_value, ''), multiple_choice, sort_order, created, updated FROM customization_key
    """

    execute "DROP TABLE customization_key"
    execute "ALTER TABLE customization_key_new RENAME TO customization_key"

    # Migrate customization_value table
    execute """
    CREATE TABLE customization_value_new (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      price_increment_nok NUMERIC DEFAULT 0 NOT NULL,
      belongs_to TEXT NOT NULL,
      enable BOOLEAN DEFAULT FALSE NOT NULL,
      constant_price BOOLEAN DEFAULT FALSE NOT NULL,
      sort_order INTEGER DEFAULT 0 NOT NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO customization_value_new (id, name, price_increment_nok, belongs_to, enable, constant_price, sort_order, inserted_at, updated_at)
    SELECT id, name, price_increment_nok, belongs_to, enable, constant_price, sort_order, created, updated FROM customization_value
    """

    execute "DROP TABLE customization_value"
    execute "ALTER TABLE customization_value_new RENAME TO customization_value"

    # Migrate item_customization table
    execute """
    CREATE TABLE item_customization_new (
      id TEXT PRIMARY KEY NOT NULL,
      key TEXT NOT NULL,
      value TEXT DEFAULT '[]' NOT NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO item_customization_new (id, key, value, inserted_at, updated_at)
    SELECT id, key, value, created, updated FROM item_customization
    """

    execute "DROP TABLE item_customization"
    execute "ALTER TABLE item_customization_new RENAME TO item_customization"
    execute "CREATE INDEX item_customization_key_value_index ON item_customization (key, value)"

    # Migrate message table
    execute """
    CREATE TABLE message_new (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      subtitle TEXT,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO message_new (id, title, subtitle, inserted_at, updated_at)
    SELECT id, title, subtitle, created, updated FROM message
    """

    execute "DROP TABLE message"
    execute "ALTER TABLE message_new RENAME TO message"

    # Migrate status table
    execute """
    CREATE TABLE status_new (
      id TEXT PRIMARY KEY NOT NULL,
      open BOOLEAN DEFAULT FALSE NOT NULL,
      show_message BOOLEAN DEFAULT FALSE NOT NULL,
      message TEXT,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO status_new (id, open, show_message, message, inserted_at, updated_at)
    SELECT id, open, show_message, NULLIF(message, ''), created, updated FROM status
    """

    execute "DROP TABLE status"
    execute "ALTER TABLE status_new RENAME TO status"

    # Migrate order table
    execute """
    CREATE TABLE order_new (
      id TEXT PRIMARY KEY NOT NULL,
      customer_id INTEGER,
      day_id INTEGER NOT NULL,
      items_data TEXT,
      state TEXT NOT NULL,
      missing_information BOOLEAN DEFAULT FALSE NOT NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO order_new (id, customer_id, day_id, items_data, state, missing_information, inserted_at, updated_at)
    SELECT id, customer_id, day_id, items_data, state, missing_information, created, updated FROM "order"
    """

    execute "DROP TABLE \"order\""
    execute "ALTER TABLE order_new RENAME TO \"order\""
    execute "CREATE INDEX order_customer_id_index ON \"order\" (customer_id)"

    # Drop PocketBase system tables
    execute "DROP TABLE IF EXISTS _collections"
    execute "DROP TABLE IF EXISTS _migrations"
    execute "DROP TABLE IF EXISTS _authOrigins"
    execute "DROP TABLE IF EXISTS _superusers"
    execute "DROP TABLE IF EXISTS _externalAuths"
    execute "DROP TABLE IF EXISTS _mfas"
    execute "DROP TABLE IF EXISTS _otps"
    execute "DROP TABLE IF EXISTS _params"
  end

  def down do
    raise "Cannot rollback migration - PocketBase no longer available"
  end
end
