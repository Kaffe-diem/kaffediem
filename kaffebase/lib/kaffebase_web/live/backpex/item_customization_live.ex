defmodule KaffebaseWeb.Backpex.ItemCustomizationLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Catalog.ItemCustomization,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:item_customizations"
    ],
    fluid?: true

  alias Backpex.Fields.{MultiSelect, Select}
  alias Ecto.Changeset
  alias Kaffebase.Catalog

  @impl Backpex.LiveResource
  def singular_name, do: "Item Customization"

  @impl Backpex.LiveResource
  def plural_name, do: "Item Customizations"

  @impl Backpex.LiveResource
  def fields do
    [
      key: %{
        module: Select,
        label: "Key",
        options: &key_options/1,
        prompt: "Choose a key",
        orderable: true
      },
      value: %{
        module: MultiSelect,
        label: "Values",
        options: &value_options/1,
        not_found_text: "No values for this key"
      }
    ]
  end

  def apply_changeset(%Changeset{data: item_customization}, attrs, metadata) do
    apply_changeset(item_customization, attrs, metadata)
  end

  def apply_changeset(item_customization, attrs, _metadata) do
    Catalog.change_item_customization(item_customization, attrs)
  end

  defp key_options(_assigns) do
    Catalog.list_customization_keys()
    |> Enum.map(fn key -> {key.name, key.id} end)
  end

  defp value_options(assigns) do
    key_id = selected_key(assigns)

    Catalog.list_customization_values(order_by: [asc: :sort_order, asc: :name], key_id: key_id)
    |> Enum.map(fn value -> {value.name, value.id} end)
  end

  defp selected_key(assigns) do
    cond do
      form = Map.get(assigns, :form) ->
        with %{value: value} when is_binary(value) and value != "" <- form[:key] do
          value
        else
          _ -> selected_key(Map.delete(assigns, :form))
        end

      item = Map.get(assigns, :item) ->
        case Map.get(item, :key) do
          value when is_binary(value) and value != "" -> value
          _ -> nil
        end

      true ->
        nil
    end
  end
end
