defmodule ExpireWeb.UrlLive.Show do
  use ExpireWeb, :live_view

  alias Expire.Urls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Url {@url.id}
        <:subtitle>This is a url record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/urls"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/urls/#{@url}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit url
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Short">{@url.short}</:item>
        <:item title="Long">{@url.long}</:item>
        <:item title="Expire at">{@url.expires_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Urls.subscribe_urls(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Url")
     |> assign(:url, Urls.get_url!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Expire.Urls.Url{id: id} = url},
        %{assigns: %{url: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :url, url)}
  end

  def handle_info(
        {:deleted, %Expire.Urls.Url{id: id}},
        %{assigns: %{url: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current url was deleted.")
     |> push_navigate(to: ~p"/urls")}
  end

  def handle_info({type, %Expire.Urls.Url{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
