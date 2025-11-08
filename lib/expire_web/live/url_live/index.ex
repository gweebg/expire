defmodule ExpireWeb.UrlLive.Index do
  use ExpireWeb, :live_view

  alias Expire.Urls

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Urls.subscribe_urls(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Urls")
     |> stream(:urls, list_urls(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    url = Urls.get_url!(socket.assigns.current_scope, id)
    {:ok, _} = Urls.delete_url(socket.assigns.current_scope, url)

    {:noreply, stream_delete(socket, :urls, url)}
  end

  @impl true
  def handle_info({type, %Expire.Urls.Url{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :urls, list_urls(socket.assigns.current_scope), reset: true)}
  end

  defp list_urls(current_scope) do
    Urls.list_urls(current_scope)
  end
end
