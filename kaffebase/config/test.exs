import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :kaffebase, Kaffebase.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../kaffebase_test.db", Path.dirname(__ENV__.file)),
  pool_size: 1,
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kaffebase, KaffebaseWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4002],
  secret_key_base: "9lgg/1gYw2jsOP5uJVM1aY+FlFwl1Pjpmu/20ey6MSAYNJXvii/c5FIbAKdSxySK",
  server: false

# In test we don't send emails.
config :kaffebase, Kaffebase.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
