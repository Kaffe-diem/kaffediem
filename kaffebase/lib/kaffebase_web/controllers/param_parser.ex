defmodule KaffebaseWeb.ParamParser do
  @moduledoc false

  @spec parse_sort(String.t() | nil) :: list()
  def parse_sort(nil), do: []

  def parse_sort(sort_string) do
    sort_string
    |> String.split([",", " "], trim: true)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_sort_field/1)
  end

  defp parse_sort_field("-" <> field), do: {:desc, String.to_existing_atom(field)}
  defp parse_sort_field("+" <> field), do: {:asc, String.to_existing_atom(field)}

  defp parse_sort_field(field) do
    {:asc, String.to_existing_atom(field)}
  rescue
    ArgumentError -> {:asc, String.to_atom(field)}
  end

  @spec parse_expand(String.t() | nil, keyword()) :: list(atom())
  def parse_expand(nil, _mapping), do: []

  def parse_expand(expand_string, mapping) do
    lookup = mapping |> to_mapping()

    expand_string
    |> String.split([",", " "], trim: true)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn key -> Map.get(lookup, key, to_atom(key)) end)
    |> Enum.uniq()
  end

  @spec parse_order_filters(String.t() | nil) :: keyword()
  def parse_order_filters(nil), do: []

  def parse_order_filters(filter_string) do
    filter_string
    |> String.split("&&", trim: true)
    |> Enum.reduce([], fn segment, acc ->
      segment = String.trim(segment)

      cond do
        Regex.match?(~r/^created\s*>=/, segment) ->
          case Regex.run(~r/"([^"]+)"|'([^']+)'/, segment) do
            [_, value, nil] -> Keyword.put(acc, :from_date, value)
            [_, nil, value] -> Keyword.put(acc, :from_date, value)
            _ -> acc
          end

        Regex.match?(~r/^customer\s*=\s*/, segment) ->
          case Regex.run(~r/'([^']+)'|"([^"]+)"/, segment) do
            [_, value, nil] -> Keyword.put(acc, :customer, value)
            [_, nil, value] -> Keyword.put(acc, :customer, value)
            _ -> acc
          end

        true ->
          acc
      end
    end)
  end

  @spec pagination(map(), non_neg_integer()) :: map()
  def pagination(params, total_items) do
    page = params |> Map.get("page") |> parse_integer(1)
    per_page = params |> Map.get("perPage") |> parse_integer(max(total_items, 1))

    per_page = if per_page <= 0, do: max(total_items, 1), else: per_page
    total_pages = if per_page == 0, do: 1, else: div(total_items + per_page - 1, per_page)

    %{
      page: page,
      perPage: per_page,
      totalItems: total_items,
      totalPages: total_pages
    }
  end

  defp parse_integer(nil, default), do: default

  defp parse_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_integer(value, _default) when is_integer(value), do: value
  defp parse_integer(_value, default), do: default

  defp to_mapping(mapping) when is_map(mapping), do: mapping
  defp to_mapping(mapping) when is_list(mapping), do: Map.new(mapping)
  defp to_mapping(_), do: %{}

  defp to_atom(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> String.to_atom(key)
  end
end
