---
title: Real-time Architecture
description: How Kaffediem achieves real-time synchronization across multiple clients using Phoenix Channels and Svelte stores with event-driven patterns.
---

## Architecture Pattern

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│  Client A   │          │   Backend   │          │  Client B   │
│  (Browser)  │          │  (Phoenix)  │          │  (Browser)  │
└──────┬──────┘          └──────┬──────┘          └──────┬──────┘
       │                        │                        │
       │  1. REST POST          │                        │
       ├───────────────────────>│                        │
       │     (create order)     │                        │
       │                        │                        │
       │  2. DB Insert          │                        │
       │                        ├──────┐                 │
       │                        │      │ Store in SQLite │
       │                        │<─────┘                 │
       │                        │                        │
       │  3. WebSocket Broadcast│                        │
       │<───────────────────────┼───────────────────────>│
       │  (new order event)     │  (new order event)     │
       │                        │                        │
       │  4. Update Store       │                        │
       ├──────┐                 │                 ┌──────┤
       │      │ $orders += new  │                 │      │
       │<─────┘                 │                 └─────>│
       │                        │                        │
       │  5. Reactive UI        │                        │
       │  Re-renders            │           Re-renders   │
       │                        │                        │
```

## Components

### 1. WebSocket Connection (Phoenix Socket)

**File:** `src/lib/realtime/socket.ts`

Single WebSocket connection per client:

```typescript
const socket = new Socket("ws://localhost:4000/socket", {
  params: {}
});

socket.connect();
```

**Automatic reconnection** with exponential backoff.

### 2. Phoenix Channels (Backend)

**File:** `kaffebase_web/channels/collection_channel.ex`

Generic channel for all collections:

```elixir
def join("collection:" <> collection, payload, socket) do
  data = load_collection(collection, payload.options)
  {:ok, %{"items" => data}, socket}
end
```

**Broadcasting:**

```elixir
def broadcast_change(collection, action, record) do
  payload = %{
    "action" => action,  # "create" | "update" | "delete"
    "record" => record
  }

  KaffebaseWeb.Endpoint.broadcast("collection:#{collection}", "change", payload)
end
```

### 3. Svelte Stores (Frontend)

**File:** `src/lib/stores/collection.ts`

Generic pattern for subscribing to collections:

```typescript
export function createCollection<Api, T>(
  collectionName: string,
  fromApi: (data: Api) => T,
  options?: { onCreate?: (item: T) => void }
): Writable<T[]> {
  const { subscribe, set, update } = writable<T[]>([]);
  const channel = socket.channel(`collection:${collectionName}`);

  channel
    .join()
    .receive("ok", (response) => set(extract(response)))
    .receive("error", (err) => console.error(err));

  channel.on("change", (event) => {
    switch (event.action) {
      case "create": update(items => [...items, fromApi(event.record)]);
      case "update": update(items => items.map(i => i.id === event.record.id ? fromApi(event.record) : i));
      case "delete": update(items => items.filter(i => i.id !== event.record.id));
    }
  });

  return { subscribe, set, update };
}
```

### 4. Reactive UI (Svelte Components)

Components automatically re-render when stores update:

```svelte
<script>
  import { orders } from "$lib/stores/orders";
</script>

{#each $orders as order}
  <div>{order.day_id}</div>
{/each}
```

## Event Flow

### Create Event

1. **User action:** Click "Place Order"
2. **API call:** `POST /api/collections/order/records`
3. **Backend:** Validate, save to DB
4. **Broadcast:** `broadcast_change("order", "create", order)`
5. **All clients:** Receive event via WebSocket
6. **Store update:** `update(items => [...items, newOrder])`
7. **UI update:** Svelte reactively re-renders

### Update Event

1. **User action:** Click "Move to Production"
2. **API call:** `PATCH /api/collections/order/records/:id`
3. **Backend:** Update state in DB
4. **Broadcast:** `broadcast_change("order", "update", order)`
5. **All clients:** Receive event
6. **Store update:** Replace order in array
7. **UI update:** Order moves to new column

### Delete Event

1. **User action:** Click "Delete"
2. **API call:** `DELETE /api/collections/order/records/:id`
3. **Backend:** Remove from DB
4. **Broadcast:** `broadcast_delete("order", order)`
5. **All clients:** Receive event
6. **Store update:** Filter out deleted order
7. **UI update:** Order disappears

## Special Case: Menu Collection

Menu broadcasts the **entire** menu on any change:

```elixir
defp load_collection("menu", _options) do
  %{
    tree: build_menu_tree(),
    indexes: build_menu_indexes()
  }
end
```

**Why?** Menu structure is hierarchical and complex. Easier to replace entirely than merge updates.

## Concurrency Handling

### Last Write Wins

Multiple users editing same record:
- Both writes succeed
- Last write wins
- All clients converge to final state via broadcast

### Optimistic Updates (Optional)

Can implement optimistic updates:

```typescript
async function createOrder(order) {
  // Optimistic: add immediately
  update(orders => [...orders, order]);

  try {
    await apiPost("order", order);
  } catch (err) {
    // Rollback on error
    update(orders => orders.filter(o => o.id !== order.id));
  }
}
```

Currently **not implemented** - waits for server confirmation.

## Performance Considerations

### Connection Limits

- One WebSocket per browser tab
- WebSockets scale to thousands per server
- Consider load balancing for production

### Broadcast Fanout

- Broadcasts sent to all connected clients
- Phoenix Channels handles fanout efficiently
- PubSub backed by pg2 (or Redis in distributed setup)

### Message Size

- Keep broadcast payloads small
- Only send changed data
- Frontend merges into existing state

### Throttling

For rapid updates, consider throttling:

```typescript
import { debounce } from "$lib/utils";

const debouncedUpdate = debounce((order) => {
  updateOrder(order);
}, 500);
```

## Reliability

### Reconnection

Phoenix Socket automatically reconnects:
- Exponential backoff
- Rejoins channels on reconnect
- Fetches missed updates (if implemented)

### Missed Updates

Simple approach: Reload data on reconnect:

```typescript
socket.onOpen(() => {
  channel.push("reload", {});
});
```

Advanced: Track sequence numbers and replay missed events.

### Network Partitions

If disconnected:
- UI shows "offline" indicator
- Queues writes locally
- Syncs when reconnected

Currently **not implemented** - requires online connection.

## Debugging

### Browser DevTools

1. Open DevTools → Network → WS
2. Click WebSocket connection
3. View Messages tab
4. See real-time events

### Backend Logs

```elixir
Logger.info("Broadcasting #{action} to collection:#{collection}")
```

### Store Inspection

```svelte
<script>
  import { orders } from "$lib/stores/orders";
  $: console.log("Orders updated", $orders);
</script>
```

## Alternative Patterns

### Polling

Could use HTTP polling instead:

```typescript
setInterval(async () => {
  const response = await fetch("/api/collections/order/records");
  const data = await response.json();
  orders.set(data.items);
}, 5000);  // Every 5 seconds
```

**Downsides:**
- Higher latency
- More server load
- More network traffic

### Server-Sent Events (SSE)

One-way server-to-client:

```typescript
const events = new EventSource("/api/events");
events.onmessage = (event) => {
  const data = JSON.parse(event.data);
  // Update store
};
```

**Downsides:**
- One-way only (need separate POST requests)
- Less browser support than WebSockets

## Best Practices

- **Single WebSocket per app:** Reuse connection
- **Channel per collection:** Separate concerns
- **Broadcast after DB commit:** Ensure consistency
- **Handle reconnection:** Graceful degradation
- **Clean up channels:** Leave when component unmounts
- **Show connection status:** Let users know if offline
- **Throttle rapid updates:** Avoid UI thrashing

## Next Steps

- [WebSocket Channels](/dev/reference/websocket-channels) - Protocol reference
- [Stores Reference](/dev/reference/stores) - Store API
- [Add WebSocket Subscription](/dev/how-to/add-websocket-subscription) - Implementation guide
