defmodule KaffebaseWeb.ControllerHelpers do
  @moduledoc false

  def atomize_keys(params) when is_map(params) do
    params
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case to_atom(key) do
        {:ok, atom} -> Map.put(acc, atom, transform_value(value))
        :error -> acc
      end
    end)
  end

  def atomize_keys(value), do: value

  defp transform_value(value) when is_map(value), do: atomize_keys(value)
  defp transform_value(value) when is_list(value), do: Enum.map(value, &transform_value/1)
  defp transform_value(value), do: value

  defp to_atom(key) when is_atom(key), do: {:ok, key}

  defp to_atom(key) when is_binary(key) do
    try do
      {:ok, String.to_existing_atom(key)}
    rescue
      ArgumentError -> :error
    end
  end
end
