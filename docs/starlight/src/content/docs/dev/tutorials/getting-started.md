---
title: Getting Started with Kaffediem
description: Set up your local development environment for Kaffediem and make your first code change in this step-by-step tutorial.
---

## Prerequisites

- Docker installed (for containerized setup)
- OR: Elixir 1.15+, Erlang/OTP 26+, Node.js 18+ (for local setup)
- Git
- A text editor or IDE (VS Code recommended)

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd kaffediem
```

## Step 2: Choose Your Setup Method

### Option A: Docker Setup (Recommended)

This is the simplest way to get started.

1. **Create environment file**:

```bash
cat > .env << EOF
PUBLIC_BACKEND_URL=http://localhost:4000
PUBLIC_BACKEND_WS=ws://localhost:4000/socket
BACKEND_URL=http://localhost:4000
EOF
```

2. **Build and run**:

```bash
make
```

This will:
- Build the Phoenix backend
- Build the SvelteKit frontend
- Start both services in containers
- Set up the database with migrations

3. **Access the application**:
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:4000

### Option B: Local Setup

For a more hands-on development experience.

#### Backend (Phoenix/Elixir)

```bash
cd kaffebase

# Install dependencies
mix deps.get

# Set up database (creates, migrates, seeds)
mix ecto.setup

# Start the Phoenix server
mix phx.server
```

The backend will start on http://localhost:4000

#### Frontend (SvelteKit)

In a separate terminal:

```bash
cd /path/to/kaffediem  # Back to project root

# Install dependencies
npm install

# Create .env file
cat > .env << EOF
PUBLIC_BACKEND_URL=http://localhost:4000
PUBLIC_BACKEND_WS=ws://localhost:4000/socket
EOF

# Start the dev server
npm run dev
```

The frontend will start on http://localhost:5173

## Step 3: Verify the Setup

1. **Open the application**: Navigate to http://localhost:5173
2. **You should see**: The Kaffediem homepage with the logo and menu
3. **Test the backend**: Visit http://localhost:4000/api/collections/status/records
   - You should see a JSON response with status data

## Step 4: Explore the Codebase

Let's familiarize ourselves with the project structure:

```
kaffediem/
├── kaffebase/              # Backend (Phoenix/Elixir)
│   ├── lib/
│   │   ├── kaffebase/      # Business logic contexts
│   │   │   ├── catalog/    # Menu items, categories, customizations
│   │   │   ├── orders/     # Order management
│   │   │   ├── accounts/   # User authentication
│   │   │   └── content/    # Messages and status
│   │   └── kaffebase_web/  # Web layer
│   │       ├── controllers/ # REST API endpoints
│   │       └── channels/    # WebSocket handlers
│   └── priv/repo/migrations/ # Database migrations
├── src/                     # Frontend (SvelteKit)
│   ├── lib/
│   │   ├── types.ts        # TypeScript type definitions
│   │   ├── stores/         # Svelte stores (state management)
│   │   ├── realtime/       # WebSocket connection
│   │   └── pricing.ts      # Price calculation logic
│   └── routes/             # Page components
└── docs/                   # Documentation (you are here!)
```

## Step 5: Make Your First Change

Let's make a simple change to verify everything works.

### Backend Change

1. **Edit the status endpoint response**:

```bash
# Open the file
# kaffebase/lib/kaffebase/content/status.ex
```

Find the `list_statuses/0` function and examine how it retrieves status records.

2. **Restart the Phoenix server** (if running locally):
   - Press `Ctrl+C` twice to stop
   - Run `mix phx.server` again

### Frontend Change

1. **Edit the homepage**:

```bash
# Open src/routes/+page.svelte
```

2. **Add a welcome message** above the menu:

```svelte
<div class="p-4 text-center">
  <p class="text-lg">Welcome to my local Kaffediem! ☕</p>
</div>
```

3. **Save the file** - SvelteKit will automatically hot-reload your changes

4. **Refresh the browser** - You should see your new message!

## Step 6: Test the Real-time Connection

1. Open http://localhost:5173 in your browser
2. Open the browser's developer console (F12)
3. Look for WebSocket connection messages:
   - You should see successful connections to various "collection:" channels
4. In another browser tab, open http://localhost:5173/admin/message (you may need to log in)
5. Change a message and observe real-time updates in the first tab's display page

## Common Issues

### Port Already in Use

If you see errors about ports 4000 or 5173 already being in use:

```bash
# Find and kill the process
lsof -ti:4000 | xargs kill -9  # Backend
lsof -ti:5173 | xargs kill -9  # Frontend
```

### Database Errors

If you encounter database issues:

```bash
cd kaffebase
mix ecto.reset  # Drops, creates, migrates, and seeds
```

### WebSocket Connection Failures

Check that:
1. Backend is running on port 4000
2. Your `.env` file has the correct `PUBLIC_BACKEND_WS` value
3. Browser console shows no CORS errors

## Next Steps

Now that you have a working development environment:

- **[Creating Your First Order](/dev/tutorials/creating-first-order)** - Learn the order lifecycle
- **[Customizing the Menu](/dev/tutorials/customizing-menu)** - Understand menu management
- **[Domain Model](/dev/concepts/domain-model)** - Learn about the data structures

## Development Workflow Tips

### Backend Development

```bash
cd kaffebase

# Run tests
mix test

# Run tests in watch mode
mix test.watch

# Check formatting
mix format

# Interactive Elixir shell with app loaded
iex -S mix phx.server
```

### Frontend Development

```bash
# Type checking
npm run check

# Linting
npm run lint

# Build for production
npm run build
```

### Database Management

```bash
cd kaffebase

# Create a new migration
mix ecto.gen.migration migration_name

# Run migrations
mix ecto.migrate

# Rollback last migration
mix ecto.rollback

# Reset database (drop, create, migrate, seed)
mix ecto.reset
```

## Summary

You've successfully:
- ✅ Set up your development environment
- ✅ Started both frontend and backend services
- ✅ Explored the codebase structure
- ✅ Made your first code change
- ✅ Verified real-time functionality works

You're ready to start developing! 🎉
