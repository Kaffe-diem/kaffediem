---
title: Stores Reference
description: Svelte stores used in Kaffediem for state management and real-time synchronization, including collection patterns and CRUD helpers.
---

## Core Pattern: Collection Stores

Most stores use the `createCollection` pattern for real-time data synchronization.

### createCollection

```typescript
createCollection<ApiType, DomainType>(
  collectionName: string,
  fromApi: (data: ApiType) => DomainType,
  options?: {
    queryParams?: Record<string, string>;
    onCreate?: (item: DomainType) => void;
  }
): Writable<DomainType[]> & { destroy: () => void }
```

**Example:**
```typescript
const orders = createCollection<ApiOrder, Order>(
  "order",
  (data) => ({ ...data, created: data.inserted_at }),
  { onCreate: (order) => playSound() }
);
```

## Available Stores

### menu

**File:** `src/lib/stores/menu.ts`

```typescript
import { menu, menuTree, menuIndexes } from "$lib/stores/menu";

// Full menu with tree and indexes
$menu.tree          // Hierarchical structure
$menu.indexes       // Flat indexes for lookups

// Derived stores
$menuTree           // Just the tree
$menuIndexes        // Just the indexes
```

**Structure:**
```typescript
type MenuPayload = {
  tree: MenuCategory[];  // Nested: Category → Items → Customizations
  indexes: {
    categories: Category[];
    items: Item[];
    items_by_category: Record<string, Item[]>;
    customization_keys: CustomizationKey[];
    customization_values: CustomizationValue[];
    customizations_by_key: Record<string, CustomizationValue[]>;
  };
};
```

**CRUD Operations:**
```typescript
import {
  createCategory, updateCategory, deleteCategory,
  createItem, updateItem, deleteItem,
  createCustomizationKey, updateCustomizationKey, deleteCustomizationKey,
  createCustomizationValue, updateCustomizationValue, deleteCustomizationValue
} from "$lib/stores/menu";

await createItem({ name: "Latte", price_nok: 45, ... });
await updateItem({ id: "item1", name: "New Name", ... });
await deleteItem("item1");
```

### orders

**File:** `src/lib/stores/orders.ts`

```typescript
import { orders } from "$lib/stores/orders";

$orders  // Order[]
```

Filter with derived stores:
```typescript
const receivedOrders = derived(orders, $orders =>
  $orders.filter(o => o.state === "received")
);
```

### cart

**File:** `src/lib/stores/cart.ts`

**Special**: Not synchronized, local only.

```typescript
import {
  cart,
  selectedItemId,
  selectedItem,
  selectedCategory,
  selectedCustomizations,
  totalPrice,
  editingIndex,
  addToCart,
  removeFromCart,
  clearCart,
  toggleCustomization,
  startEditing,
  stopEditing,
  deleteEditingItem
} from "$lib/stores/cart";

// Read state
$cart              // CartItem[]
$totalPrice        // number
$editingIndex      // number | null

// Modify cart
addToCart(item);
removeFromCart(index);
clearCart();

// Customizations
toggleCustomization(key, value);
startEditing(index);
stopEditing();
```

**CartItem:**
```typescript
interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice: number;
  totalPrice: number;  // Calculated
}
```

### auth

**File:** `src/lib/stores/auth.ts`

```typescript
import { user, login, logout } from "$lib/stores/auth";

$user  // User | null

await login(email, password);
await logout();
```

### status

**File:** `src/lib/stores/status.ts`

```typescript
import { status } from "$lib/stores/status";

$status  // Status[]
```

### toastStore

**File:** `src/lib/stores/toastStore.ts`

```typescript
import { toasts, addToast, removeToast } from "$lib/stores/toastStore";

addToast({
  type: "success" | "error" | "info",
  message: "Operation completed",
  duration: 3000  // ms
});
```

## CRUD Helpers

### createCrudOperations

```typescript
const { create, update, delete: deleteEntity } = createCrudOperations<Entity>(
  "entity_name",
  { toApi: (entity) => transform(entity) }  // Optional transform
);

await create(entity);
await update(entity);
await deleteEntity(entity.id);
```

## Store Lifecycle

### Cleanup

For dynamically created stores:

```typescript
import { onDestroy } from "svelte";

const myStore = createCollection("data", fromApi);

onDestroy(() => {
  myStore.destroy();  // Leaves channel, prevents memory leak
});
```

Global stores (menu, orders, etc.) don't need cleanup.

## Advanced Patterns

### Filtered Collections

```typescript
const todayOrders = createCollection(
  "order",
  fromApi,
  { queryParams: { from_date: new Date().toISOString() } }
);
```

### Derived Stores

```typescript
const completedOrders = derived(orders, $orders =>
  $orders.filter(o => o.state === "completed")
);

const orderCount = derived(orders, $orders => $orders.length);
```

### Multiple Subscriptions

```typescript
const unsubscribe1 = orders.subscribe(value => {
  console.log("Orders changed", value);
});

const unsubscribe2 = orders.subscribe(value => {
  updateUI(value);
});

// Later
unsubscribe1();
unsubscribe2();
```

### Custom Stores

```typescript
function createCustomStore() {
  const { subscribe, set, update } = writable(initialValue);

  return {
    subscribe,
    increment: () => update(n => n + 1),
    reset: () => set(0)
  };
}

const counter = createCustomStore();
```

## Best Practices

- **Use derived stores** for filtering/transforming data
- **Don't mutate store values** directly, use `update()`
- **Clean up dynamic stores** in `onDestroy`
- **Batch updates** when possible
- **Keep stores focused** - one concern per store

## Troubleshooting

### Store Not Updating

Check:
1. WebSocket connection active
2. Backend broadcasting changes
3. No JavaScript errors
4. Store is subscribed ($store syntax or .subscribe())

### Memory Leaks

Check:
1. Calling `.destroy()` on dynamic stores
2. Not creating stores in reactive statements
3. Unsubscribing manual subscriptions

## Next Steps

- [WebSocket Channels](/dev/reference/websocket-channels) - Real-time protocols
- [Types and Schemas](/dev/reference/types-and-schemas) - Data structures
- [Add WebSocket Subscription](/dev/how-to/add-websocket-subscription) - Create new stores
