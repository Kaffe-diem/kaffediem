---
title: Order Lifecycle
description: Deep dive into the order state machine and transition rules, from received to dispatched, including day_id management.
---

## State Machine

Orders progress through exactly 4 states:

```
┌──────────┐      ┌────────────┐      ┌───────────┐      ┌────────────┐
│ received │ ───> │ production │ ───> │ completed │ ───> │ dispatched │
└──────────┘      └────────────┘      └───────────┘      └────────────┘
   (new)            (preparing)          (ready)          (picked up)
```

**States are defined as Ecto.Enum:**

```elixir
field :state, Ecto.Enum, values: [:received, :production, :completed, :dispatched]
```

## State Descriptions

### received

**Meaning:** Order has been placed and is waiting to be started.

**Who sees it:** Kitchen staff

**Actions available:**
- Start production (→ production)
- Cancel order (delete)

**Display location:** Kitchen "Received" column

### production

**Meaning:** Order is actively being prepared.

**Who sees it:** Kitchen staff

**Actions available:**
- Mark complete (→ completed)
- Move back to received (→ received) if needed

**Display location:** Kitchen "Production" column

### completed

**Meaning:** Order is ready for customer pickup.

**Who sees it:**
- Kitchen staff
- Frontdesk staff
- Public display screen
- Customer (if logged in)

**Actions available:**
- Dispatch order (→ dispatched)

**Display location:**
- Kitchen "Completed" column
- Frontdesk "Ready for Pickup" column
- Display screen

### dispatched

**Meaning:** Order has been given to the customer.

**Who sees it:** Historical records only

**Actions available:** None (terminal state)

**Display location:** Order history, reports

## State Transitions

### Valid Transitions

| From | To | Trigger |
|------|----|----|
| received | production | Staff clicks "Start" |
| production | completed | Staff clicks "Complete" |
| completed | dispatched | Staff clicks "Dispatch" or customer confirms pickup |
| production | received | Staff clicks "Move back" (rare) |

### Invalid Transitions

- Cannot skip states (e.g., received → completed)
- Cannot move backwards from completed
- Cannot move backwards from dispatched
- dispatched is terminal

## Transition Implementation

### Backend

**File:** `kaffebase_web/controllers/order_controller.ex`

```elixir
def update(conn, %{"id" => id} = params) do
  with {:ok, order} <- Orders.update_order(id, params) do
    CollectionChannel.broadcast_change("order", "update", order)
    render(conn, :show, order: order)
  end
end
```

State is validated by changeset in `order.ex`.

### Frontend

**File:** Kitchen/frontdesk components

```typescript
import { updateOrder } from "$lib/stores/orders";

async function moveToProduction(order: Order) {
  await updateOrder({ ...order, state: "production" });
  // Real-time update propagates automatically
}
```

## Business Rules

### Order Creation

1. **Generate day_id**
   ```elixir
   day_id = Kaffebase.Orders.DayId.next(Repo)
   # Returns 100 for first order of day, 101 for second, etc.
   ```

2. **Initial state:** Always "received"

3. **Snapshot items:**
   - Resolve item IDs to current catalog data
   - Copy item name, price, category
   - Copy customization names, prices
   - Store as immutable JSON

4. **Broadcast creation:**
   ```elixir
   CollectionChannel.broadcast_change("order", "create", order)
   ```

### Order Updates

State transitions broadcast updates to all connected clients:

```json
{
  "action": "update",
  "record": {
    "id": "order_123",
    "state": "production",
    ...
  }
}
```

### Order Deletion

Orders can be deleted only in "received" state (before work has started).

```elixir
def delete(conn, %{"id" => id}) do
  with {:ok, order} <- Orders.get_order(id),
       true <- order.state == :received,
       {:ok, _} <- Orders.delete_order(id) do
    CollectionChannel.broadcast_delete("order", order)
    send_resp(conn, :no_content, "")
  else
    false -> {:error, :cannot_delete}
  end
end
```

## day_id Management

**File:** `kaffebase/lib/kaffebase/orders/day_id.ex`

### Algorithm

```elixir
def next(repo) do
  # Get today's date bounds
  day_start = DateTime.new!(Date.utc_today(), ~T[00:00:00], "Etc/UTC")
  next_day_start = DateTime.add(day_start, 86_400, :second)

  # Find highest day_id for today
  last_id = repo.one(
    from o in Order,
    where: o.inserted_at >= ^day_start and o.inserted_at < ^next_day_start,
    order_by: [desc: o.day_id],
    limit: 1,
    select: o.day_id
  ) || @baseline  # @baseline = 100

  {:ok, last_id + 1}
end
```

### Properties

- **Baseline:** 100 (first order each day)
- **Sequential:** Increments by 1
- **Daily reset:** Resets to 100 at midnight UTC
- **Thread-safe:** Database transaction ensures uniqueness

### Why 100?

- Avoids confusion with order IDs (which are strings)
- Easier to communicate verbally ("Order one-oh-two")
- Leaves room for special orders (1-99) if needed

## Concurrency Handling

### Race Conditions

Multiple concurrent order creations are safe:
- `day_id` generated inside database transaction
- Query ensures highest ID is used
- Increment happens atomically

### Real-time Conflicts

If two staff members try to transition the same order:
- Last write wins
- Both clients receive the final state via broadcast
- UI updates to reflect reality

## Metrics & Reporting

### Orders by State

```elixir
Orders.list_orders()
|> Enum.group_by(& &1.state)
|> Map.new(fn {state, orders} -> {state, length(orders)} end)
```

### Average Completion Time

```elixir
completed_orders = Orders.list_orders(state: :completed)

avg_time =
  completed_orders
  |> Enum.map(fn order ->
    DateTime.diff(order.updated_at, order.inserted_at, :minute)
  end)
  |> Enum.sum()
  |> div(length(completed_orders))
```

### Daily Throughput

```elixir
today_start = DateTime.utc_now() |> DateTime.to_date() |> DateTime.new!(~T[00:00:00], "Etc/UTC")

Orders.list_orders(from_date: today_start)
|> length()
```

## UI Patterns

### Kitchen Display

**File:** `src/routes/admin/orders/kitchen/+page.svelte`

```svelte
<script>
  import { orders } from "$lib/stores/orders";
  import { derived } from "svelte/store";

  const receivedOrders = derived(orders, $orders =>
    $orders.filter(o => o.state === "received")
  );

  const productionOrders = derived(orders, $orders =>
    $orders.filter(o => o.state === "production")
  );

  const completedOrders = derived(orders, $orders =>
    $orders.filter(o => o.state === "completed")
  );
</script>

<div class="grid grid-cols-3 gap-4">
  <div>
    <h2>Received</h2>
    {#each $receivedOrders as order}
      <OrderCard {order} onStart={() => moveToProduction(order)} />
    {/each}
  </div>

  <div>
    <h2>Production</h2>
    {#each $productionOrders as order}
      <OrderCard {order} onComplete={() => moveToCompleted(order)} />
    {/each}
  </div>

  <div>
    <h2>Completed</h2>
    {#each $completedOrders as order}
      <OrderCard {order} />
    {/each}
  </div>
</div>
```

### Public Display

Shows only "completed" orders waiting for pickup:

```svelte
const readyOrders = derived(orders, $orders =>
  $orders.filter(o => o.state === "completed")
);
```

## Best Practices

- **Don't skip states:** Always follow the state machine
- **Broadcast every transition:** Keep all clients in sync
- **Validate state changes:** Check current state before transitioning
- **Log state changes:** Audit trail for debugging
- **Handle concurrent updates gracefully:** UI should recover from race conditions

## Next Steps

- [Domain Model](/dev/concepts/domain-model) - Entity relationships
- [Real-time Architecture](/dev/concepts/realtime-architecture) - How updates propagate
- [Creating Your First Order](/dev/tutorials/creating-first-order) - Walkthrough
