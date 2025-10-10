defmodule KaffebaseWeb.Backpex.StatusLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Content.Status,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:status"
    ],
    fluid?: true

  alias Backpex.Fields.{Boolean, Text}
  alias Ecto.Changeset
  alias Kaffebase.Content

  @impl Backpex.LiveResource
  def singular_name, do: "Status"

  @impl Backpex.LiveResource
  def plural_name, do: "Statuses"

  @impl Backpex.LiveResource
  def fields do
    [
      message: %{module: Text, label: "Message"},
      open: %{module: Boolean, label: "Open"},
      show_message: %{module: Boolean, label: "Show Message"}
    ]
  end

  def apply_changeset(%Changeset{data: status}, attrs, metadata) do
    apply_changeset(status, attrs, metadata)
  end

  def apply_changeset(status, attrs, _metadata) do
    Content.change_status(status, attrs)
  end
end
