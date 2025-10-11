defmodule Kaffebase.Repo do
  use Ecto.Repo,
    otp_app: :kaffebase,
    adapter: Ecto.Adapters.SQLite3
end
