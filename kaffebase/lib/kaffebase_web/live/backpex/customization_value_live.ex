defmodule KaffebaseWeb.Backpex.CustomizationValueLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Catalog.CustomizationValue,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:customization_values"
    ],
    fluid?: true

  alias Backpex.Fields.{Boolean, Number, Text}
  alias Ecto.Changeset
  alias Kaffebase.Catalog

  @impl Backpex.LiveResource
  def singular_name, do: "Customization Value"

  @impl Backpex.LiveResource
  def plural_name, do: "Customization Values"

  @impl Backpex.LiveResource
  def fields do
    [
      name: %{module: Text, label: "Name"},
      belongs_to: %{module: Text, label: "Customization Key"},
      price_increment_nok: %{module: Number, label: "Price Increment (NOK)"},
      sort_order: %{module: Number, label: "Sort Order"},
      constant_price: %{module: Boolean, label: "Constant Price"},
      enable: %{module: Boolean, label: "Enabled"}
    ]
  end

  def apply_changeset(%Changeset{data: customization_value}, attrs, metadata) do
    apply_changeset(customization_value, attrs, metadata)
  end

  def apply_changeset(customization_value, attrs, _metadata) do
    Catalog.change_customization_value(customization_value, attrs)
  end
end
