defmodule ExpireWeb.LiveHooks.Anon do
  @moduledoc false

  use ExpireWeb, :live_view

  def on_mount(:anon, _params, session, socket) do
    {:cont, assign_new(socket, :anon_id, fn -> session["anon_id"] end)}
  end
end
