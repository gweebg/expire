defmodule ExpireWeb.Router do
  use ExpireWeb, :router

  import ExpireWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExpireWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug ExpireWeb.Plugs.EnsureAnonId
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExpireWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/url", ExpireWeb do
    pipe_through :api
    get "/:id", UrlController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:expire, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExpireWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ExpireWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ExpireWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", ExpireWeb do
    pipe_through [:browser, :ensure_return_to]

    live_session :current_user,
      on_mount: [
        {ExpireWeb.UserAuth, :mount_current_scope},
        {ExpireWeb.LiveHooks.CurrentPath, :current_path},
        {ExpireWeb.LiveHooks.Anon, :anon}
      ] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new

      scope "/urls" do
        live "/", UrlLive.Index, :show
      end
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
