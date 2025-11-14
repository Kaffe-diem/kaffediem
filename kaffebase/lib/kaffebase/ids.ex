defmodule Kaffebase.Ids do
  @moduledoc """
  Generates record identifiers.
  todo: this is a legacy from pocketbase, use something more native to elixir, e.g. Ecto.UUID
  """

  @doc """
  Returns a new identifier using the style prefix of `r` followed by 14 lowercase hex chars.
  """
  @spec generate() :: String.t()
  def generate do
    "r" <> (:crypto.strong_rand_bytes(7) |> Base.encode16(case: :lower))
  end
end
