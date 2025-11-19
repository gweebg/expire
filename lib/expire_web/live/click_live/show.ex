defmodule ExpireWeb.ClickLive.Show do
  use ExpireWeb, :live_view

  alias Expire.Urls

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Click {@click.id}
        <:subtitle>This is a click record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/clicks"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/clicks/#{@click}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit click
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Ip">{@click.ip}</:item>
        <:item title="User agent">{@click.user_agent}</:item>
        <:item title="Country">{@click.country}</:item>
        <:item title="Referrer">{@click.referrer}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Click")
     |> assign(:click, Urls.get_click!(id))}
  end
end
