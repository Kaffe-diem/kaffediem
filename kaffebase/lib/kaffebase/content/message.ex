defmodule Kaffebase.Content.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "message" do
    field :subtitle, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:subtitle, :title])
    |> ensure_title_not_nil()
  end

  # the frontend rightfully sends null for empty title
  # we want to still support it because messages are by
  # default created without a title.
  # todo: remove this and have frontend send a title on create
  defp ensure_title_not_nil(changeset) do
    case get_field(changeset, :title) do
      nil -> put_change(changeset, :title, "")
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
