---
title: Add WebSocket Subscription
description: Subscribe to real-time updates from the backend using Phoenix Channels and Svelte stores in Kaffediem applications.
---

## When to Use This

You want to:
- Display real-time data updates across multiple clients
- Build a live dashboard or monitoring view
- Sync state without polling

## Quick Example: Subscribe to Orders

```typescript
import { createCollection } from "$lib/stores/collection";
import type { Order } from "$lib/types";

export const orders = createCollection<any, Order>(
  "order",           // Channel name
  fromApiTransform,  // Transform function
  {
    queryParams: { from_date: "2025-01-01" },  // Optional filters
    onCreate: (order) => console.log("New order!", order)
  }
);
```

Use in a component:

```svelte
<script lang="ts">
  import { orders } from "$lib/stores/orders";
</script>

{#each $orders as order}
  <div>{order.id} - {order.state}</div>
{/each}
```

## Step 1: Ensure Backend Channel Supports Your Collection

Check `kaffebase_web/channels/collection_channel.ex`:

```elixir
defp load_collection("your_collection", options) do
  YourContext.list_items(options)  # Must return a list
end
```

If not present, add it:

```elixir
defp load_collection("feedback", _options) do
  Content.list_feedback()
end
```

## Step 2: Create the Frontend Store

Pattern 1: **Using `createCollection`** (for lists of records)

```typescript
import { createCollection, createCrudOperations } from "$lib/stores/collection";
import type { Feedback } from "$lib/types";

function fromApi(data: any): Feedback {
  return {
    id: data.id,
    rating: data.rating,
    comment: data.comment,
    created: data.inserted_at,
    updated: data.updated_at
  };
}

export const feedback = createCollection<any, Feedback>("feedback", fromApi);

// Optional: CRUD operations
export const { create, update, delete: deleteFeedback } =
  createCrudOperations<Feedback>("feedback");
```

Pattern 2: **Using `createChannelStore`** (for single values or custom data)

```typescript
import { createChannelStore } from "$lib/stores/collection";

export const appStatus = createChannelStore<{ online: boolean }>("status", {
  initialValue: { online: false },
  extract: (response: any) => response.data,
  onChange: (event: any, { set }) => {
    if (event.action === "update") {
      set(event.record);
    }
  }
});
```

## Step 3: Use in Components

### Basic Usage

```svelte
<script lang="ts">
  import { feedback } from "$lib/stores/feedback";
</script>

<div>
  {#each $feedback as item}
    <p>{item.comment}</p>
  {/each}
</div>
```

### With Query Parameters

```typescript
import { derived } from "svelte/store";
import { createCollection } from "$lib/stores/collection";

// Subscribe only to today's orders
export const todayOrders = createCollection(
  "order",
  fromApi,
  { queryParams: { from_date: new Date().toISOString() } }
);
```

### Derived Stores

```typescript
import { derived } from "svelte/store";
import { orders } from "$lib/stores/orders";

export const receivedOrders = derived(orders, ($orders) =>
  $orders.filter((o) => o.state === "received")
);
```

## Step 4: Handle CRUD Operations

### Create

```typescript
import { createFeedback } from "$lib/stores/feedback";

await createFeedback({
  id: "",
  rating: 5,
  comment: "Great!"
});
```

Backend broadcasts, and all subscribed clients receive the new record automatically.

### Update

```typescript
import { updateFeedback } from "$lib/stores/feedback";

await updateFeedback({
  id: "existing_id",
  rating: 4,
  comment: "Updated comment"
});
```

### Delete

```typescript
import { deleteFeedback } from "$lib/stores/feedback";

await deleteFeedback("item_id");
```

## Step 5: Cleanup (Important!)

If your store is created dynamically or on a specific page, clean it up when done:

```svelte
<script lang="ts">
  import { onDestroy } from "svelte";
  import { createCollection } from "$lib/stores/collection";

  const myStore = createCollection("data", fromApi);

  onDestroy(() => {
    myStore.destroy();  // ← Leaves the channel, frees resources
  });
</script>
```

For global stores (like `orders`, `menu`), no cleanup needed.

## Advanced: Custom Channel Events

If you need more than "create/update/delete" events:

### Backend

```elixir
# In your controller or context
KaffebaseWeb.Endpoint.broadcast("collection:orders", "order_ready", %{
  order_id: order.id,
  customer: order.customer_id
})
```

### Frontend

```typescript
import { getSocket } from "$lib/realtime/socket";

const socket = getSocket();
const channel = socket?.channel("collection:orders");

channel?.on("order_ready", (payload) => {
  console.log("Order ready!", payload.order_id);
  // Play sound, show notification, etc.
});
```

## Testing Real-time Updates

1. Open your app in two browser tabs
2. Make a change in one tab (e.g., create a record)
3. Verify it appears in both tabs immediately

Check browser console for:
- WebSocket connection: `ws://localhost:4000/socket`
- Channel join messages: `collection:your_collection joined`
- Change events: `{action: "create", record: {...}}`

## Troubleshooting

### Store Not Updating

Check:
1. Backend broadcasts after CRUD operations
2. `CollectionChannel.load_collection/2` includes your collection
3. WebSocket connection is active (browser console)
4. No JavaScript errors

### Initial Data Not Loading

Check:
1. `extract` function in store definition
2. Backend returns data in expected format: `%{items: [...]}`
3. `fromApi` transform function handles all fields

### Memory Leaks

Check:
1. Calling `.destroy()` on dynamic stores in `onDestroy`
2. Not creating stores inside reactive statements

## Best Practices

- **Use `createCollection` for lists**: Standard pattern for CRUD resources
- **Use `createChannelStore` for complex data**: Custom structures or non-list data
- **Filter on backend when possible**: Use `queryParams` to reduce data transfer
- **Derive don't duplicate**: Use `derived()` instead of creating multiple subscriptions
- **Clean up dynamic stores**: Call `.destroy()` when component unmounts

## Next Steps

- [Implement Real-time Updates](/dev/how-to/implement-realtime-updates) - Full feature walkthrough
- [WebSocket Channels Reference](/dev/reference/websocket-channels) - Channel protocols
- [Real-time Architecture](/dev/concepts/realtime-architecture) - How it all works
