defmodule ExpireWeb.UrlController do
  use ExpireWeb, :controller

  alias Expire.Urls
  alias Expire.Utils.Conn
  alias Expire.Workers

  action_fallback ExpireWeb.FallbackController

  def show(conn, %{"slug" => slug}) do
    case Urls.get_url_by_slug(slug) do
      nil ->
        {:error, :not_found}

      url ->
        # todo: don't forget to only store statistics if `collect_stats` is true
        ip_address = Conn.get_client_address(conn)
        user_agent = Conn.get_header(conn, "user-agent")
        referrer = Conn.get_header(conn, "referrer")

        %{
          url_id: url.id,
          ip_address: ip_address,
          user_agent: user_agent,
          referrer: referrer
        }
        |> Workers.Analytics.new()
        |> Oban.insert()

        redirect(conn, external: url.long)
    end
  end
end
