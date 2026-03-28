---
title: Important Files Reference
description: Guide to the most critical files in the Kaffediem codebase, organized by domain and layer for quick navigation.
---

## Core Domain Logic

### Order Management

| File | Purpose |
|------|---------|
| `kaffebase/lib/kaffebase/orders/order.ex` | Order schema with 4-state enum |
| `kaffebase/lib/kaffebase/orders/place_order.ex` | Order creation command, builds denormalized snapshots |
| `kaffebase/lib/kaffebase/orders/day_id.ex` | Daily order ID generation (starts at 100) |
| `kaffebase/lib/kaffebase/orders.ex` | Order context functions |

### Catalog (Menu)

| File | Purpose |
|------|---------|
| `kaffebase/lib/kaffebase/catalog/category.ex` | Category schema |
| `kaffebase/lib/kaffebase/catalog/item.ex` | Menu item schema |
| `kaffebase/lib/kaffebase/catalog/customization_key.ex` | Customization key schema |
| `kaffebase/lib/kaffebase/catalog/customization_value.ex` | Customization value schema |
| `kaffebase/lib/kaffebase/catalog/crud.ex` | Generic CRUD operations for catalog |
| `kaffebase/lib/kaffebase/catalog.ex` | Catalog context functions |

### Authentication

| File | Purpose |
|------|---------|
| `kaffebase/lib/kaffebase/accounts/user.ex` | User schema |
| `kaffebase/lib/kaffebase/accounts.ex` | User management context |
| `kaffebase_web/user_auth.ex` | Authentication plugs and helpers |

### Content

| File | Purpose |
|------|---------|
| `kaffebase/lib/kaffebase/content/message.ex` | Display message schema |
| `kaffebase/lib/kaffebase/content/status.ex` | System status schema |
| `kaffebase/lib/kaffebase/content.ex` | Content context |

## Web Layer (Backend)

### Controllers

| File | Purpose |
|------|---------|
| `kaffebase_web/controllers/order_controller.ex` | Order REST API |
| `kaffebase_web/controllers/item_controller.ex` | Item REST API |
| `kaffebase_web/controllers/category_controller.ex` | Category REST API |
| `kaffebase_web/controllers/customization_key_controller.ex` | Customization key REST API |
| `kaffebase_web/controllers/customization_value_controller.ex` | Customization value REST API |
| `kaffebase_web/controllers/message_controller.ex` | Message REST API |
| `kaffebase_web/controllers/status_controller.ex` | Status REST API |
| `kaffebase_web/controllers/session_controller.ex` | Authentication API |

### Channels (WebSocket)

| File | Purpose |
|------|---------|
| `kaffebase_web/channels/collection_channel.ex` | Generic collection subscription channel |
| `kaffebase_web/channels/user_socket.ex` | WebSocket endpoint configuration |
| `kaffebase/lib/kaffebase/broadcast_helpers.ex` | Broadcasting helpers |

### Routing & Configuration

| File | Purpose |
|------|---------|
| `kaffebase_web/router.ex` | HTTP routing and pipelines |
| `kaffebase_web/endpoint.ex` | Phoenix endpoint configuration |
| `kaffebase/lib/kaffebase/application.ex` | OTP application startup |

## Database

| File | Purpose |
|------|---------|
| `kaffebase/priv/repo/migrations/20251020080000_origin.exs` | Main schema migration (all tables) |
| `kaffebase/priv/repo/migrations/20251023195327_drop_item_customization.ex` | Cleanup migration |
| `kaffebase/priv/repo/seeds.exs` | Seed data script |
| `kaffebase/lib/kaffebase/repo.ex` | Ecto repository |
| `kaffebase/lib/kaffebase/ids.ex` | ID generation (nanoid) |

### Custom Ecto Types

| File | Purpose |
|------|---------|
| `kaffebase/lib/kaffebase/ecto_types/jsonb_items.ex` | Custom type for order items (JSONB) |
| `kaffebase/lib/kaffebase/ecto_types/jsonb_list.ex` | Custom type for generic JSON lists |

## Frontend

### Type Definitions

| File | Purpose |
|------|---------|
| `src/lib/types.ts` | All TypeScript type definitions for domain entities |

### Stores (State Management)

| File | Purpose |
|------|---------|
| `src/lib/stores/collection.ts` | Generic real-time collection pattern |
| `src/lib/stores/menu.ts` | Menu subscription and CRUD operations |
| `src/lib/stores/orders.ts` | Order subscription |
| `src/lib/stores/cart.ts` | Shopping cart (local only, not synchronized) |
| `src/lib/stores/auth.ts` | Authentication state |
| `src/lib/stores/status.ts` | System status subscription |
| `src/lib/stores/toastStore.ts` | Toast notifications |

### Real-time & API

| File | Purpose |
|------|---------|
| `src/lib/realtime/socket.ts` | Phoenix WebSocket connection setup |
| `src/lib/api/session.ts` | Session API calls (login/logout) |

### Business Logic

| File | Purpose |
|------|---------|
| `src/lib/pricing.ts` | Price calculation formula |
| `src/lib/utils/index.ts` | Utility functions (sumBy, groupBy, etc.) |
| `src/lib/constants.ts` | Application constants |

## Key Routes/Pages

### Admin Pages

| File | Purpose |
|------|---------|
| `src/routes/admin/+page.svelte` | Admin dashboard |
| `src/routes/admin/+layout.svelte` | Admin layout (if exists) |
| `src/routes/admin/menu/+page.svelte` | Menu management |
| `src/routes/admin/orders/frontdesk/+page.svelte` | Order entry interface |
| `src/routes/admin/orders/kitchen/+page.svelte` | Kitchen display |
| `src/routes/admin/message/+page.svelte` | Message management |
| `src/routes/admin/stats/+page.svelte` | Statistics dashboard |

### Public Pages

| File | Purpose |
|------|---------|
| `src/routes/+page.svelte` | Homepage and public menu |
| `src/routes/+layout.svelte` | Root layout |
| `src/routes/login/+page.svelte` | Login page |
| `src/routes/account/+page.svelte` | User account page |
| `src/routes/display/+page.svelte` | Public order display screen |

## Configuration

### Backend

| File | Purpose |
|------|---------|
| `kaffebase/mix.exs` | Elixir project configuration and dependencies |
| `kaffebase/config/config.exs` | Application configuration |
| `kaffebase/config/dev.exs` | Development environment config |
| `kaffebase/config/prod.exs` | Production environment config |
| `kaffebase/config/runtime.exs` | Runtime configuration (env vars) |

### Frontend

| File | Purpose |
|------|---------|
| `package.json` | Node.js dependencies and scripts |
| `svelte.config.js` | SvelteKit configuration |
| `vite.config.ts` | Vite build configuration |
| `tailwind.config.js` | TailwindCSS configuration |
| `tsconfig.json` | TypeScript configuration |

## Testing

| File | Purpose |
|------|---------|
| `kaffebase/test/kaffebase_web/controllers/*_test.exs` | Controller tests |
| `kaffebase/test/kaffebase/*_test.exs` | Context tests |
| `kaffebase/test/support/fixtures/*.ex` | Test data factories |
| `kaffebase/test/test_helper.exs` | Test configuration |

## Build & Deployment

| File | Purpose |
|------|---------|
| `Makefile` | Build automation |
| `Dockerfile` (if exists) | Docker image definition |
| `docker-compose.yml` (if exists) | Local development setup |
| `.gitignore` | Git ignore patterns |

## Quick Reference: Where to Find Things

### To understand order creation:
1. `kaffebase/lib/kaffebase/orders/place_order.ex` - Snapshot logic
2. `kaffebase_web/controllers/order_controller.ex` - API endpoint
3. `src/lib/stores/cart.ts` - Frontend cart logic

### To understand pricing:
1. `src/lib/pricing.ts` - Formula implementation
2. `kaffebase/lib/kaffebase/catalog/customization_value.ex` - Price modifiers
3. `src/lib/stores/cart.ts` - Price calculation in UI

### To understand real-time updates:
1. `kaffebase_web/channels/collection_channel.ex` - Channel logic
2. `src/lib/stores/collection.ts` - Generic subscription pattern
3. `src/lib/realtime/socket.ts` - WebSocket setup

### To add a new feature:
1. Migration: `priv/repo/migrations/`
2. Schema: `kaffebase/lib/kaffebase/{context}/{entity}.ex`
3. Context: `kaffebase/lib/kaffebase/{context}.ex`
4. Controller: `kaffebase_web/controllers/{entity}_controller.ex`
5. Router: `kaffebase_web/router.ex`
6. Channel: `kaffebase_web/channels/collection_channel.ex`
7. Types: `src/lib/types.ts`
8. Store: `src/lib/stores/{entity}.ts`
9. Page: `src/routes/{path}/+page.svelte`

## Next Steps

- [API Endpoints](/dev/reference/api-endpoints) - REST API reference
- [Types and Schemas](/dev/reference/types-and-schemas) - Data structures
- [Database Schema](/dev/reference/database-schema) - Database tables
