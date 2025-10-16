defmodule Kaffebase.Repo.Migrations.MigrateCustomerToIntegerFk do
  use Ecto.Migration

  def up do
    # Add new customer_id column as integer
    alter table(:order) do
      add :customer_id, :integer
    end

    # Migrate all existing orders to user_id = 1 (the only user in system)
    execute("UPDATE \"order\" SET customer_id = 1")

    # Make customer_id non-nullable now that it's populated
    execute("CREATE TABLE order_new AS SELECT id, customer_id, day_id, items, items_data, state, missing_information, created, updated FROM \"order\"")
    execute("DROP TABLE \"order\"")
    execute("ALTER TABLE order_new RENAME TO \"order\"")

    # Add foreign key constraint
    create index(:order, [:customer_id])
  end

  def down do
    # Add back old customer column as text
    alter table(:order) do
      add :customer, :text, default: ""
    end

    # Can't reverse the data migration as we lost the old PocketBase IDs
    execute("UPDATE \"order\" SET customer = 'i89crpups3fgkx9'")

    # Drop customer_id
    alter table(:order) do
      remove :customer_id
    end
  end
end
