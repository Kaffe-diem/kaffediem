---
title: Developer Documentation
description: Developer documentation for the Kaffediem coffee ordering system
---

This is the **developer documentation** for Kaffediem, a coffee ordering system built by students from [Amalie Skram](https://www.amalieskram.vgs.no) at [kodekafe](https://discord.gg/HC6UMSfrJN).

## Technology Stack

- **Frontend**: SvelteKit with TypeScript, TailwindCSS, DaisyUI
- **Backend**: Elixir Phoenix with SQLite, Phoenix Channels for real-time
- **Deployment**: Coolify (frontend), fly.io (backend)

## Documentation Structure

This documentation follows the [Diataxis framework](https://diataxis.fr/), organizing content into four types:

### 📚 [Tutorials](./tutorials/) - Learning-oriented

Step-by-step lessons to get you productive quickly:

- [Getting Started](/dev/tutorials/getting-started) - Set up your development environment
- [Creating Your First Order](/dev/tutorials/creating-first-order) - Walk through the order flow
- [Customizing the Menu](/dev/tutorials/customizing-menu) - Learn the menu management system

### 🛠️ [How-To Guides](./how-to/) - Task-oriented

Practical guides for common development tasks:

- [Add a New Collection](/dev/how-to/add-new-collection) - Extend the data model
- [Create a New Route](/dev/how-to/create-new-route) - Add pages to the application
- [Add WebSocket Subscription](/dev/how-to/add-websocket-subscription) - Implement real-time updates
- [Create Database Migration](/dev/how-to/create-database-migration) - Modify the database schema
- [Implement Real-time Updates](/dev/how-to/implement-realtime-updates) - Full real-time feature flow
- [Add New Customization Type](/dev/how-to/add-new-customization-type) - Extend menu customizations

### 📖 [Reference](./reference/) - Information-oriented

Technical specifications and API documentation:

- [API Endpoints](/dev/reference/api-endpoints) - REST API reference
- [WebSocket Channels](/dev/reference/websocket-channels) - Phoenix Channel protocols
- [Stores](/dev/reference/stores) - Svelte store API
- [Types and Schemas](/dev/reference/types-and-schemas) - Data structures
- [Database Schema](/dev/reference/database-schema) - Database tables and relationships
- [Important Files](/dev/reference/important-files) - Key files in the codebase

### 💡 [Concepts](./concepts/) - Understanding-oriented

Explanations of how and why the system works:

- [Architecture](/dev/concepts/architecture) - System design and event-driven patterns
- [Domain Model](/dev/concepts/domain-model) - Business entities and relationships
- [Order Lifecycle](/dev/concepts/order-lifecycle) - Order state machine explained
- [Pricing System](/dev/concepts/pricing-system) - How prices are calculated
- [Real-time Architecture](/dev/concepts/realtime-architecture) - WebSocket and store patterns
- [Denormalization Strategy](/dev/concepts/denormalization-strategy) - Why orders snapshot data

## Quick Start

```bash
# 1. Clone and navigate to the project
cd kaffediem

# 2. Set up environment variables (.env)
PUBLIC_BACKEND_URL=https://kaffebase.example
PUBLIC_BACKEND_WS=wss://kaffebase.example/socket
BACKEND_URL=https://kaffebase.example

# 3. Build and run with Docker
make

# 4. Or run backend separately
cd kaffebase
mix setup
mix phx.server

# 5. And frontend separately
npm install
npm run dev
```

## Core Concepts at a Glance

- **Collections**: Unified pattern for real-time data subscriptions (menu, orders, status, messages)
- **Order State Machine**: received → production → completed → dispatched
- **Menu Hierarchy**: Category → Item → CustomizationKey → CustomizationValue
- **Day ID**: Orders get sequential IDs per day, starting at 100
- **Event-Driven**: Changes broadcast via Phoenix Channels, consumed by Svelte stores

## Contributing

See [contribution.md](/dev/contribution) for development guidelines.

## Legacy Documentation

- [Routes Overview](/dev/routes) - Page-by-page description
