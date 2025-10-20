defmodule Kaffebase.Content.Status do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "status" do
    field :message, :string, source: :message
    field :open, :boolean
    field :show_message, :boolean, source: :show_message

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:id, :message, :open, :show_message])
    |> maybe_put_id()
    |> validate_required([:message])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
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
