defmodule Kaffebase.Repo.Migrations.CreateOrderEvents do
  use Ecto.Migration

  def change do
    create table(:order_events, primary_key: false) do
      add :id, :string, primary_key: true
      add :aggregate_id, :string, null: false
      add :event_type, :string, null: false
      add :event_data, :text, null: false
      add :timestamp, :utc_datetime_usec, null: false
      add :sequence, :integer, null: false
    end

    create index(:order_events, [:aggregate_id, :sequence])
    create index(:order_events, [:timestamp])
  end
end
