defmodule ExpireWeb.UrlLive.Index do
  use ExpireWeb, :live_view

  alias Expire.Urls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Urls
        <:actions>
          <.button variant="primary" navigate={~p"/urls/new"}>
            <.icon name="hero-plus" /> New Url
          </.button>
        </:actions>
      </.header>

      <.table
        id="urls"
        rows={@streams.urls}
        row_click={fn {_id, url} -> JS.navigate(~p"/urls/#{url}") end}
      >
        <:col :let={{_id, url}} label="Short">{url.short}</:col>
        <:col :let={{_id, url}} label="Long">{url.long}</:col>
        <:col :let={{_id, url}} label="Expire at">{url.expire_at}</:col>
        <:action :let={{_id, url}}>
          <div class="sr-only">
            <.link navigate={~p"/urls/#{url}"}>Show</.link>
          </div>
          <.link navigate={~p"/urls/#{url}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, url}}>
          <.link
            phx-click={JS.push("delete", value: %{id: url.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

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
