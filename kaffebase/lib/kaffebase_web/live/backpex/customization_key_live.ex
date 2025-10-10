defmodule KaffebaseWeb.Backpex.CustomizationKeyLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Catalog.CustomizationKey,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:customization_keys"
    ],
    fluid?: true

  alias Backpex.Fields.{Boolean, Number, Text}
  alias Ecto.Changeset
  alias Kaffebase.Catalog

  @impl Backpex.LiveResource
  def singular_name, do: "Customization Key"

  @impl Backpex.LiveResource
  def plural_name, do: "Customization Keys"

  @impl Backpex.LiveResource
  def fields do
    [
      name: %{module: Text, label: "Name"},
      default_value: %{module: Text, label: "Default Value"},
      sort_order: %{module: Number, label: "Sort Order"},
      multiple_choice: %{module: Boolean, label: "Multiple Choice"},
      enable: %{module: Boolean, label: "Enabled"}
    ]
  end

  def apply_changeset(%Changeset{data: customization_key}, attrs, metadata) do
    apply_changeset(customization_key, attrs, metadata)
  end

  def apply_changeset(customization_key, attrs, _metadata) do
    Catalog.change_customization_key(customization_key, attrs)
  end
end
