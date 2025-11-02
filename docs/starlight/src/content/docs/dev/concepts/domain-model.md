---
title: Domain Model
description: Understanding the business entities and their relationships in Kaffediem, including menu structure, orders, and snapshots.
---

## Entity Overview

```
Menu Domain:
  Category
    ↓ has many
  Item
    ↓ references
  CustomizationKey ← linked via valid_customizations
    ↓ has many
  CustomizationValue

Order Domain:
  User (Customer)
    ↓ places
  Order
    ↓ contains (snapshot)
  OrderItem
    ↓ has
  OrderItemCustomization

Content Domain:
  Message
  Status
```

## Core Entities

### Category

A grouping for menu items (e.g., "Coffee", "Tea", "Pastries").

**Key characteristics:**
- Has many Items
- Defines which CustomizationKeys are valid for its items
- Controls ordering via `sort_order`
- Can be enabled/disabled

**Example:**
```
Category: "Coffee"
├── valid_customizations: ["size_key_id", "milk_key_id"]
├── Items: Latte, Espresso, Cappuccino
└── enable: true
```

### Item

A product that can be ordered.

**Key characteristics:**
- Belongs to exactly one Category
- Has a base price in NOK (Norwegian Kroner)
- Can have an image
- Inherits valid customizations from its category

**Example:**
```
Item: "Latte"
├── price_nok: 45
├── category: "coffee_id"
├── image: "/images/latte.jpg"
└── enable: true
```

### CustomizationKey

A dimension of customization (e.g., "Size", "Milk Type").

**Key characteristics:**
- Has many CustomizationValues
- Can allow single or multiple selections (`multiple_choice`)
- Can have a default value
- Has optional label color for UI

**Example:**
```
CustomizationKey: "Size"
├── multiple_choice: false (only one size)
├── default_value: "medium_id"
└── Values: Small, Medium, Large
```

### CustomizationValue

A specific option within a customization dimension.

**Key characteristics:**
- Belongs to exactly one CustomizationKey
- Has a price modifier (additive or multiplicative)
- `constant_price` determines modifier type:
  - `true`: Additive (+10 kr)
  - `false`: Multiplicative (×1.20, stored as 120)

**Example:**
```
CustomizationValue: "Large"
├── belongs_to: "size_key_id"
├── price_increment_nok: 120  (×1.20)
└── constant_price: false  (multiplicative)
```

### Order

A customer's purchase.

**Key characteristics:**
- Has a state machine: received → production → completed → dispatched
- Has a daily sequential ID (`day_id`) starting at 100
- Contains **denormalized snapshots** of items and customizations
- Optionally linked to a customer (can be anonymous)

**State Machine:**
```
received -----> production -----> completed -----> dispatched
  (new)         (preparing)       (ready)         (picked up)
```

**Example:**
```
Order #102
├── customer_id: 42
├── day_id: 102
├── state: "production"
├── items: [snapshot of Latte with Medium size]
└── inserted_at: 2025-01-15T10:30:00Z
```

### OrderItem (Snapshot)

A denormalized copy of an item at order time.

**Why snapshot?** Menu items can be renamed, repriced, or deleted. Orders must preserve what was actually ordered and charged.

**Contains:**
- `item_id`: Reference to original item
- `name`: Snapshot of item name
- `price`: Snapshot of base price
- `category`: Snapshot of category ID
- `customizations`: Array of customization snapshots

**Example:**
```json
{
  "item_id": "latte_id",
  "name": "Latte",
  "price": 45.0,
  "category": "coffee_id",
  "customizations": [...]
}
```

### OrderItemCustomization (Snapshot)

A denormalized copy of a customization at order time.

**Contains:**
- `key_id`, `key_name`: Customization dimension
- `value_id`, `value_name`: Selected option
- `price_change`: Price modifier at time of order

**Example:**
```json
{
  "key_id": "milk_id",
  "key_name": "Milk Type",
  "value_id": "oat_id",
  "value_name": "Oat Milk",
  "price_change": 5
}
```

### User

A customer or staff member.

**Key characteristics:**
- Can be customer (`is_admin: false`) or staff (`is_admin: true`)
- Has authentication credentials
- Orders optionally link to users

### Message

Display content for public screens.

**Key characteristics:**
- Has title and optional subtitle
- Used on display screens during events or closures

### Status

System operational status.

**Key characteristics:**
- Indicates if ordering is open/closed
- Can show a custom message
- Controls frontend behavior

## Relationships

### Direct References

```
Item ----belongsTo----> Category
CustomizationValue ----belongsTo----> CustomizationKey
Order ----belongsTo----> User (optional)
```

### Indirect References (via JSON)

```
Category.valid_customizations ---references---> [CustomizationKey IDs]
CustomizationKey.default_value ---references---> CustomizationValue ID
```

### Snapshot References

```
OrderItem.item_id ---references---> Item
OrderItemCustomization.key_id ---references---> CustomizationKey
OrderItemCustomization.value_id ---references---> CustomizationValue
```

But these are **informational only**. Deleting the original item doesn't affect the order.

## Lifecycle

### Menu Setup

1. Create Categories
2. Create Items, assign to categories
3. Create CustomizationKeys
4. Create CustomizationValues, link to keys
5. Update Categories with valid_customizations

### Order Placement

1. Customer builds cart (client-side)
2. Client sends order request with item IDs and customization selections
3. Backend resolves IDs to current catalog data
4. Backend creates **denormalized snapshots**
5. Backend generates `day_id`
6. Order saved with state = "received"
7. Backend broadcasts order to all clients

### Order Fulfillment

1. Staff sees order in "received" column
2. Staff moves to "production"
3. When ready, staff moves to "completed"
4. Customer picks up order
5. Staff moves to "dispatched"

Each state transition broadcasts update to all clients.

## Invariants

### Menu

- An Item must belong to a Category
- A CustomizationValue must belong to a CustomizationKey
- A Category's valid_customizations must reference existing keys
- A CustomizationKey's default_value must be one of its values

### Orders

- Order state must be one of the 4 valid states
- day_id must be unique within a day, >= 100
- items array must have at least 1 item
- Snapshot data is immutable after creation

## Design Decisions

### Why No Foreign Key Constraints?

Denormalization strategy. Orders preserve historical snapshots even if menu items are deleted.

### Why String IDs for Domain Entities?

- Easier to reference in frontend
- Avoid integer collision across entities
- Compatible with distributed systems

### Why daily day_id Reset?

- Keeps order numbers manageable (100-199 per day)
- Easy visual identification of today's orders
- Reduces cognitive load for staff

### Why Denormalize Orders?

- **Immutability**: What was ordered stays accurate
- **Historical accuracy**: Price changes don't affect past orders
- **Independence**: Menu can be freely modified without breaking orders
- **Reporting**: All order data self-contained

## Next Steps

- [Order Lifecycle](/dev/concepts/order-lifecycle) - State machine deep dive
- [Pricing System](/dev/concepts/pricing-system) - How prices are calculated
- [Denormalization Strategy](/dev/concepts/denormalization-strategy) - Why snapshots matter
