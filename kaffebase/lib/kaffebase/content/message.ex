defmodule Kaffebase.Content.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}

  schema "message" do
    field :subtitle, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:id, :subtitle, :title])
    |> maybe_put_id()
    |> validate_required([:title])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Content.Message do
  def encode(message, opts) do
    Jason.Encode.map(
      %{
        id: message.id,
        title: message.title,
        subtitle: message.subtitle,
        inserted_at: message.inserted_at,
        updated_at: message.updated_at
      },
      opts
    )
  end
end
