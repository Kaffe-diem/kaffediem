defmodule Kaffebase.Repo.Migrations.AddItemsDataToOrder do
  use Ecto.Migration

  def change do
    alter table(:order) do
      add :items_data, :text
    end
  end
end
