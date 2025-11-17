defmodule Kaffebase.Repo.Migrations.Origin do
  use Ecto.Migration

  def change do
    # User authentication tables
    create_if_not_exists table(:users) do
      add :email, :string, null: false
      add :hashed_password, :string
      add :confirmed_at, :utc_datetime
      add :name, :string
      add :username, :string
      add :is_admin, :boolean, default: false, null: false
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists unique_index(:users, [:email])
    create_if_not_exists unique_index(:users, [:username])

    create_if_not_exists table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(type: :utc_datetime_usec, updated_at: false)
    end
    create_if_not_exists index(:users_tokens, [:user_id])
    create_if_not_exists unique_index(:users_tokens, [:context, :token])

    # Catalog tables
    create_if_not_exists table(:category) do
      add :name, :string, null: false
      add :sort_order, :integer, default: 0, null: false
      add :enable, :boolean, default: false, null: false
      add :valid_customizations, :text, default: "[]", null: false
      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:item) do
      add :name, :string, null: false
      add :price_nok, :decimal, null: false
      add :category_id, references(:category, on_delete: :restrict)
      add :image, :string
      add :enable, :boolean, default: false, null: false
      add :sort_order, :integer, default: 0, null: false
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists unique_index(:item, [:name])
    create_if_not_exists index(:item, [:category_id])

    create_if_not_exists table(:customization_key) do
      add :name, :string, null: false
      add :enable, :boolean, default: false, null: false
      add :label_color, :string
      add :default_value, :string
      add :multiple_choice, :boolean, default: false, null: false
      add :sort_order, :integer, default: 0, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:customization_value) do
      add :name, :string, null: false
      add :price_increment_nok, :decimal, default: 0, null: false
      add :belongs_to, :integer, null: false
      add :enable, :boolean, default: false, null: false
      add :constant_price, :boolean, default: false, null: false
      add :sort_order, :integer, default: 0, null: false
      timestamps(type: :utc_datetime_usec)
    end

    # Content tables
    create_if_not_exists table(:message) do
      add :title, :string, null: false
      add :subtitle, :string
      timestamps(type: :utc_datetime_usec)
    end

    create_if_not_exists table(:status) do
      add :open, :boolean, default: false, null: false
      add :show_message, :boolean, default: false, null: false
      add :message_id, :integer
      timestamps(type: :utc_datetime_usec)
    end

    # Order tables
    create_if_not_exists table(:order) do
      add :uuid, :text, null: false
      add :customer_id, :integer
      add :day_id, :integer, null: false
      add :items_data, :text
      add :state, :string, null: false
      add :missing_information, :boolean, default: false, null: false
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists index(:order, [:customer_id])
    create_if_not_exists unique_index(:order, [:uuid])
  end
end
