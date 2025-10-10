defmodule KaffebaseWeb.Backpex.OrderLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Kaffebase.Orders.Order,
      repo: Kaffebase.Repo,
      update_changeset: &__MODULE__.apply_changeset/3,
      create_changeset: &__MODULE__.apply_changeset/3,
      item_query: &KaffebaseWeb.Backpex.Helpers.item_query_without_distinct/3
    ],
    layout: {KaffebaseWeb.Layouts, :admin},
    pubsub: [
      server: Kaffebase.PubSub,
      topic: "backpex:orders"
    ],
    fluid?: true

  alias Backpex.Fields.{Boolean, Number, Select, Text}
  alias Ecto.Changeset
  alias Kaffebase.Orders.Order

  @impl Backpex.LiveResource
  def singular_name, do: "Order"

  @impl Backpex.LiveResource
  def plural_name, do: "Orders"

  @impl Backpex.LiveResource
  def fields do
    [
      customer: %{module: Text, label: "Customer"},
      day_id: %{module: Number, label: "Day ID", orderable: true},
      state: %{module: Select, label: "State", options: &state_options/1},
      missing_information: %{module: Boolean, label: "Missing Information"},
      items: %{module: Text, label: "Items", only: [:show]}
    ]
  end

  def apply_changeset(%Changeset{data: order}, attrs, metadata) do
    apply_changeset(order, attrs, metadata)
  end

  def apply_changeset(order, attrs, _metadata) do
    Order.changeset(order, attrs)
  end

  defp state_options(_assigns) do
    Order.states()
    |> Enum.map(fn state ->
      {Phoenix.Naming.humanize(state), state}
    end)
  end
end
