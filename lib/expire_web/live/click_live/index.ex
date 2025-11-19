defmodule ExpireWeb.ClickLive.Index do
  use ExpireWeb, :live_view

  alias Expire.Urls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Clicks
        <:actions>
          <.button variant="primary" navigate={~p"/clicks/new"}>
            <.icon name="hero-plus" /> New Click
          </.button>
        </:actions>
      </.header>

      <.table
        id="clicks"
        rows={@streams.clicks}
        row_click={fn {_id, click} -> JS.navigate(~p"/clicks/#{click}") end}
      >
        <:col :let={{_id, click}} label="Ip">{click.ip}</:col>
        <:col :let={{_id, click}} label="User agent">{click.user_agent}</:col>
        <:col :let={{_id, click}} label="Country">{click.country}</:col>
        <:col :let={{_id, click}} label="Referrer">{click.referrer}</:col>
        <:action :let={{_id, click}}>
          <div class="sr-only">
            <.link navigate={~p"/clicks/#{click}"}>Show</.link>
          </div>
          <.link navigate={~p"/clicks/#{click}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, click}}>
          <.link
            phx-click={JS.push("delete", value: %{id: click.id}) |> hide("##{id}")}
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
    {:ok,
     socket
     |> assign(:page_title, "Listing Clicks")
     |> stream(:clicks, list_clicks())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    click = Urls.get_click!(id)
    {:ok, _} = Urls.delete_click(click)

    {:noreply, stream_delete(socket, :clicks, click)}
  end

  defp list_clicks() do
    Urls.list_clicks()
  end
end
