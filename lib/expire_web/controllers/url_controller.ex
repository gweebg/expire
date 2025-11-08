defmodule ExpireWeb.UrlController do
  use ExpireWeb, :controller

  alias Expire.Urls

  action_fallback ExpireWeb.FallbackController

  def show(conn, %{"id" => id}) do
    case Urls.get_url_by_short(id) do
      nil -> {:error, :not_found}
      url -> redirect(conn, external: url.long)
    end
  end
end
