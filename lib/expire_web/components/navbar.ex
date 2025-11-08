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
        <div class="navbar bg-base-100 px-4 lg:px-56 lg:mt-4">
          <%!-- Mobile menu button --%>
          <div class="flex-none lg:hidden">
            <label for="navbar-drawer" class="btn btn-square btn-ghost">
              <.icon name="hero-bars-3" class="size-6" />
            </label>
          </div>

          <%!-- Logo --%>
          <div class="flex-none">
            <a href="/" class="flex items-center gap-2">
              <img src={~p"/images/logo.svg"} width="36" alt="Logo" />
              <span class="text-sm font-semibold hidden sm:inline">Expire</span>
            </a>
          </div>

          <%!-- Desktop Navigation --%>
          <div class="flex-1 hidden lg:flex lg:ml-8">
            <ul class="flex items-center gap-6">
              <li>
                <a
                  href="/urls"
                  class={[
                    "text-sm transition-colors",
                    if(is_active?(@current_path, "/urls"),
                      do: "text-base-content font-semibold",
                      else: "text-base-content/60 hover:text-base-content"
                    )
                  ]}
                >
                  Shortener
                </a>
              </li>
              <li>
                <a
                  href="/secrets"
                  class={[
                    "text-sm transition-colors",
                    if(is_active?(@current_path, "/secrets"),
                      do: "text-base-content font-semibold",
                      else: "text-base-content/60 hover:text-base-content"
                    )
                  ]}
                >
                  Secrets
                </a>
              </li>
            </ul>
          </div>

          <%!-- Right side actions --%>
          <div class="flex-none flex items-center gap-2">
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
              <a href="/users/log-in" class="btn btn-primary btn-sm">
                Sign In
              </a>
            <% end %>
          </div>
        </div>
      </div>

      <%!-- Mobile Drawer --%>
      <div class="drawer-side z-50">
        <label for="navbar-drawer" class="drawer-overlay"></label>
        <ul class="menu p-4 w-80 min-h-full bg-base-200">
          <li class="mb-4">
            <a href="/" class="flex items-center gap-2">
              <img src={~p"/images/logo.svg"} width="36" alt="Logo" />
              <span class="text-lg font-semibold">Expire</span>
            </a>
          </li>
          <li>
            <a href="/shortener">
              <.icon name="hero-link" class="size-5" /> Shortener
            </a>
          </li>
          <li>
            <a href="/secrets">
              <.icon name="hero-lock-closed" class="size-5" /> Secrets
            </a>
          </li>
          <%= if @current_scope do %>
            <div class="divider"></div>
            <li>
              <a href="/settings">
                <.icon name="hero-cog-6-tooth" class="size-5" /> Settings
              </a>
            </li>
            <li>
              <a href="/users/log_out" method="delete">
                <.icon name="hero-arrow-right-on-rectangle" class="size-5" /> Sign Out
              </a>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp is_active?(current_path, against_path) do
    current_path
    |> String.starts_with?(against_path)
  end
end
