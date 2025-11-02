---
title: Creating Your First Order
description: Walk through the complete lifecycle of an order in Kaffediem, from menu selection to completion, understanding how data flows through the system.
---

## Prerequisites

- Completed the [Getting Started](/dev/tutorials/getting-started) tutorial
- Development environment running (both frontend and backend)
- Basic understanding of the Kaffediem architecture

## What You'll Learn

- How orders progress through the state machine
- How menu items and customizations work together
- How denormalized snapshots preserve order data
- How real-time updates propagate through the system

## Part 1: Understanding the Order State Machine

Orders in Kaffediem follow a 4-state lifecycle:

```
received → production → completed → dispatched
```

- **received**: Order has been placed, waiting to be started
- **production**: Order is being prepared
- **completed**: Order is ready for pickup
- **dispatched**: Order has been given to the customer

## Part 2: Explore the Menu Structure

Before creating an order, let's understand the menu hierarchy.

### Open the Admin Menu Page

1. Navigate to http://localhost:5173/admin/menu
2. You'll see the menu management interface with:
   - **Categories** (e.g., "Coffee", "Tea", "Pastries")
   - **Items** within each category
   - **Customization Keys** (e.g., "Size", "Milk Type")
   - **Customization Values** (e.g., "Small", "Medium", "Large")

### Inspect a Menu Item

Look at how an item is structured:

```typescript
type Item = {
  id: string;
  name: string;
  price_nok: number;    // Base price in Norwegian kroner
  category: string;      // References a Category.id
  image: string | null;
  enable: boolean;
  sort_order: number;
}
```

### Understand Customizations

Customizations are linked to categories, not individual items:

```typescript
type Category = {
  id: string;
  name: string;
  valid_customizations: string[];  // Array of CustomizationKey IDs
}

type CustomizationKey = {
  id: string;
  name: string;               // e.g., "Size"
  default_value: string | null;
  multiple_choice: boolean;    // Can select multiple values?
  label_color: string | null;
}

type CustomizationValue = {
  id: string;
  name: string;                    // e.g., "Large"
  price_increment_nok: number;     // Can be additive or multiplicative
  constant_price: boolean;         // true = additive, false = multiplicative
  belongs_to: string;              // References CustomizationKey.id
}
```

## Part 3: Create an Order via the Frontdesk

### Navigate to the Frontdesk

1. Go to http://localhost:5173/admin/orders/frontdesk
2. This interface has three columns:
   - **Left**: Menu selection (categories and items)
   - **Middle**: Current cart
   - **Right**: Completed orders waiting for pickup

### Add Items to Cart

1. **Select a category** (e.g., "Coffee")
2. **Click an item** (e.g., "Latte")
3. **Choose customizations**:
   - Select a size (e.g., "Medium")
   - Select milk type if available (e.g., "Oat Milk")
4. **Click "Add to Cart"**

### Observe the Cart

In the middle column, you'll see:
- The item name
- Selected customizations
- **Calculated price** (base price + customization modifiers)

The pricing calculation happens in `src/lib/pricing.ts`:

```typescript
finalPrice = (basePrice + additive_customizations) * multiplicative_customizations
```

- **Additive** (constant_price: true): +10 kr
- **Multiplicative** (constant_price: false): ×1.15 (stored as 115)

### Place the Order

1. Click the **"Place Order"** button
2. The order is sent to the backend at `POST /api/collections/order/records`

## Part 4: What Happens on the Backend

Let's trace the order creation flow:

### 1. Controller Receives Request

File: `kaffebase/lib/kaffebase_web/controllers/order_controller.ex`

```elixir
def create(conn, params) do
  # Validates and creates order
end
```

### 2. PlaceOrder Command Builds Snapshot

File: `kaffebase/lib/kaffebase/orders/place_order.ex`

The order creation **doesn't store references** to catalog items. Instead, it creates a **denormalized snapshot**:

```elixir
defp snapshot_item(catalog_item, customization_inputs) do
  %{
    item_id: catalog_item.id,
    name: catalog_item.name,              # ← Copied from catalog
    price: Decimal.to_float(catalog_item.price_nok),
    category: catalog_item.category,
    customizations: build_customizations_snapshot(customization_inputs)
  }
end
```

**Why snapshot?** If you change the menu (e.g., rename "Latte" to "Caffè Latte" or increase the price), existing orders remain unchanged. This is critical for historical accuracy.

### 3. Day ID is Generated

File: `kaffebase/lib/kaffebase/orders/day_id.ex`

Each order gets a `day_id` that:
- Starts at 100 each day
- Increments sequentially (100, 101, 102...)
- Resets the next day

```elixir
def next(repo) do
  # Finds the highest day_id for today
  # Returns last_id + 1 (or 100 if no orders today)
end
```

### 4. Order is Persisted

File: `kaffebase/lib/kaffebase/orders/order.ex`

```elixir
schema "order" do
  field :customer_id, :integer
  field :day_id, :integer
  field :items, JsonbItems        # ← JSONB stored snapshot
  field :state, Ecto.Enum         # ← State machine
  field :missing_information, :boolean
  timestamps()
end
```

The `items` field contains the full snapshot as JSON.

### 5. Broadcast Real-time Update

File: `kaffebase/lib/kaffebase_web/channels/collection_channel.ex`

```elixir
def broadcast_change(collection, action, record) do
  payload = %{
    "action" => action,     # "create"
    "record" => record      # The new order
  }

  KaffebaseWeb.Endpoint.broadcast("collection:order", "change", payload)
end
```

## Part 5: Watch Real-time Updates on the Kitchen Display

### Open the Kitchen View

1. In a **new browser tab**, navigate to http://localhost:5173/admin/orders/kitchen
2. Your new order should appear in the **"Received"** column

### How Does This Work?

File: `src/lib/stores/orders.ts`

The orders store subscribes to the `collection:order` WebSocket channel:

```typescript
export const orders = createCollection<ApiOrder, Order>(
  "order",
  fromApi,
  {
    onCreate: (order) => {
      // Play sound, show notification, etc.
    }
  }
);
```

When the backend broadcasts a "create" event:
1. WebSocket delivers it to all connected clients
2. The `orders` store updates automatically
3. Svelte re-renders components subscribed to `$orders`

## Part 6: Progress the Order Through States

### Move to Production

1. In the kitchen view, find your order in the "Received" column
2. Click the **"Start Production"** button (or equivalent action)
3. The order moves to the **"Production"** column

Behind the scenes:
- Frontend calls `PATCH /api/collections/order/records/:id` with `{ state: "production" }`
- Backend updates the order
- Backend broadcasts the "update" event
- All connected clients (including the frontdesk) see the update

### Mark as Completed

1. Click **"Mark Complete"**
2. The order moves to the **"Completed"** column
3. The frontdesk's right column now shows this order as ready for pickup

### Dispatch the Order

1. Back on the frontdesk view, find the completed order
2. Click **"Dispatch"** to mark it as given to the customer
3. The order state becomes "dispatched"

## Part 7: Inspect the Database

Let's look at how the order is stored.

### Query the Database

```bash
cd kaffebase
sqlite3 priv/repo/dev.db
```

```sql
-- View your order
SELECT id, day_id, state, items_data
FROM "order"
ORDER BY inserted_at DESC
LIMIT 1;

-- See the snapshot structure
SELECT json_extract(items_data, '$') as items
FROM "order"
ORDER BY inserted_at DESC
LIMIT 1;
```

You'll see the `items_data` field contains the full snapshot:

```json
[
  {
    "item_id": "abc123",
    "name": "Latte",
    "price": 45.0,
    "category": "coffee_id",
    "customizations": [
      {
        "key_id": "size_id",
        "key_name": "Size",
        "value_id": "medium_id",
        "value_name": "Medium",
        "price_change": 0
      }
    ]
  }
]
```

### Test Snapshot Immutability

1. Go back to http://localhost:5173/admin/menu
2. **Edit the Latte**: Change its name to "Caffè Latte" or increase the price
3. **Query the database again**:

```sql
SELECT items_data FROM "order" WHERE id = 'your_order_id';
```

Notice: The order still shows the **original** name and price. This is denormalization at work!

## Part 8: Explore with Browser DevTools

### Watch WebSocket Traffic

1. Open DevTools (F12)
2. Go to the **Network** tab
3. Filter by **WS** (WebSocket)
4. Click the WebSocket connection
5. Go to the **Messages** tab
6. Create another order and watch the messages:

```json
{
  "event": "change",
  "topic": "collection:order",
  "payload": {
    "action": "create",
    "record": { /* order data */ }
  }
}
```

### Inspect the Orders Store

In the **Console** tab:

```javascript
// Access the orders store (if exposed or in component)
// You'll see it's a Svelte writable store with subscribe/update methods
```

## Part 9: Understanding the Cart

The cart is a special store that doesn't map directly to a database table.

File: `src/lib/stores/cart.ts`

```typescript
export interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice: number;
  totalPrice: number;  // ← Calculated on the fly
}

export const cart = writable<CartItem[]>([]);
```

The cart:
- Lives only in browser memory
- Calculates prices dynamically as customizations change
- Transforms into the order payload when "Place Order" is clicked

## Key Takeaways

You now understand:

- ✅ Orders progress through a 4-state machine
- ✅ Menu hierarchy: Category → Item, CustomizationKey → CustomizationValue
- ✅ Orders snapshot item data (denormalization)
- ✅ Day IDs provide sequential numbering per day
- ✅ Real-time updates use Phoenix Channels + Svelte stores
- ✅ The cart is a local-only store for building orders

## Next Steps

- **[Customizing the Menu](/dev/tutorials/customizing-menu)** - Learn menu management
- **[Order Lifecycle](/dev/concepts/order-lifecycle)** - Deep dive into states
- **[Pricing System](/dev/concepts/pricing-system)** - Understand price calculations
- **[Denormalization Strategy](/dev/concepts/denormalization-strategy)** - Why snapshots matter

## Exercises

1. **Create a custom order**: Try ordering multiple items with different customizations
2. **Test state transitions**: Move an order through all states and observe updates
3. **Modify a menu item**: Change an item's price and verify existing orders are unchanged
4. **Break the WebSocket**: Stop the backend and observe frontend behavior
5. **Inspect the PlaceOrder code**: Read through `kaffebase/lib/kaffebase/orders/place_order.ex`
