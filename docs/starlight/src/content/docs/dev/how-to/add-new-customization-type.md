---
title: Add New Customization Type
description: Extend the menu customization system with a new type of customization in Kaffediem, such as temperature or special dietary options.
---

## Example: Add "Temperature" Customization

We'll add a temperature option (Hot/Iced) for beverages.

## Step 1: Create the Customization Key via Admin UI

1. Go to http://localhost:5173/admin/menu
2. Find the "Customization Keys" section
3. Click "Add Customization Key"
4. Fill in:
   - **Name**: "Temperature"
   - **Multiple Choice**: ☐ (single selection)
   - **Default Value**: (leave empty, we'll set after creating values)
   - **Label Color**: `#ef4444` (red for hot, optional)
   - **Enable**: ✓
   - **Sort Order**: 2
5. Save and note the generated ID

## Step 2: Create Customization Values

Add two values for the key:

### "Hot" Value

- **Name**: "Hot"
- **Belongs To**: Select "Temperature"
- **Price Increment (NOK)**: 0
- **Constant Price**: ✓ (no price change)
- **Enable**: ✓
- **Sort Order**: 1

### "Iced" Value

- **Name**: "Iced"
- **Belongs To**: Select "Temperature"
- **Price Increment (NOK)**: 5
- **Constant Price**: ✓ (adds 5 kr)
- **Enable**: ✓
- **Sort Order**: 2

## Step 3: Set Default Value

1. Edit the "Temperature" key
2. Set **Default Value**: Select "Hot"
3. Save

Now "Hot" will be auto-selected when a customer picks a beverage.

## Step 4: Link to Categories

### For Coffee

1. Find "Coffee" category
2. Edit it
3. In **Valid Customizations**, check "Temperature"
4. Save

### For Tea

1. Find "Tea" category
2. Edit it
3. Check "Temperature" in **Valid Customizations**
4. Save

## Step 5: Test

1. Go to http://localhost:5173/admin/orders/frontdesk
2. Select a coffee item
3. You should see "Temperature" options with "Hot" pre-selected
4. Select "Iced" - price increases by 5 kr
5. Add to cart and place order

## Verify the Snapshot

```bash
cd kaffebase
sqlite3 priv/repo/dev.db
```

```sql
SELECT json_pretty(items_data) FROM "order" ORDER BY inserted_at DESC LIMIT 1;
```

You'll see temperature captured in customizations:

```json
{
  "customizations": [
    {
      "key_id": "temperature_id",
      "key_name": "Temperature",
      "value_id": "iced_id",
      "value_name": "Iced",
      "price_change": 5
    }
  ]
}
```

## Advanced: Programmatic Creation

If you need to create customizations via code or seed data:

### Backend Seed Script

Edit `kaffebase/priv/repo/seeds.exs`:

```elixir
alias Kaffebase.Catalog

# Create key
{:ok, temp_key} = Catalog.create_customization_key(%{
  name: "Temperature",
  multiple_choice: false,
  label_color: "#ef4444",
  enable: true,
  sort_order: 2
})

# Create values
{:ok, hot} = Catalog.create_customization_value(%{
  name: "Hot",
  belongs_to: temp_key.id,
  price_increment_nok: 0,
  constant_price: true,
  enable: true,
  sort_order: 1
})

{:ok, iced} = Catalog.create_customization_value(%{
  name: "Iced",
  belongs_to: temp_key.id,
  price_increment_nok: 5,
  constant_price: true,
  enable: true,
  sort_order: 2
})

# Set default
Catalog.update_customization_key(temp_key.id, %{default_value: hot.id})

# Link to categories
coffee_cat = Catalog.get_category_by_name("Coffee")
Catalog.update_category(coffee_cat.id, %{
  valid_customizations: [temp_key.id | coffee_cat.valid_customizations]
})
```

Run seeds:

```bash
mix run priv/repo/seeds.exs
```

## Common Customization Patterns

### Size (Multiplicative)

```elixir
{:ok, size_key} = Catalog.create_customization_key(%{
  name: "Size",
  multiple_choice: false,
  enable: true
})

# Small = 80% of base price
{:ok, _} = Catalog.create_customization_value(%{
  name: "Small",
  belongs_to: size_key.id,
  price_increment_nok: 80,      # ← 80 = 0.80x
  constant_price: false,         # ← Multiplicative
  enable: true
})

# Large = 120% of base price
{:ok, _} = Catalog.create_customization_value(%{
  name: "Large",
  belongs_to: size_key.id,
  price_increment_nok: 120,     # ← 120 = 1.20x
  constant_price: false,
  enable: true
})
```

### Multiple Extras (Additive)

```elixir
{:ok, extras_key} = Catalog.create_customization_key(%{
  name: "Extras",
  multiple_choice: true,  # ← Allow multiple selections
  enable: true
})

for {name, price} <- [{"Extra Shot", 10}, {"Whipped Cream", 5}] do
  Catalog.create_customization_value(%{
    name: name,
    belongs_to: extras_key.id,
    price_increment_nok: price,
    constant_price: true,  # ← Additive
    enable: true
  })
end
```

### Mutually Exclusive Options

```elixir
{:ok, milk_key} = Catalog.create_customization_key(%{
  name: "Milk Type",
  multiple_choice: false,  # ← Only one selection
  enable: true
})

for {name, price} <- [{"Regular", 0}, {"Oat", 5}, {"Almond", 5}] do
  Catalog.create_customization_value(%{
    name: name,
    belongs_to: milk_key.id,
    price_increment_nok: price,
    constant_price: true,
    enable: true
  })
end
```

## Best Practices

- **Use descriptive names**: "Size" not "S/M/L"
- **Set sensible defaults**: Most common choice
- **Order by frequency**: Popular options first (sort_order)
- **Use colors sparingly**: Only for important distinctions
- **Test pricing**: Verify additive vs multiplicative
- **Link to appropriate categories**: Not all items need all customizations

## Troubleshooting

### Customization Not Appearing

Check:
1. Key is enabled
2. Values are enabled and have `belongs_to` set
3. Category includes key in `valid_customizations`
4. Frontend has reloaded (WebSocket update)

### Wrong Price Calculation

Check:
1. `constant_price` setting (true = additive, false = multiplicative)
2. For multiplicative, value should be whole number (150 = 1.50x)
3. Multiple customizations combine correctly

### Default Not Applied

Check:
1. `default_value` points to valid, enabled value
2. Frontend calls `applyDefaults()` in cart store
3. Value belongs to the key

## Next Steps

- [Customizing the Menu Tutorial](/dev/tutorials/customizing-menu) - Full walkthrough
- [Pricing System](/dev/concepts/pricing-system) - How calculations work
- [Domain Model](/dev/concepts/domain-model) - Entity relationships
