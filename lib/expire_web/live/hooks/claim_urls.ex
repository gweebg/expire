defmodule ExpireWeb.LiveHooks.ClaimUrls do
  @moduledoc false

  use ExpireWeb, :live_view

  alias Expire.Accounts.Scope
  alias Expire.Urls

  def on_mount(
        :claim_urls,
        _params,
        %{"anon_id" => anon_id},
        %{assigns: %{current_scope: %Scope{} = scope}} = socket
      )
      when not is_nil(anon_id) do
    if connected?(socket) do
      {amount, _errors} = Urls.claim_anon_urls(scope.user, anon_id)

      socket =
        if amount > 0 do
          put_flash(socket, :info, "Imported #{amount} URLs into your account")
        else
          socket
        end

      {:cont, socket}
    else
      {:cont, socket}
    end
  end

  def on_mount(:claim_urls, _params, _session, socket), do: {:cont, socket}
end
