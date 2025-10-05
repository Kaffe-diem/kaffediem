defmodule Kaffebase.Orders.DayId do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Kaffebase.Orders.Order

  @baseline 100

  @spec next(Ecto.Repo.t()) :: {:ok, pos_integer()} | {:error, term()}
  def next(repo) do
    with {:ok, {day_start, next_day_start}} <- day_bounds(Date.utc_today()) do
      query =
        from(o in Order,
          where: o.created >= ^day_start and o.created < ^next_day_start,
          order_by: [desc: o.day_id],
          limit: 1,
          select: o.day_id
        )

      last_id = repo.one(query) || @baseline
      {:ok, last_id + 1}
    end
  rescue
    error -> {:error, error}
  end

  defp day_bounds(date) do
    day_start = DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
    next_day_start = DateTime.add(day_start, 86_400, :second)
    {:ok, {day_start, next_day_start}}
  end

end
