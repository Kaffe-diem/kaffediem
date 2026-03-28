---
title: Add a New Collection
description: Add a new real-time synchronized collection to Kaffediem, covering the full stack from database to frontend with step-by-step instructions.
---

## When to Use This

You want to add a new type of data that:
- Needs to be stored in the database
- Should sync in real-time across multiple clients
- Follows CRUD operations (Create, Read, Update, Delete)

## Example: Adding a "Feedback" Collection

We'll create a customer feedback system as an example.

## Step 1: Create the Database Migration

```bash
cd kaffebase
mix ecto.gen.migration create_feedback
```

Edit the generated file in `priv/repo/migrations/`:

```elixir
defmodule Kaffebase.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedback, primary_key: false) do
      add :id, :string, primary_key: true
      add :customer_id, :integer
      add :rating, :integer, null: false
      add :comment, :text
      add :order_id, :string

      timestamps(type: :utc_datetime_usec)
    end

    create index(:feedback, [:customer_id])
    create index(:feedback, [:order_id])
  end
end
```

Run the migration:

```bash
mix ecto.migrate
```

## Step 2: Create the Ecto Schema

Create `kaffebase/lib/kaffebase/content/feedback.ex`:

```elixir
defmodule Kaffebase.Content.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}

  schema "feedback" do
    field :customer_id, :integer
    field :rating, :integer
    field :comment, :string
    field :order_id, :string

    timestamps()
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:id, :customer_id, :rating, :comment, :order_id])
    |> maybe_put_id()
    |> validate_required([:rating])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

# Add JSON encoder
defimpl Jason.Encoder, for: Kaffebase.Content.Feedback do
  def encode(feedback, opts) do
    Jason.Encode.map(
      %{
        id: feedback.id,
        customer_id: feedback.customer_id,
        rating: feedback.rating,
        comment: feedback.comment,
        order_id: feedback.order_id,
        inserted_at: feedback.inserted_at,
        updated_at: feedback.updated_at
      },
      opts
    )
  end
end
```

## Step 3: Add Context Functions

Edit `kaffebase/lib/kaffebase/content.ex` to add feedback functions:

```elixir
defmodule Kaffebase.Content do
  # ... existing code ...

  alias Kaffebase.Content.Feedback
  alias Kaffebase.Catalog.Crud

  def list_feedback do
    Crud.list(Feedback)
  end

  def get_feedback(id) do
    Crud.get(Feedback, id)
  end

  def create_feedback(attrs) do
    Crud.create(Feedback, attrs)
  end

  def update_feedback(id, attrs) do
    Crud.update(Feedback, id, attrs)
  end

  def delete_feedback(id) do
    Crud.delete(Feedback, id)
  end
end
```

## Step 4: Create the Controller

Create `kaffebase/lib/kaffebase_web/controllers/feedback_controller.ex`:

```elixir
defmodule KaffebaseWeb.FeedbackController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Content
  alias KaffebaseWeb.CollectionChannel

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    feedback_list = Content.list_feedback()
    render(conn, :index, feedback: feedback_list)
  end

  def show(conn, %{"id" => id}) do
    case Content.get_feedback(id) do
      nil -> {:error, :not_found}
      feedback -> render(conn, :show, feedback: feedback)
    end
  end

  def create(conn, params) do
    with {:ok, feedback} <- Content.create_feedback(params) do
      CollectionChannel.broadcast_change("feedback", "create", feedback)

      conn
      |> put_status(:created)
      |> render(:show, feedback: feedback)
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, feedback} <- Content.update_feedback(id, params) do
      CollectionChannel.broadcast_change("feedback", "update", feedback)
      render(conn, :show, feedback: feedback)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, feedback} <- Content.delete_feedback(id) do
      CollectionChannel.broadcast_delete("feedback", feedback)
      send_resp(conn, :no_content, "")
    end
  end

  # JSON rendering
  def render("index.json", %{feedback: feedback_list}) do
    %{feedback: feedback_list}
  end

  def render("show.json", %{feedback: feedback}) do
    %{feedback: feedback}
  end
end
```

## Step 5: Add Routes

Edit `kaffebase/lib/kaffebase_web/router.ex`:

```elixir
scope "/api/collections", KaffebaseWeb do
  pipe_through :api

  # ... existing routes ...

  # Feedback
  get "/feedback/records", FeedbackController, :index
  post "/feedback/records", FeedbackController, :create
  get "/feedback/records/:id", FeedbackController, :show
  patch "/feedback/records/:id", FeedbackController, :update
  put "/feedback/records/:id", FeedbackController, :update
  delete "/feedback/records/:id", FeedbackController, :delete
end
```

## Step 6: Add to CollectionChannel

Edit `kaffebase/lib/kaffebase_web/channels/collection_channel.ex`:

```elixir
defmodule KaffebaseWeb.CollectionChannel do
  # ... existing code ...

  defp load_collection("feedback", _options) do
    Content.list_feedback()
  end

  # ... rest of code ...
end
```

## Step 7: Create TypeScript Types

Edit `src/lib/types.ts`:

```typescript
export type Feedback = {
  id: string;
  customer_id: number | null;
  rating: number;
  comment: string | null;
  order_id: string | null;
  created?: string;
  updated?: string;
};
```

## Step 8: Create the Frontend Store

Create `src/lib/stores/feedback.ts`:

```typescript
import { createCollection, createCrudOperations } from "./collection";
import type { Feedback } from "$lib/types";

function fromApi(data: any): Feedback {
  return {
    id: data.id,
    customer_id: data.customer_id,
    rating: data.rating,
    comment: data.comment,
    order_id: data.order_id,
    created: data.inserted_at,
    updated: data.updated_at
  };
}

export const feedback = createCollection<any, Feedback>("feedback", fromApi);

export const {
  create: createFeedback,
  update: updateFeedback,
  delete: deleteFeedback
} = createCrudOperations<Feedback>("feedback");
```

## Step 9: Use in a Component

Create `src/routes/feedback/+page.svelte`:

```svelte
<script lang="ts">
  import { feedback, createFeedback, deleteFeedback } from "$lib/stores/feedback";

  let rating = 5;
  let comment = "";

  async function submit() {
    await createFeedback({
      id: "",
      customer_id: null,
      rating,
      comment,
      order_id: null
    });

    // Reset form
    rating = 5;
    comment = "";
  }
</script>

<div class="p-4">
  <h1 class="text-2xl font-bold mb-4">Feedback</h1>

  <!-- Form -->
  <form on:submit|preventDefault={submit} class="mb-8">
    <label class="block mb-2">
      Rating:
      <input type="number" min="1" max="5" bind:value={rating} class="input" />
    </label>

    <label class="block mb-2">
      Comment:
      <textarea bind:value={comment} class="textarea" />
    </label>

    <button type="submit" class="btn btn-primary">Submit Feedback</button>
  </form>

  <!-- List -->
  <div class="space-y-4">
    {#each $feedback as item (item.id)}
      <div class="card">
        <div class="flex justify-between">
          <div>
            <div class="text-yellow-500">{"★".repeat(item.rating)}</div>
            <p>{item.comment}</p>
            <small>{item.created}</small>
          </div>
          <button on:click={() => deleteFeedback(item.id)} class="btn btn-sm">
            Delete
          </button>
        </div>
      </div>
    {/each}
  </div>
</div>
```

## Step 10: Test the Collection

### Test Backend

```bash
cd kaffebase
mix test
```

Create a test file `test/kaffebase/content_test.exs`:

```elixir
defmodule Kaffebase.ContentTest do
  use Kaffebase.DataCase

  alias Kaffebase.Content

  describe "feedback" do
    test "create_feedback/1 with valid data creates feedback" do
      attrs = %{rating: 5, comment: "Great service!"}
      assert {:ok, feedback} = Content.create_feedback(attrs)
      assert feedback.rating == 5
      assert feedback.comment == "Great service!"
    end

    test "create_feedback/1 with invalid rating fails" do
      attrs = %{rating: 6, comment: "Invalid"}
      assert {:error, changeset} = Content.create_feedback(attrs)
      assert %{rating: _} = errors_on(changeset)
    end
  end
end
```

### Test Real-time Updates

1. Open http://localhost:5173/feedback in two browser tabs
2. Submit feedback in one tab
3. See it appear in both tabs immediately

### Test API Directly

```bash
# Create feedback
curl -X POST http://localhost:4000/api/collections/feedback/records \
  -H "Content-Type: application/json" \
  -d '{"rating": 5, "comment": "Excellent!"}'

# List feedback
curl http://localhost:4000/api/collections/feedback/records
```

## Checklist

- ✅ Database migration created and run
- ✅ Ecto schema defined with changeset validation
- ✅ Jason encoder implemented
- ✅ Context functions added
- ✅ Controller created with all CRUD actions
- ✅ Routes added to router
- ✅ CollectionChannel load function added
- ✅ TypeScript types defined
- ✅ Frontend store created
- ✅ Component using the store
- ✅ Real-time updates tested

## Common Patterns

### With Associations

If your collection references another entity:

```elixir
schema "feedback" do
  belongs_to :order, Kaffebase.Orders.Order, type: :string
end
```

### With Query Options

Support filtering in CollectionChannel:

```elixir
defp load_collection("feedback", options) do
  query = from(f in Feedback, order_by: [desc: f.inserted_at])

  query =
    if order_id = options["order_id"] do
      where(query, [f], f.order_id == ^order_id)
    else
      query
    end

  Repo.all(query)
end
```

Frontend:

```typescript
export const orderFeedback = createCollection<any, Feedback>(
  "feedback",
  fromApi,
  { queryParams: { order_id: "some_order_id" } }
);
```

## Next Steps

- [Create Database Migration](/dev/how-to/create-database-migration) - Deep dive into migrations
- [Implement Real-time Updates](/dev/how-to/implement-realtime-updates) - Advanced patterns
- [Database Schema Reference](/dev/reference/database-schema) - Schema conventions
