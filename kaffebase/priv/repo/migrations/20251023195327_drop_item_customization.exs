defmodule Kaffebase.Repo.Migrations.DropItemCustomization do
  use Ecto.Migration

  def change do
    drop_if_exists table(:order_item)
    drop_if_exists table(:item_customization)
    drop_if_exists index(:item_customization, [:key, :value])
  end
end
