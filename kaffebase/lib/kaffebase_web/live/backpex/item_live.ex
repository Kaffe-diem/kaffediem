defmodule KaffebaseWeb.Backpex.ItemLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Catalog.Item,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:items"
    ],
    fluid?: true

  alias Backpex.Fields.{Boolean, Number, Text}
  alias Ecto.Changeset
  alias Kaffebase.Catalog

  @impl Backpex.LiveResource
  def singular_name, do: "Item"

  @impl Backpex.LiveResource
  def plural_name, do: "Items"

  @impl Backpex.LiveResource
  def fields do
    [
      name: %{module: Text, label: "Name"},
      category: %{module: Text, label: "Category"},
      price_nok: %{module: Number, label: "Price (NOK)"},
      sort_order: %{module: Number, label: "Sort Order"},
      enable: %{module: Boolean, label: "Enabled"},
      image: %{module: Text, label: "Image URL"}
    ]
  end

  def apply_changeset(%Changeset{data: item}, attrs, metadata) do
    apply_changeset(item, attrs, metadata)
  end

  def apply_changeset(item, attrs, _metadata) do
    Catalog.change_item(item, attrs)
  end
end
