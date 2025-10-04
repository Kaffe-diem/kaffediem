defmodule Kaffebase.Orders.OrderItem do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "order_item" do
    field :created_at, :string, source: :created
    field :customization, :map
    field :item_id, :string, source: :item
    field :updated_at, :string, source: :updated
  end
end
