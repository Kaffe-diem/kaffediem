---
title: Pricing System
description: Learn how Kaffediem calculates prices for items with customizations using additive and multiplicative modifiers.
---

## Core Formula

**File:** `src/lib/pricing.ts`

```typescript
finalPrice = (basePrice + additive_sum) * multiplicative_product
```

**Rounded up** to nearest krone:

```typescript
return Math.ceil((basePrice + additive) * multiplicative);
```

## Price Components

### Base Price

Set on the Item:

```typescript
type Item = {
  price_nok: number;  // e.g., 45
};
```

### Additive Modifiers

Fixed amounts added to the base price.

**Identified by:** `constant_price: true`

```typescript
type CustomizationValue = {
  price_increment_nok: number;  // e.g., 10 = +10 kr
  constant_price: true;
};
```

**Examples:**
- Extra shot: +10 kr
- Whipped cream: +5 kr
- Protein powder: +15 kr

### Multiplicative Modifiers

Percentages that multiply the price.

**Identified by:** `constant_price: false`

```typescript
type CustomizationValue = {
  price_increment_nok: number;  // e.g., 120 = ×1.20
  constant_price: false;
};
```

**Stored as whole numbers:**
- 80 = ×0.80 (20% discount)
- 100 = ×1.00 (no change)
- 120 = ×1.20 (20% increase)
- 150 = ×1.50 (50% increase)

**Examples:**
- Small size: ×0.80
- Large size: ×1.20
- Extra large: ×1.50

## Calculation Examples

### Example 1: Additive Only

**Item:** Latte, 45 kr
**Customizations:**
- Extra shot: +10 kr (additive)
- Whipped cream: +5 kr (additive)

```typescript
additive = 10 + 5 = 15
multiplicative = 1
finalPrice = ceil((45 + 15) × 1) = ceil(60) = 60 kr
```

### Example 2: Multiplicative Only

**Item:** Latte, 45 kr
**Customizations:**
- Large size: 120 (×1.20)

```typescript
additive = 0
multiplicative = 120 / 100 = 1.20
finalPrice = ceil((45 + 0) × 1.20) = ceil(54) = 54 kr
```

### Example 3: Combined

**Item:** Latte, 45 kr
**Customizations:**
- Large size: 120 (×1.20)
- Extra shot: +10 kr (additive)
- Oat milk: +5 kr (additive)

```typescript
additive = 10 + 5 = 15
multiplicative = 120 / 100 = 1.20

finalPrice = ceil((45 + 15) × 1.20)
           = ceil(60 × 1.20)
           = ceil(72)
           = 72 kr
```

### Example 4: Multiple Multiplicative

**Item:** Smoothie, 50 kr
**Customizations:**
- Large: 120 (×1.20)
- Premium blend: 115 (×1.15)

```typescript
additive = 0
multiplicative = (120 / 100) × (115 / 100) = 1.20 × 1.15 = 1.38

finalPrice = ceil((50 + 0) × 1.38)
           = ceil(69)
           = 69 kr
```

## Implementation

### Frontend (Real-time Calculation)

**File:** `src/lib/pricing.ts`

```typescript
import { sumBy, productBy } from "$lib/utils";

export const finalPrice = (
  basePrice: number,
  customizations: CustomizationValue[]
): number => {
  const additive = sumBy(customizations, (c) =>
    c.constant_price ? c.price_increment_nok || 0 : 0
  );

  const multiplicative = productBy(customizations, (c) =>
    c.constant_price ? 1 : (c.price_increment_nok ?? 100) / 100
  );

  return Math.ceil((basePrice + additive) * multiplicative);
};
```

**Used in cart:**

```typescript
const buildCartItem = (item: Item, customizations: CustomizationValue[]): CartItem => {
  const basePrice = item.price_nok;
  const totalPrice = finalPrice(basePrice, customizations);

  return {
    ...item,
    totalPrice,
    basePrice,
    customizations
  };
};
```

### Backend (Snapshot Verification)

Backend doesn't recalculate prices - it trusts the frontend calculation and stores the snapshot.

However, prices could be recalculated server-side for verification:

```elixir
defmodule Kaffebase.Pricing do
  def calculate_price(base_price, customizations) do
    additive =
      customizations
      |> Enum.filter(& &1.constant_price)
      |> Enum.map(& &1.price_increment_nok)
      |> Enum.sum()

    multiplicative =
      customizations
      |> Enum.reject(& &1.constant_price)
      |> Enum.map(&(&1.price_increment_nok / 100))
      |> Enum.reduce(1, &*/2)

    (base_price + additive) * multiplicative
    |> ceil()
  end
end
```

## Pricing Strategies

### Size-based (Multiplicative)

All sizes scale proportionally:

```typescript
const sizes = [
  { name: "Small", modifier: 80 },   // ×0.80
  { name: "Medium", modifier: 100 }, // ×1.00 (default)
  { name: "Large", modifier: 120 }   // ×1.20
];
```

**Why multiplicative?** Larger drinks use proportionally more ingredients.

### Add-ons (Additive)

Fixed cost regardless of base item:

```typescript
const addons = [
  { name: "Extra Shot", price: 10 },
  { name: "Syrup Pump", price: 5 }
];
```

**Why additive?** Add-ons cost the same regardless of drink size.

### Premium Ingredients (Either)

Can be modeled as:
- **Additive:** Oat milk +5 kr (fixed cost)
- **Multiplicative:** Premium coffee 110 (10% upcharge)

### Discounts (Multiplicative)

Can implement discounts as multiplicative:

```typescript
{ name: "Student Discount", modifier: 90 }  // ×0.90 = 10% off
```

## Edge Cases

### Free Customizations

Set `price_increment_nok: 0` with `constant_price: true`:

```typescript
{ name: "Regular Milk", price_increment_nok: 0, constant_price: true }
```

Result: No price change.

### Price Floors

If calculated price drops below minimum:

```typescript
export const finalPrice = (basePrice, customizations) => {
  const calculated = Math.ceil((basePrice + additive) * multiplicative);
  return Math.max(calculated, MIN_PRICE);  // e.g., MIN_PRICE = 10
};
```

### Rounding

Always round **up** to avoid undercharging:

```typescript
Math.ceil(72.1) === 73
```

## Testing Prices

### Manual Testing

1. Open frontdesk: http://localhost:5173/admin/orders/frontdesk
2. Select item
3. Add customizations
4. Verify displayed price matches expectation

### Automated Testing

```typescript
import { finalPrice } from "$lib/pricing";

test("combines additive and multiplicative correctly", () => {
  const basePrice = 45;
  const customizations = [
    { price_increment_nok: 10, constant_price: true },   // +10
    { price_increment_nok: 120, constant_price: false }  // ×1.20
  ];

  const result = finalPrice(basePrice, customizations);
  // (45 + 10) × 1.20 = 66
  expect(result).toBe(66);
});
```

## Price Display

### In Cart

```svelte
<div>
  <span>Base: {item.basePrice} kr</span>
  {#each item.customizations as custom}
    <span class="text-sm">
      {custom.value_name}:
      {#if custom.constant_price}
        +{custom.price_increment_nok} kr
      {:else}
        ×{custom.price_increment_nok / 100}
      {/if}
    </span>
  {/each}
  <span class="font-bold">Total: {item.totalPrice} kr</span>
</div>
```

### In Order Summary

Show only final prices, not breakdown:

```svelte
{#each order.items as item}
  <div>{item.name}: {item.price} kr</div>
{/each}
```

## Best Practices

- **Use multiplicative for scaling:** Sizes, portions
- **Use additive for fixed costs:** Add-ons, extras
- **Set sensible defaults:** Medium size at 100 (×1.00)
- **Always round up:** Avoid undercharging
- **Test combinations:** Additive + multiplicative edge cases
- **Display clearly:** Show customers how price is calculated

## Troubleshooting

### Price Doesn't Match Expectation

Check:
1. `constant_price` flag correct?
2. For multiplicative, value is whole number (120, not 1.20)?
3. All selected customizations included?
4. Order of operations: additive first, then multiplicative
5. Rounding applied?

### Negative Prices

If multiplicative goes below zero:

```typescript
const multiplicative = Math.max(productBy(...), 0.01);  // Floor at 1%
```

## Next Steps

- [Domain Model](/dev/concepts/domain-model) - CustomizationValue entity
- [Customizing Menu Tutorial](/dev/tutorials/customizing-menu) - Set up pricing
- [Types Reference](/dev/reference/types-and-schemas) - Data structures
