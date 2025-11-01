defmodule KaffebaseWeb.Router do
  use KaffebaseWeb, :router

  import KaffebaseWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KaffebaseWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", KaffebaseWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api/collections", KaffebaseWeb do
    pipe_through :api

    # Categories
    get "/category/records", CategoryController, :index
    post "/category/records", CategoryController, :create
    get "/category/records/:id", CategoryController, :show
    patch "/category/records/:id", CategoryController, :update
    put "/category/records/:id", CategoryController, :update
    delete "/category/records/:id", CategoryController, :delete

    # Items
    get "/item/records", ItemController, :index
    post "/item/records", ItemController, :create
    get "/item/records/:id", ItemController, :show
    patch "/item/records/:id", ItemController, :update
    put "/item/records/:id", ItemController, :update
    delete "/item/records/:id", ItemController, :delete

    # Customizations
    get "/customization_key/records", CustomizationKeyController, :index
    post "/customization_key/records", CustomizationKeyController, :create
    get "/customization_key/records/:id", CustomizationKeyController, :show
    patch "/customization_key/records/:id", CustomizationKeyController, :update
    put "/customization_key/records/:id", CustomizationKeyController, :update
    delete "/customization_key/records/:id", CustomizationKeyController, :delete

    get "/customization_value/records", CustomizationValueController, :index
    post "/customization_value/records", CustomizationValueController, :create
    get "/customization_value/records/:id", CustomizationValueController, :show
    patch "/customization_value/records/:id", CustomizationValueController, :update
    put "/customization_value/records/:id", CustomizationValueController, :update
    delete "/customization_value/records/:id", CustomizationValueController, :delete

    # Messages & status
    get "/message/records", MessageController, :index
    post "/message/records", MessageController, :create
    get "/message/records/:id", MessageController, :show
    patch "/message/records/:id", MessageController, :update
    put "/message/records/:id", MessageController, :update
    delete "/message/records/:id", MessageController, :delete

    get "/status/records", StatusController, :index
    post "/status/records", StatusController, :create
    get "/status/records/:id", StatusController, :show
    patch "/status/records/:id", StatusController, :update
    put "/status/records/:id", StatusController, :update
    delete "/status/records/:id", StatusController, :delete

    # Orders
    get "/order/records", OrderController, :index
    post "/order/records", OrderController, :create
    get "/order/records/:id", OrderController, :show
    patch "/order/records/:id", OrderController, :update
    put "/order/records/:id", OrderController, :update
    delete "/order/records/:id", OrderController, :delete
  end

  scope "/api", KaffebaseWeb do
    pipe_through :api

    post "/session", SessionController, :create
    delete "/session", SessionController, :delete
    get "/session", SessionController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", KaffebaseWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:kaffebase, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KaffebaseWeb.Telemetry, ecto_repos: [Kaffebase.Repo]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", KaffebaseWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{KaffebaseWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", KaffebaseWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{KaffebaseWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
