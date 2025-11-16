defmodule Kaffebase.ContentTest do
  use Kaffebase.DataCase

  alias Kaffebase.Content
  alias Kaffebase.Content.{Message, Status}
  alias Kaffebase.ContentFixtures
  alias Kaffebase.Repo

  setup do
    Repo.delete_all(Status)
    Repo.delete_all(Message)
    :ok
  end

  describe "messages" do
    test "list_messages/0 returns stored messages" do
      message = ContentFixtures.message_fixture()
      ids = Content.list_messages() |> Enum.map(& &1.id)
      assert message.id in ids
    end
  end

  describe "status" do
    test "get_status!/1 retrieves status by id" do
      status = ContentFixtures.status_fixture()

      loaded = Content.get_status!(status.id)
      assert loaded.id == status.id
      assert loaded.message == status.message
    end

    test "get_singleton_status/0 returns nil when none" do
      assert Content.get_singleton_status() == nil
    end

    test "get_singleton_status/0 returns first status" do
      status = ContentFixtures.status_fixture()

      loaded = Content.get_singleton_status()
      assert loaded.id == status.id
      assert loaded.message == status.message
    end
  end
end
