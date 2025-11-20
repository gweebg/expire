defmodule Expire.Utils.Conn do
  @doc """
  Get the client IP(v4|v6) address from the connection.

  Prioritizes the address in the X-Forwarded-For header if available.
  """
  def get_client_address(%Plug.Conn{} = conn) do
    conn.remote_ip
    |> :inet.ntoa()
    |> to_string()
  end

  @doc """
  Get the value of the specified header of the request.

  Returns `nil` if no such header is found.
  """
  def get_header(%Plug.Conn{} = conn, header) when is_binary(header) do
    conn
    |> Plug.Conn.get_req_header(header)
    |> List.first()
  end
end
