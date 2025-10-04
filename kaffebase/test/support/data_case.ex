defmodule Kaffebase.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Kaffebase.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Kaffebase.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Kaffebase.DataCase
    end
  end

  setup tags do
    Kaffebase.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    ensure_test_db!()
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Kaffebase.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  defp ensure_test_db! do
    repo_config = Application.fetch_env!(:kaffebase, Kaffebase.Repo)
    db_path = Keyword.fetch!(repo_config, :database)

    unless File.exists?(db_path) do
      source = Path.join(Path.dirname(db_path), "data.db")

      if File.exists?(source) do
        File.cp!(source, db_path)
      else
        File.touch!(db_path)
      end
    end
  end
end
