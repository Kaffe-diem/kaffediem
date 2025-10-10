defmodule Kaffebase.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :name, :string
      add :username, :string
      add :is_admin, :boolean, default: false, null: false
    end

    execute("UPDATE users SET name = COALESCE(name, 'User')")

    execute(
      "UPDATE users SET username = 'user-' || substr(hex(randomblob(8)), 1, 8) WHERE username IS NULL"
    )

    create unique_index(:users, [:username])
  end

  def down do
    drop_if_exists index(:users, [:username])

    alter table(:users) do
      remove :is_admin
      remove :username
      remove :name
    end
  end
end
