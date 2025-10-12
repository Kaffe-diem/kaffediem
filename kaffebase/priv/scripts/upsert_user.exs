defmodule Kaffebase.Scripts.UpsertUser do
  @moduledoc false

  import Ecto.Query

  alias Ecto.Changeset
  alias Kaffebase.Accounts.User
  alias Kaffebase.Repo

  @strict_opts [
    email: :string,
    password: :string,
    name: :string,
    username: :string,
    admin: :boolean,
    confirmed: :boolean
  ]

  @aliases [
    e: :email,
    p: :password,
    n: :name,
    u: :username,
    a: :admin,
    c: :confirmed
  ]

  @doc """
  Upserts a user based on the provided CLI arguments.
  """
  def run!(argv) do
    {parsed_opts, _rest, invalid} =
      OptionParser.parse(argv, strict: @strict_opts, aliases: @aliases)

    case invalid do
      [] -> ensure_user(parsed_opts)
      _ -> raise "Invalid options supplied: #{inspect(invalid)}"
    end
  end

  defp ensure_user(opts) do
    opts_map = Map.new(opts)

    email = fetch_required(opts_map, :email)
    password = fetch_required(opts_map, :password)

    name = resolve_name(opts_map[:name], email)
    username_base = resolve_username_base(opts_map[:username], email)
    admin? = Keyword.get(opts, :admin, false)
    confirmed? = Keyword.get(opts, :confirmed, admin?)

    now = DateTime.utc_now(:second)
    hashed_password = Bcrypt.hash_pwd_salt(password)

    Repo.transaction(fn ->
      case Repo.get_by(User, email: email) do
        nil ->
          insert_user(email, hashed_password, name, username_base, admin?, confirmed?, now)

        %User{} = user ->
          update_user(user, hashed_password, name, username_base, admin?, confirmed?, now, opts)
      end
    end)
    |> handle_result(email)
  end

  defp insert_user(email, hashed_password, name, username_base, admin?, confirmed?, now) do
    username = ensure_unique_username(username_base, nil)

    params = %{
      email: email,
      hashed_password: hashed_password,
      confirmed_at: confirm_timestamp(confirmed?, now),
      is_admin: admin?,
      name: name,
      username: username,
      inserted_at: now,
      updated_at: now
    }

    %User{}
    |> Changeset.change(params)
    |> Repo.insert!()
  end

  defp update_user(user, hashed_password, name, username_base, admin?, confirmed?, now, opts) do
    updates =
      %{
        hashed_password: hashed_password,
        updated_at: now
      }
      |> maybe_put(:name, name, name_update?(opts, user))
      |> maybe_put(:username, ensure_username(user, username_base), username_update?(opts, user))
      |> maybe_put(:is_admin, admin?, Keyword.has_key?(opts, :admin))
      |> maybe_put(
        :confirmed_at,
        confirm_timestamp(confirmed?, now),
        Keyword.has_key?(opts, :confirmed)
      )

    user
    |> Changeset.change(updates)
    |> Repo.update!()
  end

  defp ensure_username(%User{username: current, id: id}, username_base) do
    cond do
      is_nil(current) or current == "" ->
        ensure_unique_username(username_base, id)

      true ->
        current
    end
  end

  defp ensure_unique_username(base, ignore_id) do
    if username_taken?(base, ignore_id) do
      base
      |> bump_username()
      |> ensure_unique_username(ignore_id)
    else
      base
    end
  end

  defp username_taken?(username, nil) do
    Repo.exists?(from u in User, where: u.username == ^username)
  end

  defp username_taken?(username, id) do
    Repo.exists?(from u in User, where: u.username == ^username and u.id != ^id)
  end

  defp bump_username(base) do
    suffix =
      3
      |> :crypto.strong_rand_bytes()
      |> Base.encode16(case: :lower)

    "#{base}-#{suffix}"
  end

  defp confirm_timestamp(true, now), do: now
  defp confirm_timestamp(false, _now), do: nil

  defp maybe_put(attrs, _key, _value, false), do: attrs
  defp maybe_put(attrs, key, value, true), do: Map.put(attrs, key, value)

  defp name_update?(opts, %User{name: name}) do
    Keyword.has_key?(opts, :name) or name in [nil, ""]
  end

  defp username_update?(opts, %User{username: username}) do
    Keyword.has_key?(opts, :username) or username in [nil, ""]
  end

  defp resolve_name(nil, email), do: derive_name_from_email(email)
  defp resolve_name("", email), do: derive_name_from_email(email)
  defp resolve_name(name, _email), do: name

  defp derive_name_from_email(email) do
    [local | _] = String.split(email, "@")

    local
    |> String.replace(~r/[\._]/, " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp resolve_username_base(nil, email), do: sanitize_username_from_email(email)
  defp resolve_username_base("", email), do: sanitize_username_from_email(email)
  defp resolve_username_base(username, _), do: username

  defp sanitize_username_from_email(email) do
    [local | _] = String.split(email, "@")

    local
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9_-]/, "-")
    |> String.trim("-")
    |> ensure_present("user")
  end

  defp ensure_present("", fallback), do: fallback
  defp ensure_present(value, _fallback), do: value

  defp fetch_required(opts, key) do
    case opts do
      %{^key => value} when is_binary(value) and value != "" ->
        value

      _ ->
        raise "Missing required option --#{key}"
    end
  end

  defp handle_result({:ok, %User{id: id}}, email) do
    IO.puts("Upserted user #{email} (user id #{id}).")
    :ok
  end

  defp handle_result({:error, reason}, _email) do
    raise "Failed to upsert user: #{inspect(reason)}"
  end
end

Mix.Task.run("app.start")
Kaffebase.Scripts.UpsertUser.run!(System.argv())
