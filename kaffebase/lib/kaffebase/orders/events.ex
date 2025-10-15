defmodule Kaffebase.Orders.Events do
  @moduledoc """
  Event types for order lifecycle.

  Events are immutable facts that happened. They form the source of truth.
  """

  defmodule OrderPlaced do
    @moduledoc "Order was created"
    defstruct [:order_id, :customer, :day_id, :missing_information, :item_ids, :timestamp]

    @type t :: %__MODULE__{
            order_id: String.t(),
            customer: String.t() | nil,
            day_id: integer(),
            missing_information: boolean(),
            item_ids: [String.t()],
            timestamp: DateTime.t()
          }
  end

  defmodule OrderStateChanged do
    @moduledoc "Order state transitioned"
    defstruct [:order_id, :from_state, :to_state, :timestamp]

    @type t :: %__MODULE__{
            order_id: String.t(),
            from_state: atom() | nil,
            to_state: atom(),
            timestamp: DateTime.t()
          }
  end

  defmodule OrderUpdated do
    @moduledoc "Order metadata updated (customer, missing_information)"
    defstruct [:order_id, :changes, :timestamp]

    @type t :: %__MODULE__{
            order_id: String.t(),
            changes: map(),
            timestamp: DateTime.t()
          }
  end

  defmodule OrderItemCreated do
    @moduledoc "New order item was created"
    defstruct [:order_item_id, :item_id, :customization_ids, :timestamp]

    @type t :: %__MODULE__{
            order_item_id: String.t(),
            item_id: String.t(),
            customization_ids: [String.t()],
            timestamp: DateTime.t()
          }
  end

  defmodule OrderDeleted do
    @moduledoc "Order was deleted"
    defstruct [:order_id, :timestamp]

    @type t :: %__MODULE__{
            order_id: String.t(),
            timestamp: DateTime.t()
          }
  end
end
