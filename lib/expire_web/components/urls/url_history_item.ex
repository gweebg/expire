defmodule ExpireWeb.Components.Urls.UrlHistoryItem do
  use Phoenix.Component
  use ExpireWeb, :html

  alias Expire.Urls.Url

  attr :current_scope, :map, default: nil
  attr :url, Url, required: true
  attr :id, :string, required: true

  def item(assigns) do
    assigns = assign(assigns, :short_url, short_url(assigns.url))

    ~H"""
    <li class="list-row" id={@id}>
      <div>
        <img
          loading="lazy"
          src={favicon_url(@url)}
          alt={"#{@url.long} logo"}
          class="size-10 rounded-box"
        />
      </div>
      <div class="min-w-0 flex-1">
        <a class="link link-hover" href={@short_url} target="blank">
          {@short_url}
        </a>
        <div class="text-xs font-semibold opacity-60 truncate">
          {@url.long}
        </div>
      </div>
      <div class="tooltip relative z-50" data-tip="Copy Link">
        <button
          class="btn btn-square btn-ghost"
          id={"copy-#{@id}"}
          phx-hook="Clipboard"
          data-clipboard-text={@short_url}
        >
          <label class="swap swap-flip">
            <input type="checkbox" data-role="clipboard-swap" />

            <div class="swap-on">
              <.icon name="hero-check" class="size-5 text-primary" />
            </div>
            <div class="swap-off">
              <.icon name="hero-clipboard" class="size-5" />
            </div>
          </label>
        </button>
      </div>
    </li>
    """
  end

  defp favicon_url(%{long: link} = %Url{}) when is_binary(link) do
    domain =
      link
      |> String.split("/", trim: true)
      |> Enum.at(1)
      |> Kernel.<>(".ico")

    "https://icons.duckduckgo.com/ip3/#{domain}"
  end

  defp short_url(%{short: code} = %Url{}), do: "#{ExpireWeb.Endpoint.url()}/u/#{code}"
end
