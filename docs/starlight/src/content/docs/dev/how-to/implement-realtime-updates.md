---
title: Implement Real-time Updates
description: Implement a complete real-time feature from backend to frontend, including Phoenix Channels, WebSocket broadcasting, and Svelte stores.
---

## Goal

Add a "notifications" feature where admin users see real-time alerts when new orders are placed.

## Step 1: Backend - Add Notification Context

Create `kaffebase/lib/kaffebase/notifications.ex`:

```elixir
defmodule Kaffebase.Notifications do
  @moduledoc """
  Context for managing system notifications.
  """

  def broadcast_order_notification(order) do
    message = "New order ##{order.day_id} received"

    KaffebaseWeb.Endpoint.broadcast("notifications:admin", "new_order", %{
      order_id: order.id,
      day_id: order.day_id,
      message: message,
      timestamp: DateTime.utc_now()
    })
  end
end
```

## Step 2: Trigger Notification on Order Creation

Edit `kaffebase_web/controllers/order_controller.ex`:

```elixir
def create(conn, params) do
  with {:ok, order} <- Orders.create_order(params) do
    CollectionChannel.broadcast_change("order", "create", order)

    # ← Add this line
    Kaffebase.Notifications.broadcast_order_notification(order)

    conn
    |> put_status(:created)
    |> render(:show, order: order)
  end
end
```

## Step 3: Create Notifications Channel

Create `kaffebase_web/channels/notifications_channel.ex`:

```elixir
defmodule KaffebaseWeb.NotificationsChannel do
  use Phoenix.Channel
  require Logger

  @impl true
  def join("notifications:" <> scope, _payload, socket) do
    Logger.info("Client joining notifications:#{scope}")
    {:ok, socket}
  end

  @impl true
  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end
end
```

Add to `kaffebase_web/channels/user_socket.ex`:

```elixir
channel "notifications:*", KaffebaseWeb.NotificationsChannel
```

## Step 4: Frontend - Create Notifications Store

Create `src/lib/stores/notifications.ts`:

```typescript
import { writable } from "svelte/store";
import { getSocket } from "$lib/realtime/socket";
import type { Channel } from "phoenix";

export type Notification = {
  id: string;
  order_id: string;
  day_id: number;
  message: string;
  timestamp: string;
  read: boolean;
};

function createNotificationStore() {
  const { subscribe, update } = writable<Notification[]>([]);
  let channel: Channel | null = null;

  function connect(scope: string = "admin") {
    const socket = getSocket();
    if (!socket) return;

    channel = socket.channel(`notifications:${scope}`);

    channel
      .join()
      .receive("ok", () => console.log("Joined notifications"))
      .receive("error", (err) => console.error("Failed to join", err));

    channel.on("new_order", (payload: any) => {
      const notification: Notification = {
        id: crypto.randomUUID(),
        order_id: payload.order_id,
        day_id: payload.day_id,
        message: payload.message,
        timestamp: payload.timestamp,
        read: false
      };

      update((notifications) => [notification, ...notifications]);

      // Play sound or show browser notification
      if (Notification.permission === "granted") {
        new Notification("New Order", { body: payload.message });
      }
    });
  }

  function markRead(id: string) {
    update((notifications) =>
      notifications.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
  }

  function clearAll() {
    update(() => []);
  }

  function disconnect() {
    channel?.leave();
    channel = null;
  }

  return {
    subscribe,
    connect,
    markRead,
    clearAll,
    disconnect
  };
}

export const notifications = createNotificationStore();
```

## Step 5: Create Notification UI Component

Create `src/lib/components/NotificationBell.svelte`:

```svelte
<script lang="ts">
  import { notifications } from "$lib/stores/notifications";
  import { onMount, onDestroy } from "svelte";

  let showDropdown = false;

  onMount(() => {
    notifications.connect("admin");

    // Request browser notification permission
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission();
    }
  });

  onDestroy(() => {
    notifications.disconnect();
  });

  $: unreadCount = $notifications.filter((n) => !n.read).length;
</script>

<div class="relative">
  <button
    class="btn btn-circle btn-ghost relative"
    on:click={() => (showDropdown = !showDropdown)}
  >
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="h-6 w-6"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
      />
    </svg>

    {#if unreadCount > 0}
      <span class="absolute top-0 right-0 badge badge-primary badge-sm">
        {unreadCount}
      </span>
    {/if}
  </button>

  {#if showDropdown}
    <div class="absolute right-0 mt-2 w-80 bg-base-200 rounded-lg shadow-lg p-4 z-50">
      <div class="flex justify-between items-center mb-2">
        <h3 class="font-bold">Notifications</h3>
        <button class="btn btn-xs" on:click={() => notifications.clearAll()}>
          Clear All
        </button>
      </div>

      <div class="space-y-2 max-h-96 overflow-auto">
        {#each $notifications as notification}
          <div
            class="p-2 rounded"
            class:bg-primary={!notification.read}
            class:bg-base-300={notification.read}
          >
            <p class="text-sm">{notification.message}</p>
            <p class="text-xs opacity-70">
              {new Date(notification.timestamp).toLocaleTimeString()}
            </p>
            {#if !notification.read}
              <button
                class="btn btn-xs mt-1"
                on:click={() => notifications.markRead(notification.id)}
              >
                Mark Read
              </button>
            {/if}
          </div>
        {:else}
          <p class="text-sm text-center opacity-70">No notifications</p>
        {/each}
      </div>
    </div>
  {/if}
</div>
```

## Step 6: Add to Layout

Edit `src/routes/admin/+layout.svelte`:

```svelte
<script lang="ts">
  import NotificationBell from "$lib/components/NotificationBell.svelte";
</script>

<div class="navbar bg-base-300">
  <div class="flex-1">
    <h1 class="text-xl font-bold">Admin Panel</h1>
  </div>
  <div class="flex-none">
    <NotificationBell />
  </div>
</div>

<slot />
```

## Step 7: Test the Feature

1. Open http://localhost:5173/admin in one tab
2. Open http://localhost:5173/admin/orders/frontdesk in another
3. Create a new order in the frontdesk
4. Watch the notification bell in the admin tab light up
5. Click the bell to see the notification

## Advanced: Persist Notifications

If you want notifications to persist across sessions:

### Add Database Storage

```bash
cd kaffebase
mix ecto.gen.migration create_notifications
```

```elixir
defmodule Kaffebase.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :string, primary_key: true
      add :user_id, :string
      add :type, :string, null: false
      add :message, :text, null: false
      add :data, :text  # JSON
      add :read, :boolean, default: false
      timestamps(type: :utc_datetime_usec)
    end

    create index(:notifications, [:user_id, :read])
  end
end
```

### Load on Connect

```typescript
notifications.connect("admin");

// Load unread notifications from API
const response = await fetch("/api/notifications?read=false");
const data = await response.json();
// Populate store...
```

## Checklist

- ✅ Backend broadcast implemented
- ✅ Phoenix Channel created and registered
- ✅ Frontend store subscribes to channel
- ✅ UI component created
- ✅ Browser notifications requested (optional)
- ✅ Tested across multiple tabs
- ✅ Cleanup on component unmount

## Next Steps

- [Add WebSocket Subscription](/dev/how-to/add-websocket-subscription) - Core patterns
- [WebSocket Channels](/dev/reference/websocket-channels) - Channel protocols
- [Real-time Architecture](/dev/concepts/realtime-architecture) - System design
