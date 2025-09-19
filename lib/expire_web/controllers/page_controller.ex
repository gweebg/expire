defmodule ExpireWeb.PageController do
  use ExpireWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
