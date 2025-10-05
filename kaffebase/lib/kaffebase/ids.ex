defmodule Kaffebase.Ids do
  @moduledoc """
  Generates PocketBase-compatible record identifiers.
  """

  @doc """
  Returns a new identifier using the PocketBase style prefix of `r` followed by 14 lowercase hex chars.
  """
  @spec generate() :: String.t()
  def generate do
    "r" <> (:crypto.strong_rand_bytes(7) |> Base.encode16(case: :lower))
  end
end
