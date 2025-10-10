defmodule KaffebaseWeb.Backpex.MessageLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Content.Message,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:messages"
    ],
    fluid?: true

  alias Backpex.Fields.Text
  alias Ecto.Changeset
  alias Kaffebase.Content

  @impl Backpex.LiveResource
  def singular_name, do: "Message"

  @impl Backpex.LiveResource
  def plural_name, do: "Messages"

  @impl Backpex.LiveResource
  def fields do
    [
      title: %{module: Text, label: "Title"},
      subtitle: %{module: Text, label: "Subtitle"}
    ]
  end

  def apply_changeset(%Changeset{data: message}, attrs, metadata) do
    apply_changeset(message, attrs, metadata)
  end

  def apply_changeset(message, attrs, _metadata) do
    Content.change_message(message, attrs)
  end
end
