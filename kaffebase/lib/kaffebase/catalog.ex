defmodule Kaffebase.Catalog do
  @moduledoc """
  Catalog context boundary for the menu domain.
  """

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item
  }

  @doc """
  Returns the catalog schemas keyed by their collection name.
  """
  @spec collections() :: %{String.t() => module()}
  def collections do
    %{
      "category" => Category,
      "item" => Item,
      "customization_key" => CustomizationKey,
      "customization_value" => CustomizationValue
    }
  end
end
