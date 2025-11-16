defmodule Kaffebase.Content.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "status" do
    field :message, :string, source: :message
    field :open, :boolean
    field :show_message, :boolean, source: :show_message

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:message, :open, :show_message])
    |> validate_required([:message])
  end
end

defimpl Jason.Encoder, for: Kaffebase.Content.Status do
  def encode(status, opts) do
    Jason.Encode.map(
      %{
        id: status.id,
        open: status.open,
        show_message: status.show_message,
        message: status.message,
        inserted_at: status.inserted_at,
        updated_at: status.updated_at
      },
      opts
    )
  end
end
