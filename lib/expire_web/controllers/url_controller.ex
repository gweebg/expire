defmodule ExpireWeb.UrlController do
  use ExpireWeb, :controller

  alias Expire.Urls

  action_fallback ExpireWeb.FallbackController

  def show(conn, %{"slug" => slug}) do
    case Urls.get_url_by_short(slug) do
      nil -> {:error, :not_found}
      url -> redirect(conn, external: url.long)
    end

    # 1) fetch url by slug
    # 2) enqueue oban job for analytics processing
    # 3) redirect from url.slug to url.target~~
  end
end
