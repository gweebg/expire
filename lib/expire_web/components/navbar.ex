defmodule ExpireWeb.Components.Navbar do
  use Phoenix.Component
  use ExpireWeb, :html

  import ExpireWeb.CoreComponents

  attr :current_scope, :map, default: nil
  attr :current_path, :string, default: ""

  def navbar(assigns) do
    ~H"""
    <div class="drawer">
      <input id="navbar-drawer" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">
        <%!-- Navbar --%>
        <div class="navbar bg-base-200 px-4 lg:px-56 lg:mt-4">
          <%!-- Mobile menu button --%>
          <div class="flex-none lg:hidden">
            <label for="navbar-drawer" class="btn btn-square btn-ghost">
              <.icon name="hero-bars-3" class="size-6" />
            </label>
          </div>

          <%!-- Logo --%>
          <div class="flex-1 lg:flex-none flex justify-center lg:justify-start">
            <a href="/" class="flex items-center gap-2">
              <img src={~p"/images/logo.svg"} width="36" alt="Logo" />
              <span class="text-sm font-semibold hidden sm:inline">Expire</span>
            </a>
          </div>

          <%!-- Desktop Navigation --%>
          <div class="flex-1 hidden lg:flex lg:ml-8">
            <ul class="flex items-center gap-6">
              <.navigation_item
                path="/urls"
                label="Shortener"
                current_path={@current_path}
              />
              <.navigation_item
                path="/secrets"
                label="Secrets"
                current_path={@current_path}
              />
            </ul>
          </div>

          <%!-- Right side actions --%>
          <div class="hidden lg:flex items-center gap-2">
            <Layouts.theme_toggle />

            <%= if @current_scope do %>
              <div class="dropdown dropdown-end">
                <label tabindex="0" class="btn btn-ghost btn-circle avatar avatar-placeholder">
                  <div class="w-10 rounded-full bg-primary flex items-center justify-center">
                    <span class="text-sm font-semibold text-primary-base">
                      {String.first(@current_scope.user.email) |> String.upcase()}
                    </span>
                  </div>
                </label>
                <ul
                  tabindex="0"
                  class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52"
                >
                  <li>
                    <.link href={~p"/users/settings"}>Settings</.link>
                  </li>
                  <li>
                    <.link href={~p"/users/log-out"} method="delete">Log out</.link>
                  </li>
                </ul>
              </div>
            <% else %>
              <a href="/users/log-in" class="btn btn-primary">
                Sign In
              </a>
            <% end %>
          </div>
        </div>
      </div>

      <%!-- Mobile Drawer --%>
      <div class="drawer-side z-50">
        <label for="navbar-drawer" class="drawer-overlay"></label>
        <ul class="menu p-4 w-80 min-h-full bg-base-100">
          <li class="mb-4">
            <a href="/" class="flex items-center gap-2">
              <img src={~p"/images/logo.svg"} width="36" alt="Logo" />
              <span class="text-lg font-semibold">Expire</span>
            </a>
          </li>
          <.navigation_item
            path="/urls"
            label="Shortener"
            icon="hero-link"
            current_path={@current_path}
            mobile={true}
          />
          <.navigation_item
            path="/secrets"
            label="Secrets"
            icon="hero-lock-closed"
            current_path={@current_path}
            mobile={true}
          />
          <div class="divider" />
          <li>
            <.link href={~p"/users/settings"}>
              <.icon name="hero-cog-6-tooth" class="size-5" /> Settings
            </.link>
          </li>
          <div class="divider mt-auto"></div>
          <div class="flex flex-row gap-2 justify-between">
            <Layouts.theme_toggle />
            <%= if @current_scope do %>
              <li>
                <.link href={~p"/users/log-out"} method="delete">
                  <.icon name="hero-arrow-right-on-rectangle" class="size-5" /> Sign Out
                </.link>
              </li>
            <% else %>
              <.link href={~p"/users/log-in"} class="btn btn-primary">
                Sign In
              </.link>
            <% end %>
          </div>
        </ul>
      </div>
    </div>
    """
  end

  attr :path, :string, required: true
  attr :label, :string, required: true
  attr :icon, :string, default: nil
  attr :current_path, :string, required: true
  attr :mobile, :boolean, default: false

  defp navigation_item(%{mobile: false} = assigns) do
    ~H"""
    <li>
      <a
        href={@path}
        class={[
          "text-sm transition-colors",
          if(is_active?(@current_path, @path),
            do: "text-base-content font-semibold",
            else: "text-base-content/60 hover:text-base-content"
          )
        ]}
      >
        {@label}
      </a>
    </li>
    """
  end

  defp navigation_item(%{mobile: true} = assigns) do
    ~H"""
    <li>
      <a
        href={@path}
        class={[
          "text-sm transition-colors",
          if(is_active?(@current_path, @path),
            do: "menu-active",
            else: ""
          )
        ]}
      >
        <.icon :if={@icon} name={@icon} class="size-5" /> {@label}
      </a>
    </li>
    """
  end

  defp is_active?(current_path, against_path) do
    current_path
    |> String.starts_with?(against_path)
  end
end
