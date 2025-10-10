defmodule KaffebaseWeb.Backpex.CategoryLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Catalog.Category,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:categories"
    ],
    fluid?: true

  alias Backpex.Fields.{Boolean, Number, Text}
  alias Ecto.Changeset
  alias Kaffebase.Catalog

  @impl Backpex.LiveResource
  def singular_name, do: "Category"

  @impl Backpex.LiveResource
  def plural_name, do: "Categories"

  @impl Backpex.LiveResource
  def fields do
    [
      name: %{module: Text, label: "Name"},
      sort_order: %{module: Number, label: "Sort Order"},
      enable: %{module: Boolean, label: "Enabled"}
    ]
  end

  def apply_changeset(%Changeset{data: category}, attrs, metadata) do
    apply_changeset(category, attrs, metadata)
  end

  def apply_changeset(category, attrs, _metadata) do
    Catalog.change_category(category, attrs)
  end
end
