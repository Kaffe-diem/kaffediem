---
title: WebSocket Channels Reference
description: Real-time communication in Kaffediem using Phoenix Channels over WebSocket, including connection management and available channels.
---

## Connection

```typescript
import { Socket } from "phoenix";

const socket = new Socket("ws://localhost:4000/socket", {
  params: {}
});

socket.connect();
```

## Collection Channels

Subscribe to real-time updates for any collection.

### Channel Pattern

```
collection:{collection_name}
```

### Join Channel

```typescript
const channel = socket.channel("collection:order", {
  options: {
    // Optional query parameters
    from_date: "2025-01-01",
    customer_id: 123
  }
});

channel
  .join()
  .receive("ok", (response) => {
    console.log("Joined", response);
    // response = { items: [...] }
  })
  .receive("error", (err) => {
    console.error("Failed to join", err);
  });
```

### Events

#### `change` Event

Broadcasted when records are created, updated, or deleted.

```typescript
channel.on("change", (payload) => {
  console.log(payload);
  // payload = {
  //   action: "create" | "update" | "delete",
  //   record: { id, ... }
  // }
});
```

**Actions:**

- **create**: New record added
  ```json
  {
    "action": "create",
    "record": { "id": "new_id", "name": "New Item", ... }
  }
  ```

- **update**: Existing record modified
  ```json
  {
    "action": "update",
    "record": { "id": "existing_id", "name": "Updated Name", ... }
  }
  ```

- **delete**: Record removed
  ```json
  {
    "action": "delete",
    "record": { "id": "deleted_id" }
  }
  ```

### Leave Channel

```typescript
channel.leave();
```

## Available Collections

| Channel | Description | Query Params |
|---------|-------------|--------------|
| `collection:menu` | Menu data (categories, items, customizations) | - |
| `collection:order` | Orders | `from_date`, `customer_id` |
| `collection:status` | System status | - |
| `collection:message` | Display messages | - |
| `collection:category` | Categories only | - |
| `collection:item` | Items only | - |
| `collection:customization_key` | Customization keys | - |
| `collection:customization_value` | Customization values | - |

## Special: Menu Collection

The menu collection returns a hierarchical structure:

```json
{
  "items": {
    "tree": [
      {
        "id": "category1",
        "name": "Coffee",
        "items": [
          {
            "id": "item1",
            "name": "Latte",
            "customizations": [
              {
                "key": { "id": "size", "name": "Size", ... },
                "values": [
                  { "id": "small", "name": "Small", ... },
                  { "id": "large", "name": "Large", ... }
                ]
              }
            ]
          }
        ]
      }
    ],
    "indexes": {
      "categories": [...],
      "items": [...],
      "customization_keys": [...],
      "customization_values": [...]
    }
  }
}
```

On update, the **entire menu** is re-broadcast (not just the changed record).

## Custom Channels

### Notifications Channel

```
notifications:{scope}
```

Example:
```typescript
const channel = socket.channel("notifications:admin");

channel.on("new_order", (payload) => {
  console.log("New order!", payload);
  // payload = { order_id, day_id, message, timestamp }
});
```

## Connection Management

### Check Connection State

```typescript
socket.isConnected()  // boolean
```

### Reconnection

Phoenix Socket handles reconnection automatically with exponential backoff.

### Disconnect

```typescript
socket.disconnect();
```

## Error Handling

```typescript
channel.on("error", (err) => {
  console.error("Channel error", err);
});

socket.onError(() => {
  console.error("Socket error");
});

socket.onClose(() => {
  console.log("Socket closed");
});
```

## Best Practices

- **Reuse socket instance**: One socket per app
- **Leave channels when done**: Prevent memory leaks
- **Handle reconnection**: UI should recover gracefully
- **Throttle updates**: Batch rapid changes on frontend

## Example: Full Integration

```typescript
import { writable } from "svelte/store";
import { Socket } from "phoenix";

const socket = new Socket("ws://localhost:4000/socket");
socket.connect();

const { subscribe, set, update } = writable([]);
const channel = socket.channel("collection:order");

channel
  .join()
  .receive("ok", (response) => set(response.items));

channel.on("change", (event) => {
  if (event.action === "create") {
    update((items) => [...items, event.record]);
  } else if (event.action === "update") {
    update((items) =>
      items.map((i) => (i.id === event.record.id ? event.record : i))
    );
  } else if (event.action === "delete") {
    update((items) => items.filter((i) => i.id !== event.record.id));
  }
});

export const orders = { subscribe };
```

## Next Steps

- [Stores Reference](/dev/reference/stores) - Frontend store patterns
- [Real-time Architecture](/dev/concepts/realtime-architecture) - System design
- [Add WebSocket Subscription](/dev/how-to/add-websocket-subscription) - Implementation guide
