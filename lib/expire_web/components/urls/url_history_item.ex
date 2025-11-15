defmodule ExpireWeb.Components.Urls.UrlHistoryItem do
  use Phoenix.Component
  use ExpireWeb, :html

  alias Expire.Urls.Url

  attr :current_scope, :map, default: nil
  attr :url, :map, required: true
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
        <a class="link link-hover" href={@short_url}>
          {@short_url}
        </a>
        <div class="text-xs font-semibold opacity-60 truncate">
          {@url.long}
        </div>
      </div>
      <button class="btn btn-square btn-ghost">
        <.icon name="hero-clipboard" class="size-5" />
      </button>
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

  defp short_url(%{short: code} = %Url{}), do: "#{ExpireWeb.Endpoint.url()}/#{code}"
end
