---
title: Database Schema Reference
description: Complete database schema for Kaffediem including all tables, relationships, indexes, and query examples for SQLite.
---

## Schema Overview

```
users (authentication)
├── users_tokens
│
catalog (menu)
├── category
├── item
├── customization_key
└── customization_value
│
content (display)
├── message
└── status
│
orders
└── order
```

## Tables

### users

Authentication and user management.

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  hashed_password TEXT,
  confirmed_at DATETIME,
  name TEXT,
  username TEXT UNIQUE,
  is_admin BOOLEAN NOT NULL DEFAULT 0,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE UNIQUE INDEX users_email_index ON users(email);
CREATE UNIQUE INDEX users_username_index ON users(username);
```

### users_tokens

Session and email confirmation tokens.

```sql
CREATE TABLE users_tokens (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token BLOB NOT NULL,
  context TEXT NOT NULL,
  sent_to TEXT,
  inserted_at DATETIME NOT NULL
);

CREATE INDEX users_tokens_user_id_index ON users_tokens(user_id);
CREATE UNIQUE INDEX users_tokens_context_token_index ON users_tokens(context, token);
```

### category

Menu categories (Coffee, Tea, etc.).

```sql
CREATE TABLE category (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  enable BOOLEAN NOT NULL DEFAULT 0,
  valid_customizations TEXT NOT NULL DEFAULT '[]',  -- JSON array
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

**valid_customizations:** JSON array of customization_key IDs:
```json
["key_id_1", "key_id_2"]
```

### item

Menu items.

```sql
CREATE TABLE item (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price_nok DECIMAL NOT NULL,
  category TEXT NOT NULL,  -- References category.id (no FK constraint)
  image TEXT,
  enable BOOLEAN NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE UNIQUE INDEX item_name_index ON item(name);
```

### customization_key

Customization dimensions (Size, Milk Type, etc.).

```sql
CREATE TABLE customization_key (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  enable BOOLEAN NOT NULL DEFAULT 0,
  label_color TEXT,
  default_value TEXT,  -- References customization_value.id
  multiple_choice BOOLEAN NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### customization_value

Specific customization options (Small, Medium, Large).

```sql
CREATE TABLE customization_value (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price_increment_nok DECIMAL NOT NULL DEFAULT 0,
  belongs_to TEXT NOT NULL,  -- References customization_key.id
  enable BOOLEAN NOT NULL DEFAULT 0,
  constant_price BOOLEAN NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### message

Display messages for public screens.

```sql
CREATE TABLE message (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### status

System status (open/closed, etc.).

```sql
CREATE TABLE status (
  id TEXT PRIMARY KEY,
  open BOOLEAN NOT NULL DEFAULT 0,
  show_message BOOLEAN NOT NULL DEFAULT 0,
  message TEXT,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### order

Customer orders with denormalized snapshots.

```sql
CREATE TABLE "order" (
  id TEXT PRIMARY KEY,
  customer_id INTEGER,  -- References users.id (nullable, no FK)
  day_id INTEGER NOT NULL,
  items_data TEXT,  -- JSON snapshot
  state TEXT NOT NULL,  -- 'received' | 'production' | 'completed' | 'dispatched'
  missing_information BOOLEAN NOT NULL DEFAULT 0,
  inserted_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);

CREATE INDEX order_customer_id_index ON "order"(customer_id);
```

**items_data:** JSON array of denormalized order items:
```json
[
  {
    "item_id": "item_123",
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

## Relationships

### Direct References (No FK Constraints)

- `item.category` → `category.id`
- `customization_value.belongs_to` → `customization_key.id`
- `customization_key.default_value` → `customization_value.id`
- `order.customer_id` → `users.id`

### JSON References

- `category.valid_customizations` → array of `customization_key.id`
- `order.items_data` → snapshot with `item_id`, `key_id`, `value_id`

## Indexes

| Table | Index | Purpose |
|-------|-------|---------|
| users | email, username | Unique constraints, login lookups |
| users_tokens | user_id | Token lookups by user |
| users_tokens | context, token | Token validation |
| item | name | Unique constraint |
| order | customer_id | User order history |

## Data Types

### Decimal (price_nok, price_increment_nok)

Stored as TEXT in SQLite, handled as `Decimal` in Elixir.

### Boolean (enable, is_admin, etc.)

Stored as INTEGER (0 = false, 1 = true) in SQLite.

### DateTime (timestamps)

Stored as TEXT in ISO 8601 format with microseconds:
```
2025-01-15T10:30:45.123456Z
```

### JSONB (valid_customizations, items_data)

Stored as TEXT, parsed as JSON by custom Ecto types.

## ID Formats

- **Users**: Auto-increment INTEGER
- **Domain entities**: String nanoid (e.g., "v7nrm2kp3bgd5f8c")

## Constraints

- String IDs are auto-generated if not provided
- `enable` defaults to false for catalog entities
- `sort_order` defaults to 0
- Timestamps auto-managed by Ecto
- No foreign key constraints (denormalized design)

## Migrations

**Main migration:** `priv/repo/migrations/20251020080000_origin.exs`

All tables created with `create_if_not_exists` for idempotency.

## Example Queries

### Get today's orders

```sql
SELECT * FROM "order"
WHERE date(inserted_at) = date('now')
ORDER BY day_id ASC;
```

### Get all enabled items in a category

```sql
SELECT * FROM item
WHERE category = 'coffee_id'
  AND enable = 1
ORDER BY sort_order;
```

### Get customization values for a key

```sql
SELECT * FROM customization_value
WHERE belongs_to = 'size_key_id'
  AND enable = 1
ORDER BY sort_order;
```

### Parse order items

```sql
SELECT id, day_id, json_extract(items_data, '$') as items
FROM "order"
WHERE state = 'received';
```

## Backup & Maintenance

### Backup Database

```bash
sqlite3 priv/repo/dev.db ".backup backup.db"
```

### Vacuum

```bash
sqlite3 priv/repo/dev.db "VACUUM;"
```

### Check Integrity

```bash
sqlite3 priv/repo/dev.db "PRAGMA integrity_check;"
```

## Next Steps

- [Types and Schemas](/dev/reference/types-and-schemas) - Schema definitions
- [Create Database Migration](/dev/how-to/create-database-migration) - Modify schema
- [Domain Model](/dev/concepts/domain-model) - Entity relationships
