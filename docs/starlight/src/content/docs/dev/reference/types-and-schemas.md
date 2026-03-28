---
title: Types and Schemas Reference
description: Complete reference for data types and schemas across frontend TypeScript and backend Elixir, including validation rules and custom types.
---

## Frontend Types (TypeScript)

**File:** `src/lib/types.ts`

### Order

```typescript
type OrderState = "received" | "production" | "completed" | "dispatched";

type Order = {
  id: string;
  customer_id: number | null;
  day_id: number;
  state: OrderState;
  missing_information: boolean;
  items: OrderItem[];
  created?: string;
  updated?: string;
};
```

### OrderItem (Snapshot)

```typescript
type OrderItem = {
  item_id: string;
  name: string;
  price: number;
  category: string;
  customizations: OrderItemCustomization[];
};

type OrderItemCustomization = {
  key_id: string;
  key_name: string;
  value_id: string;
  value_name: string;
  price_change: number;
  label_color?: string | null;
};
```

### Category

```typescript
type Category = {
  id: string;
  name: string;
  sort_order: number;
  enable: boolean;
  valid_customizations: string[];  // Array of CustomizationKey IDs
  created?: string;
  updated?: string;
};
```

### Item

```typescript
type Item = {
  id: string;
  name: string;
  price_nok: number;
  category: string;  // Category ID
  image: string | null;
  enable: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
  imageFile?: File | null;  // For uploads
};
```

### CustomizationKey

```typescript
type CustomizationKey = {
  id: string;
  name: string;
  enable: boolean;
  label_color: string | null;
  default_value: string | null;  // CustomizationValue ID
  multiple_choice: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
};
```

### CustomizationValue

```typescript
type CustomizationValue = {
  id: string;
  name: string;
  price_increment_nok: number;
  constant_price: boolean;  // true = additive, false = multiplicative
  belongs_to: string;  // CustomizationKey ID
  enable: boolean;
  sort_order: number;
  created?: string;
  updated?: string;
};
```

### Message & Status

```typescript
type Message = {
  id: string;
  title: string;
  subtitle: string | null;
  created?: string;
  updated?: string;
};

type Status = {
  id: string;
  open: boolean;
  show_message: boolean;
  message: string | null;
  created?: string;
  updated?: string;
};
```

### User

```typescript
type User = {
  id: string;
  name: string;
  isAdmin: boolean;
};
```

## Backend Schemas (Elixir)

### Order Schema

**File:** `kaffebase/lib/kaffebase/orders/order.ex`

```elixir
schema "order" do
  field :customer_id, :integer
  field :day_id, :integer
  field :items, JsonbItems, source: :items_data  # Custom Ecto type
  field :missing_information, :boolean
  field :state, Ecto.Enum, values: [:received, :production, :completed, :dispatched]
  timestamps()
end
```

### Category Schema

**File:** `kaffebase/lib/kaffebase/catalog/category.ex`

```elixir
schema "category" do
  field :name, :string
  field :sort_order, :integer
  field :enable, :boolean
  field :valid_customizations, :text  # JSON array
  timestamps()
end
```

### Item Schema

**File:** `kaffebase/lib/kaffebase/catalog/item.ex`

```elixir
schema "item" do
  field :category, :string
  field :enable, :boolean
  field :image, :string
  field :name, :string
  field :price_nok, :decimal
  field :sort_order, :integer
  timestamps()
end
```

### CustomizationKey Schema

**File:** `kaffebase/lib/kaffebase/catalog/customization_key.ex`

```elixir
schema "customization_key" do
  field :name, :string
  field :enable, :boolean
  field :label_color, :string
  field :default_value, :string
  field :multiple_choice, :boolean
  field :sort_order, :integer
  timestamps()
end
```

### CustomizationValue Schema

**File:** `kaffebase/lib/kaffebase/catalog/customization_value.ex`

```elixir
schema "customization_value" do
  field :name, :string
  field :price_increment_nok, :decimal
  field :constant_price, :boolean
  field :belongs_to, :string
  field :enable, :boolean
  field :sort_order, :integer
  timestamps()
end
```

### User Schema

**File:** `kaffebase/lib/kaffebase/accounts/user.ex`

```elixir
schema "users" do
  field :email, :string
  field :hashed_password, :string
  field :confirmed_at, :utc_datetime
  field :name, :string
  field :username, :string
  field :is_admin, :boolean, default: false
  timestamps()
end
```

## Custom Ecto Types

### JsonbItems

**File:** `kaffebase/lib/kaffebase/ecto_types/jsonb_items.ex`

Stores order items as JSON in SQLite TEXT field.

```elixir
defmodule Kaffebase.EctoTypes.JsonbItems do
  use Ecto.Type

  def type, do: :text

  def cast(items) when is_list(items), do: {:ok, items}
  def cast(_), do: :error

  def load(json_string) when is_binary(json_string) do
    case Jason.decode(json_string) do
      {:ok, items} -> {:ok, items}
      _ -> {:ok, []}
    end
  end

  def dump(items) when is_list(items) do
    {:ok, Jason.encode!(items)}
  end
end
```

## Validation Rules

### Order

- `state`: Must be one of: received, production, completed, dispatched
- `items`: At least 1 item required
- `day_id`: Auto-generated, >= 100

### Item

- `name`: Required
- `price_nok`: Required, must be >= 0
- `category`: Required, must reference existing category

### CustomizationKey

- `name`: Required
- `multiple_choice`: Defaults to false

### CustomizationValue

- `name`: Required
- `belongs_to`: Required, must reference existing key
- `price_increment_nok`: Defaults to 0

## ID Generation

All domain entities use string IDs generated by nanoid:

```elixir
# kaffebase/lib/kaffebase/ids.ex
Kaffebase.Ids.generate()
# => "v7nrm2kp3bgd5f8c"
```

## Timestamps

All entities have:
- `inserted_at`: When record was created (UTC)
- `updated_at`: When record was last modified (UTC)

Frontend maps these to `created` and `updated`.

## Next Steps

- [API Endpoints](/dev/reference/api-endpoints) - REST API reference
- [Database Schema](/dev/reference/database-schema) - Table structures
- [Domain Model](/dev/concepts/domain-model) - Entity relationships
