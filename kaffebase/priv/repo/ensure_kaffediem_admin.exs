Mix.Task.run("app.start")

alias Ecto.Changeset
alias Kaffebase.Repo
alias Kaffebase.Accounts.User

email = "kaffediem@asvg.codes"
password = "kaffediem"
default_name = "Kaffediem"
default_username = "kaffediem"
now = DateTime.utc_now(:second)
hashed_password = Bcrypt.hash_pwd_salt(password)

upsert_result =
  Repo.transaction(fn ->
    case Repo.get_by(User, email: email) do
      nil ->
        params = %{
          email: email,
          hashed_password: hashed_password,
          confirmed_at: now,
          is_admin: true,
          name: default_name,
          username: default_username
        }

        %User{}
        |> Changeset.change(params)
        |> Repo.insert!()

      %User{} = user ->x
        updates =
          %{
            hashed_password: hashed_password,
            confirmed_at: now,
            is_admin: true
          }
          |> ensure_field(:name, user.name, default_name)
          |> ensure_field(:username, user.username, default_username)

        user
        |> Changeset.change(updates)
        |> Repo.update!()
    end
  end)

case upsert_result do
  {:ok, %User{id: id}} ->
    IO.puts("Ensured admin account #{email} (user id #{id}) is ready.")

  {:error, reason} ->
    raise "Failed to upsert admin account: #{inspect(reason)}"
end

defp ensure_field(attrs, key, existing_value, default_value) do
  if existing_value in [nil, ""] do
    Map.put(attrs, key, default_value)
  else
    attrs
  end
end
