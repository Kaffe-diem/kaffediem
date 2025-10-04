defmodule Kaffebase.AccountsTest do
  use Kaffebase.DataCase

  alias Kaffebase.Accounts
  alias Kaffebase.Accounts.User
  alias Kaffebase.AccountsFixtures

  describe "users" do
    test "list_users/0 returns stored users" do
      user = AccountsFixtures.user_fixture()
      ids = Accounts.list_users() |> Enum.map(& &1.id)
      assert user.id in ids
    end

    test "get_user!/1 returns the user" do
      user = AccountsFixtures.user_fixture()
      assert %User{id: result_id} = Accounts.get_user!(user.id)
      assert result_id == user.id
    end

    test "get_user_by_email/1 finds by email" do
      user = AccountsFixtures.user_fixture(%{email: "tester@example.com"})
      assert %User{id: result_id} = Accounts.get_user_by_email("tester@example.com")
      assert result_id == user.id
    end

    test "get_user_by_username/1 finds by username" do
      user = AccountsFixtures.user_fixture(%{username: "tester"})
      assert %User{id: result_id} = Accounts.get_user_by_username("tester")
      assert result_id == user.id
    end

    test "create_user/1 with valid data persists" do
      attrs = %{
        username: "phoenix",
        name: "Phoenix",
        email: "phoenix@example.com",
        password: "secret",
        token_key: "tok-secret"
      }

      assert {:ok, user} = Accounts.create_user(attrs)
      assert user.username == "phoenix"
      assert user.token_key == "tok-secret"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Accounts.create_user(%{username: nil})
      assert %{name: ["can't be blank"], username: ["can't be blank"]} = errors_on(changeset)
    end

    test "update_user/2 updates fields" do
      user = AccountsFixtures.user_fixture()
      assert {:ok, updated} = Accounts.update_user(user, %{name: "Updated"})
      assert updated.name == "Updated"
    end

    test "delete_user/1 removes the record" do
      user = AccountsFixtures.user_fixture()
      assert {:ok, _} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
