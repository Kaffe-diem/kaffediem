---
title: Denormalization Strategy
description: Learn why Kaffediem stores order data as immutable snapshots instead of foreign key references for historical accuracy and performance.
---

## The Problem

Traditional normalized design:

```
Order
├── customer_id → User
└── OrderItem
    ├── item_id → Item
    └── OrderItemCustomization
        ├── key_id → CustomizationKey
        └── value_id → CustomizationValue
```

**Issues:**
1. **Historical accuracy:** If you rename "Latte" to "Caffè Latte", all past orders show the new name
2. **Price changes:** If you increase the price, past orders show wrong totals
3. **Deleted items:** If you delete an item, orders break
4. **Complex queries:** Need joins across 5+ tables to display an order

## The Solution: Denormalization

Store a **snapshot** of all relevant data at order time:

```json
{
  "id": "order_123",
  "day_id": 102,
  "state": "completed",
  "items": [
    {
      "item_id": "latte_id",          ← Reference (informational)
      "name": "Latte",                ← Snapshot
      "price": 45.0,                  ← Snapshot
      "category": "coffee_id",        ← Snapshot
      "customizations": [
        {
          "key_id": "size_id",        ← Reference (informational)
          "key_name": "Size",         ← Snapshot
          "value_id": "medium_id",    ← Reference (informational)
          "value_name": "Medium",     ← Snapshot
          "price_change": 0           ← Snapshot
        }
      ]
    }
  ]
}
```

## Benefits

### 1. Immutability

Orders never change their content after creation.

**Example:**
```elixir
# Create order - snapshot taken
order = PlaceOrder.new(%{
  items: [%{item: "latte_id", customizations: [...]}]
})
# order.items = [%{name: "Latte", price: 45, ...}]

# Later: Rename item in catalog
Catalog.update_item("latte_id", %{name: "Caffè Latte"})

# Order still shows original name
order.items[0].name  # => "Latte" (unchanged)
```

### 2. Historical Accuracy

Reports reflect what actually happened:

```elixir
# Revenue report for 2024
orders = Orders.list_orders(year: 2024)

total_revenue =
  orders
  |> Enum.flat_map(& &1.items)
  |> Enum.map(& calculate_item_total(&1))
  |> Enum.sum()
```

Uses **actual prices charged**, not current menu prices.

### 3. Independence

Menu can be freely modified without breaking orders:

```elixir
# Delete an unpopular item
Catalog.delete_item("unpopular_id")

# Orders that included it still display correctly
order = Orders.get_order("old_order_id")
order.items[0].name  # => "Unpopular Item" (from snapshot)
```

### 4. Performance

Single query to get complete order:

```elixir
# Normalized: 5+ joins
order = Repo.get(Order, id)
|> Repo.preload([
  :customer,
  order_items: [
    :item,
    order_item_customizations: [:key, :value]
  ]
])

# Denormalized: 1 query
order = Repo.get(Order, id)
# order.items is already complete with all data
```

## Implementation

### PlaceOrder Command

**File:** `kaffebase/lib/kaffebase/orders/place_order.ex`

Transforms IDs into snapshots:

```elixir
defmodule Kaffebase.Orders.PlaceOrder do
  # Input from client
  %{
    items: [
      %{
        item: "latte_id",
        customizations: [
          %{key: "size_id", value: ["medium_id"]}
        ]
      }
    ]
  }

  # Output snapshot
  defp snapshot_item(catalog_item, customization_inputs) do
    %{
      item_id: catalog_item.id,
      name: catalog_item.name,                    ← Copied
      price: Decimal.to_float(catalog_item.price_nok),
      category: catalog_item.category,
      customizations: build_customizations_snapshot(customization_inputs)
    }
  end

  defp snapshot_customization_value(key, value) do
    %{
      key_id: key.id,
      key_name: key.name,                        ← Copied
      value_id: value.id,
      value_name: value.name,                    ← Copied
      price_change: Decimal.to_float(value.price_increment_nok || 0)
    }
  end
end
```

### Storage

Stored as JSONB (SQLite TEXT):

```elixir
schema "order" do
  field :items, JsonbItems, source: :items_data
end
```

Custom Ecto type handles JSON encoding/decoding:

```elixir
defmodule Kaffebase.EctoTypes.JsonbItems do
  def load(json_string), do: {:ok, Jason.decode!(json_string)}
  def dump(items), do: {:ok, Jason.encode!(items)}
end
```

## Tradeoffs

### Advantages ✅

- **Simple queries:** No joins needed
- **Historical accuracy:** Data never changes
- **Fast reads:** Single table access
- **Independence:** Catalog changes don't affect orders
- **Audit trail:** Complete record of transaction

### Disadvantages ❌

- **Storage overhead:** Duplicates names and other data
- **Update complexity:** Can't easily fix typos in old orders
- **No referential integrity:** Can't enforce FK constraints
- **Reporting challenges:** Can't JOIN to get current item details

## When to Use Denormalization

✅ **Good for:**
- **Transactional records:** Orders, invoices, receipts
- **Historical data:** Financial reports, audits
- **Immutable events:** Logs, analytics
- **High read volume:** Caching aggregated data

❌ **Bad for:**
- **Master data:** Users, products (current state matters)
- **Frequently updated data:** Inventory counts
- **Referential integrity required:** Foreign key relationships
- **Low read volume:** Normalization overhead not worth it

## Alternatives Considered

### 1. Fully Normalized

Store only IDs, JOIN to get current data.

**Rejected:** Historical inaccuracy, complexity, performance.

### 2. Hybrid Approach

Store IDs + snapshot, prefer snapshot but allow JOINs.

**Rejected:** Complexity, ambiguity about which to use.

### 3. Event Sourcing

Store every change as an event, replay to get state.

**Rejected:** Overkill for this use case, complex.

### 4. Temporal Tables

Database-native versioning (e.g., PostgreSQL temporal_tables).

**Not available:** SQLite doesn't support temporal tables.

## Best Practices

### Do Snapshot

- Item/product details at order time
- Prices at transaction time
- Configuration/settings that affect billing
- User details for legal records

### Don't Snapshot

- User authentication credentials
- Current inventory levels
- Real-time status (use state fields)
- Data that needs to stay synchronized

### Validation

Validate IDs exist before snapshotting:

```elixir
def item_changeset(schema, attrs) do
  changeset = Item.changeset(schema, attrs)

  case get_field(changeset, :item) do
    nil -> add_error(changeset, :item, "is required")
    item_id ->
      case Crud.get(CatalogItem, item_id) do
        nil -> add_error(changeset, :item, "not found")
        catalog_item -> put_change(changeset, :catalog_item, catalog_item)
      end
  end
end
```

### Corrections

If you need to fix historical data:

```elixir
# Update the snapshot directly (rare!)
order = Orders.get_order(id)

updated_items =
  order.items
  |> Enum.map(fn item ->
    Map.put(item, "name", "Corrected Name")
  end)

Orders.update_order(id, %{items: updated_items})
```

## Migration Strategy

If transitioning from normalized to denormalized:

1. **Add snapshot column** (nullable)
2. **Dual-write:** Write both FK and snapshot
3. **Backfill:** Populate snapshots for old orders
4. **Verify:** Check data consistency
5. **Switch reads:** Use snapshot instead of JOIN
6. **Drop FK column** (optional, keep for reference)

## Next Steps

- [Order Lifecycle](/dev/concepts/order-lifecycle) - How orders are created
- [Domain Model](/dev/concepts/domain-model) - Entity relationships
- [Creating Your First Order](/dev/tutorials/creating-first-order) - See snapshots in action
