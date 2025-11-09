defmodule ExpireWeb.Plugs.EnsureAnonId do
  import Plug.Conn

  @cookie_name "anon_id"
  # 2 years
  @max_age 60 * 60 * 24 * 365 * 2

  def init(opts), do: opts

  def call(conn, _opts) do
    conn =
      conn
      |> fetch_session()
      |> fetch_cookies()

    anon_id = get_session(conn, :anon_id) || conn.cookies[@cookie_name]

    case anon_id do
      nil ->
        anon_id = Ecto.UUID.generate()

        conn
        |> put_resp_cookie(@cookie_name, anon_id,
          max_age: @max_age,
          http_only: true,
          secure: true,
          same_site: "Lax"
        )
        |> put_session(:anon_id, anon_id)

      anon_id ->
        put_session(conn, :anon_id, anon_id)
    end
  end
end
