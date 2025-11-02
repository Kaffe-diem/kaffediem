---
title: Create a New Route
description: Add new pages to the Kaffediem application using SvelteKit's file-based routing system with authentication and data loading.
---

## When to Use This

You want to add a new page or feature to the application, such as:
- A new admin panel page
- A customer-facing feature
- A report or dashboard

## SvelteKit Routing Basics

SvelteKit uses **file-based routing**:

```
src/routes/
├── +page.svelte           →  /
├── about/
│   └── +page.svelte       →  /about
└── admin/
    ├── +page.svelte       →  /admin
    └── stats/
        └── +page.svelte   →  /admin/stats
```

## Example: Adding a Reports Page

Let's create a page at `/admin/reports` that shows daily order statistics.

## Step 1: Create the Route Directory

```bash
mkdir -p src/routes/admin/reports
```

## Step 2: Create the Page Component

Create `src/routes/admin/reports/+page.svelte`:

```svelte
<script lang="ts">
  import { orders } from "$lib/stores/orders";
  import { derived } from "svelte/store";

  // Compute statistics from orders
  const stats = derived(orders, ($orders) => {
    const today = new Date().toDateString();
    const todayOrders = $orders.filter((o) => {
      const orderDate = new Date(o.created || "").toDateString();
      return orderDate === today;
    });

    return {
      total: todayOrders.length,
      received: todayOrders.filter((o) => o.state === "received").length,
      production: todayOrders.filter((o) => o.state === "production").length,
      completed: todayOrders.filter((o) => o.state === "completed").length,
      dispatched: todayOrders.filter((o) => o.state === "dispatched").length
    };
  });
</script>

<div class="container mx-auto p-4">
  <h1 class="text-3xl font-bold mb-4">Daily Reports</h1>

  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
    <div class="card bg-base-200 p-4">
      <h2 class="text-xl font-semibold">Total Orders</h2>
      <p class="text-4xl font-bold">{$stats.total}</p>
    </div>

    <div class="card bg-base-200 p-4">
      <h2 class="text-xl font-semibold">In Progress</h2>
      <p class="text-4xl font-bold">{$stats.received + $stats.production}</p>
    </div>

    <div class="card bg-base-200 p-4">
      <h2 class="text-xl font-semibold">Completed</h2>
      <p class="text-4xl font-bold">{$stats.dispatched}</p>
    </div>
  </div>

  <div class="mt-8">
    <h2 class="text-2xl font-semibold mb-4">Order States</h2>
    <div class="space-y-2">
      <div class="flex justify-between p-2 bg-base-200 rounded">
        <span>Received</span>
        <span class="badge">{$stats.received}</span>
      </div>
      <div class="flex justify-between p-2 bg-base-200 rounded">
        <span>Production</span>
        <span class="badge">{$stats.production}</span>
      </div>
      <div class="flex justify-between p-2 bg-base-200 rounded">
        <span>Completed</span>
        <span class="badge">{$stats.completed}</span>
      </div>
      <div class="flex justify-between p-2 bg-base-200 rounded">
        <span>Dispatched</span>
        <span class="badge">{$stats.dispatched}</span>
      </div>
    </div>
  </div>
</div>
```

## Step 3: Test the Route

Navigate to http://localhost:5173/admin/reports

You should see the reports page with live-updating statistics.

## Advanced: Adding a Layout

If you want shared UI (like a sidebar) for all admin pages, use a layout.

### Create a Layout

Create `src/routes/admin/+layout.svelte`:

```svelte
<script lang="ts">
  import { page } from "$app/stores";

  const navItems = [
    { href: "/admin", label: "Dashboard" },
    { href: "/admin/menu", label: "Menu" },
    { href: "/admin/orders/frontdesk", label: "Frontdesk" },
    { href: "/admin/orders/kitchen", label: "Kitchen" },
    { href: "/admin/reports", label: "Reports" },
    { href: "/admin/message", label: "Messages" }
  ];

  $: currentPath = $page.url.pathname;
</script>

<div class="flex h-screen">
  <!-- Sidebar -->
  <aside class="w-64 bg-base-200 p-4">
    <h2 class="text-xl font-bold mb-4">Admin</h2>
    <nav class="space-y-2">
      {#each navItems as item}
        <a
          href={item.href}
          class="block p-2 rounded hover:bg-base-300"
          class:bg-primary={currentPath === item.href}
          class:text-primary-content={currentPath === item.href}
        >
          {item.label}
        </a>
      {/each}
    </nav>
  </aside>

  <!-- Main content -->
  <main class="flex-1 overflow-auto">
    <slot />
  </main>
</div>
```

Now all pages under `/admin` will share this layout.

## Step 4: Add Data Loading

If you need to load data before the page renders, use `+page.ts`:

Create `src/routes/admin/reports/+page.ts`:

```typescript
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ fetch }) => {
  // Load data from API if needed
  const response = await fetch("/api/collections/order/records");
  const data = await response.json();

  return {
    orders: data.orders || []
  };
};
```

Then access it in the component:

```svelte
<script lang="ts">
  import type { PageData } from "./$types";

  export let data: PageData;

  $: orders = data.orders;
</script>

<div>
  <p>Loaded {orders.length} orders</p>
</div>
```

## Step 5: Add Navigation Links

Update other pages to link to your new route:

In `src/routes/admin/+page.svelte`:

```svelte
<a href="/admin/reports" class="btn btn-primary">View Reports</a>
```

## Authentication & Authorization

To require authentication for a route, use the existing auth patterns:

Create `src/routes/admin/reports/+page.ts`:

```typescript
import { redirect } from "@sveltejs/kit";
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ parent }) => {
  const { user } = await parent();

  // Redirect if not authenticated
  if (!user?.id) {
    throw redirect(302, "/login");
  }

  // Redirect if not admin
  if (!user.isAdmin) {
    throw redirect(302, "/");
  }

  return {};
};
```

## Dynamic Routes

To create routes with parameters (like `/orders/:id`):

Create `src/routes/orders/[id]/+page.svelte`:

```svelte
<script lang="ts">
  import type { PageData } from "./$types";
  import { orders } from "$lib/stores/orders";

  export let data: PageData;

  $: order = $orders.find((o) => o.id === data.id);
</script>

<div>
  {#if order}
    <h1>Order #{order.day_id}</h1>
    <p>State: {order.state}</p>
    <!-- ... -->
  {:else}
    <p>Order not found</p>
  {/if}
</div>
```

And `src/routes/orders/[id]/+page.ts`:

```typescript
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ params }) => {
  return {
    id: params.id
  };
};
```

## API Routes

To create API endpoints (not just pages), use `+server.ts`:

Create `src/routes/api/stats/+server.ts`:

```typescript
import { json } from "@sveltejs/kit";
import type { RequestHandler } from "./$types";

export const GET: RequestHandler = async () => {
  // Compute stats
  const stats = {
    timestamp: new Date().toISOString(),
    orders: 42
  };

  return json(stats);
};
```

Access at: http://localhost:5173/api/stats

## Route Groups (Organization)

Use parentheses to organize files without affecting URLs:

```
src/routes/
└── admin/
    ├── (orders)/
    │   ├── frontdesk/
    │   │   └── +page.svelte  →  /admin/frontdesk
    │   └── kitchen/
    │       └── +page.svelte  →  /admin/kitchen
    └── (content)/
        └── message/
            └── +page.svelte  →  /admin/message
```

The `(orders)` and `(content)` folders help organize code but don't create URL segments.

## Error Handling

Create custom error pages with `+error.svelte`:

Create `src/routes/admin/reports/+error.svelte`:

```svelte
<script lang="ts">
  import { page } from "$app/stores";
</script>

<div class="container mx-auto p-4 text-center">
  <h1 class="text-4xl font-bold text-error">Error {$page.status}</h1>
  <p class="text-xl mt-4">{$page.error?.message || "Something went wrong"}</p>
  <a href="/admin" class="btn btn-primary mt-4">Back to Admin</a>
</div>
```

## Loading States

Show loading indicators with `+page.ts` and loading state:

```svelte
<script lang="ts">
  import { navigating } from "$app/stores";
</script>

{#if $navigating}
  <div class="loading loading-spinner loading-lg"></div>
{:else}
  <!-- Your content -->
{/if}
```

## Checklist

- ✅ Created route directory
- ✅ Added `+page.svelte` component
- ✅ Added `+page.ts` for data loading (if needed)
- ✅ Added navigation links
- ✅ Tested authentication/authorization (if needed)
- ✅ Verified route works in browser

## Common Patterns

### Admin Dashboard Page

```
src/routes/admin/dashboard/
├── +page.svelte          # Main dashboard UI
└── +page.ts              # Load data, check auth
```

### CRUD Resource Pages

```
src/routes/admin/items/
├── +page.svelte          # List all items
├── new/
│   └── +page.svelte      # Create new item form
└── [id]/
    ├── +page.svelte      # View item details
    └── edit/
        └── +page.svelte  # Edit item form
```

### Public vs Protected Routes

```
src/routes/
├── +page.svelte          # Public: Homepage
├── menu/
│   └── +page.svelte      # Public: Menu
└── admin/
    ├── +layout.ts        # Check auth at layout level
    └── +page.svelte      # Protected: Admin dashboard
```

## Next Steps

- [Add WebSocket Subscription](/dev/how-to/add-websocket-subscription) - Add real-time to your route
- [Stores Reference](/dev/reference/stores) - Learn about available stores
- [Types Reference](/dev/reference/types-and-schemas) - Understand data structures

## Troubleshooting

### Route Not Found (404)

Check:
1. File is named `+page.svelte` (not `page.svelte`)
2. Directory structure matches URL path
3. Dev server restarted if adding new routes

### Layout Not Applied

Check:
1. `+layout.svelte` is in the correct directory
2. Contains `<slot />` for child content
3. Parent layouts don't override

### Data Not Loading

Check:
1. `+page.ts` exports a `load` function
2. Return value is an object
3. Data is accessed correctly in component with `export let data`
