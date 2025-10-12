defmodule Kaffebase.Repo.Migrations.EnsureKaffediemAdmin do
  use Ecto.Migration

  import Ecto.Query

  @email "kaffediem@asvg.codes"
  @password "kaffediem"
  @default_name "Kaffediem"
  @default_username "kaffediem"

  def up do
    {:ok, _} = Application.ensure_all_started(:bcrypt_elixir)

    repo = repo()
    now = DateTime.utc_now(:second)
    hashed_password = Bcrypt.hash_pwd_salt(@password)
    admin_flag = boolean_value(repo, true)

    case fetch_user(repo) do
      nil ->
        insert_user(repo, hashed_password, admin_flag, now)

      %{id: id} = user ->
        update_user(repo, id, user, hashed_password, admin_flag, now)
    end
  end

  def down do
    :ok
  end

  defp fetch_user(repo) do
    repo.one(
      from(u in "users",
        where: u.email == ^@email,
        select: %{id: u.id, name: u.name, username: u.username}
      )
    )
  end

  defp insert_user(repo, hashed_password, admin_flag, now) do
    username = ensure_unique_username(repo, @default_username)

    repo.insert_all("users", [
      %{
        email: @email,
        hashed_password: hashed_password,
        confirmed_at: now,
        is_admin: admin_flag,
        name: @default_name,
        username: username,
        inserted_at: now,
        updated_at: now
      }
    ])
  end

  defp update_user(repo, id, user, hashed_password, admin_flag, now) do
    updates =
      %{
        hashed_password: hashed_password,
        confirmed_at: now,
        is_admin: admin_flag,
        updated_at: now
      }
      |> maybe_put(:name, user.name, @default_name)
      |> maybe_put(:username, user.username, ensure_unique_username(repo, @default_username))

    repo.update_all(
      from(u in "users", where: u.id == ^id),
      set: Map.to_list(updates)
    )
  end

  defp maybe_put(attrs, key, current, default) when current in [nil, ""] do
    Map.put(attrs, key, default)
  end

  defp maybe_put(attrs, _key, _current, _default), do: attrs

  defp ensure_unique_username(repo, base) do
    case repo.one(from(u in "users", where: u.username == ^base, select: 1)) do
      nil -> base
      _ -> base <> "-" <> random_suffix()
    end
  end

  defp random_suffix do
    4
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end

  defp boolean_value(repo, value) do
    case repo.__adapter__() do
      Ecto.Adapters.SQLite3 -> if(value, do: 1, else: 0)
      _ -> value
    end
  end
end
