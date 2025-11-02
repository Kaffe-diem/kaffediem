---
title: Architecture
description: System architecture and design patterns for Kaffediem, including event-driven patterns, real-time communication, and technology stack.
---

## High-Level Architecture

![Architecture Diagram](/architecture.excalidraw.svg)

Kaffediem follows an **event-driven architecture** where services don't communicate directly. Instead, they send messages to the backend, and other services subscribe to channels to receive updates.

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐│
│  │  Customer  │  │  Frontdesk │  │   Kitchen  │  │   Display  ││
│  │  Frontend  │  │   Admin    │  │   Admin    │  │   Screen   ││
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘│
│         │                │                │                │      │
└─────────┼────────────────┼────────────────┼────────────────┼──────┘
          │                │                │                │
          │ HTTP + WS      │                │                │
          ▼                ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Backend Layer                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │             Phoenix Endpoint (HTTP/WS)                    │  │
│  └────────┬──────────────────────────────────┬───────────────┘  │
│           │                                    │                  │
│  ┌────────▼────────┐                 ┌────────▼────────┐        │
│  │  REST API       │                 │  Channels       │        │
│  │  (Controllers)  │                 │  (WebSocket)    │        │
│  └────────┬────────┘                 └────────┬────────┘        │
│           │                                    │                  │
│  ┌────────▼────────────────────────────────────▼────────┐       │
│  │            Business Logic (Contexts)                  │       │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │       │
│  │  │ Catalog  │  │  Orders  │  │ Content  │          │       │
│  │  └──────────┘  └──────────┘  └──────────┘          │       │
│  └───────────────────────┬───────────────────────────────┘       │
│                          │                                        │
│  ┌───────────────────────▼───────────────────────────┐          │
│  │            Persistence (Ecto + SQLite)             │          │
│  └─────────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## Core Technologies

### Backend (Kaffebase)

- **Language:** Elixir 1.15+
- **Framework:** Phoenix 1.8
- **Database:** SQLite 3 (via Ecto)
- **Real-time:** Phoenix Channels over WebSocket
- **Authentication:** Session-based with bcrypt

### Frontend

- **Framework:** SvelteKit 2
- **Language:** TypeScript 5
- **Styling:** TailwindCSS 4 + DaisyUI 5
- **Build:** Vite 7
- **Real-time:** Phoenix JS client

### Infrastructure

- **Backend Hosting:** fly.io
- **Frontend Hosting:** Coolify
- **Containerization:** Docker

## Order State Machine

![Order Process](/order.png)

Orders follow a strict 4-state lifecycle:

```
received → production → completed → dispatched
```

See [Order Lifecycle](/dev/concepts/order-lifecycle) for details.

## Event-Driven Pattern

Services communicate through Phoenix Channels using a pub/sub pattern.

### Example Flow

![Display Screen Architecture](/display.excalidraw.svg)

The display screen has no business logic. It subscribes to `$stores/orders` which handles all WebSocket communication.

### Pattern

1. **Action:** User clicks "Move to Production" on kitchen screen
2. **API Call:** Frontend sends `PATCH /api/collections/order/records/:id`
3. **Backend:** Updates order state in database
4. **Broadcast:** Backend sends WebSocket message to `collection:order` channel
5. **All Clients:** Subscribed clients receive update
6. **Store Update:** Svelte stores update automatically
7. **UI Update:** All screens re-render with new state

## Data Flow

### Read (Query)

```
Component
  ↓ subscribes
Store (Svelte writable)
  ↓ subscribes via WebSocket
Channel (Phoenix)
  ↓ on join, loads
Context (Elixir)
  ↓ queries
Database (SQLite)
```

### Write (Command)

```
Component
  ↓ calls
API Function (collection.ts)
  ↓ HTTP POST/PATCH/DELETE
Controller (Phoenix)
  ↓ calls
Context (Elixir)
  ↓ validates & saves
Database (SQLite)
  ↓ after commit
Broadcast (Phoenix.PubSub)
  ↓ WebSocket
All Subscribed Clients
  ↓ update
Stores & UI
```

## Key Design Patterns

### 1. Collection Pattern

Unified pattern for real-time data synchronization:

```typescript
const collection = createCollection<ApiType, DomainType>(
  "collection_name",
  transformFunction,
  options
);
```

Used for: menu, orders, status, messages.

### 2. Denormalized Snapshots

Orders store complete copies of items/prices at order time.

**Why?** Historical accuracy, independence from menu changes.

See [Denormalization Strategy](/dev/concepts/denormalization-strategy) for details.

### 3. Generic CRUD

Controllers follow a standard CRUD pattern:

- `index` - List all
- `show` - Get one
- `create` - Create new
- `update` - Modify existing
- `delete` - Remove

All broadcast changes to WebSocket clients.

### 4. Context-Based Architecture

Business logic organized into contexts:

- **Catalog:** Menu management (categories, items, customizations)
- **Orders:** Order placement and fulfillment
- **Accounts:** User authentication and management
- **Content:** Messages and status for public display

### 5. Reactive UI

Svelte's reactivity + stores = automatic UI updates:

```svelte
<script>
  import { orders } from "$lib/stores/orders";
</script>

<!-- Automatically re-renders when $orders changes -->
{#each $orders as order}
  <OrderCard {order} />
{/each}
```

## Security

### Authentication

- **Session-based:** Cookies with HttpOnly, Secure flags
- **Password hashing:** bcrypt with work factor 12
- **CSRF protection:** Phoenix built-in

### Authorization

- **Admin routes:** Require `is_admin: true` flag
- **User isolation:** Orders optionally linked to users
- **No client-side secrets:** All validation server-side

### CORS

Configured via `cors_plug`, allows frontend domain.

## Performance

### Database

- **SQLite:** Embedded, no network overhead
- **Indexes:** On frequently queried columns
- **Denormalization:** Reduces joins for orders

### Caching

- **No explicit cache:** SQLite is fast enough for current scale
- **Consider adding:** Redis for sessions at scale

### Real-time

- **WebSocket multiplexing:** One connection, many channels
- **Selective broadcasting:** Only to interested clients
- **Efficient encoding:** JSON over binary protocol

## Scalability Considerations

### Current Limits

- **SQLite:** Single-writer, suitable for small-medium load
- **Vertical scaling:** Increase server resources
- **Read replicas:** Not supported by SQLite

### Future Migration Path

If outgrowing SQLite:
1. **PostgreSQL:** Drop-in Ecto replacement
2. **Distributed PubSub:** Redis for Phoenix.PubSub
3. **Horizontal scaling:** Load balancer + multiple nodes
4. **CDN:** Static assets on edge network

## Development Workflow

### Local Development

```bash
# Backend
cd kaffebase
mix phx.server  # Port 4000

# Frontend
npm run dev  # Port 5173
```

### Testing

```bash
# Backend tests
cd kaffebase
mix test

# Frontend (type checking)
npm run check
```

### Deployment

- **Backend:** fly.io with automatic migrations
- **Frontend:** Coolify with Docker builds

## Glossary

- **Kaffebase:** Backend application (Elixir/Phoenix)
- **Svelte:** Reactive UI framework
- **SvelteKit:** Full-stack framework for Svelte
- **Phoenix Channels:** Real-time WebSocket communication
- **Ecto:** Database toolkit for Elixir
- **day_id:** Sequential order number per day (starts at 100)
- **Snapshot:** Denormalized copy of data at a point in time

## Architecture Decisions

### Why Elixir/Phoenix?

- **Concurrency:** Handles many WebSocket connections efficiently
- **Fault tolerance:** Supervisor trees, self-healing
- **Channels:** Built-in real-time capabilities
- **Productivity:** Expressive, functional language

### Why SvelteKit?

- **Performance:** Compiled, minimal runtime
- **Developer experience:** Simple reactivity model
- **TypeScript:** Type safety across stack
- **SSR capable:** Though currently client-side only

### Why SQLite?

- **Simplicity:** No separate database server
- **Reliability:** Proven, battle-tested
- **Performance:** Fast for read-heavy workloads
- **Portability:** Single file, easy backups

### Why WebSocket?

- **Real-time:** Instant updates across clients
- **Efficiency:** One connection, many messages
- **Standard:** Widely supported protocol

## Known Limitations

### Technical Debt

- **No offline support:** Requires active connection
- **No undo/redo:** State changes are final
- **No audit log:** Changes not tracked historically
- **Design system:** UI components lack consistency

### Future Improvements

- **Optimistic updates:** Faster perceived performance
- **Conflict resolution:** Handle concurrent edits gracefully
- **Analytics:** Track metrics and usage patterns
- **Notifications:** Browser/push notifications for staff

## Next Steps

- [Domain Model](/dev/concepts/domain-model) - Entity relationships
- [Order Lifecycle](/dev/concepts/order-lifecycle) - State machine details
- [Real-time Architecture](/dev/concepts/realtime-architecture) - WebSocket patterns
- [Denormalization Strategy](/dev/concepts/denormalization-strategy) - Data modeling decisions
