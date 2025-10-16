defmodule Kaffebase.Repo.Migrations.CreateBaseTables do
  use Ecto.Migration

  def change do
    # Catalog tables
    create table(:category, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text, null: false
      add :sort_order, :integer, null: false, default: 0
      add :enable, :boolean, null: false, default: false
      add :valid_customizations, :text, null: false, default: "[]"
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    create table(:customization_key, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text, null: false
      add :enable, :boolean, null: false, default: false
      add :label_color, :text
      add :default_value, :text
      add :multiple_choice, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    create table(:customization_value, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text, null: false
      add :price_increment_nok, :text, null: false, default: "0"
      add :constant_price, :boolean, null: false, default: false
      add :belongs_to, :text, null: false
      add :enable, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    create table(:item, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :text, null: false
      add :price_nok, :text, null: false, default: "0"
      add :category, :text, null: false
      add :image, :text
      add :enable, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    create table(:item_customization, primary_key: false) do
      add :id, :string, primary_key: true
      add :key, :text, null: false
      add :value, :text, null: false, default: "[]"
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    # Content tables
    create table(:message, primary_key: false) do
      add :id, :string, primary_key: true
      add :title, :text, null: false
      add :subtitle, :text
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    create table(:status, primary_key: false) do
      add :id, :string, primary_key: true
      add :open, :boolean, null: false, default: false
      add :show_message, :boolean, null: false, default: false
      add :message, :text
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end

    # Order table
    create table(:order, primary_key: false) do
      add :id, :string, primary_key: true
      add :customer, :text
      add :day_id, :integer
      add :items, :text
      add :state, :text
      add :missing_information, :boolean
      timestamps(type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated)
    end
  end
end
