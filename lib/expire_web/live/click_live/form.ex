defmodule ExpireWeb.ClickLive.Form do
  use ExpireWeb, :live_view

  alias Expire.Urls
  alias Expire.Urls.Click

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage click records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="click-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:ip]} type="text" label="Ip" />
        <.input field={@form[:user_agent]} type="text" label="User agent" />
        <.input field={@form[:country]} type="text" label="Country" />
        <.input field={@form[:referrer]} type="text" label="Referrer" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Click</.button>
          <.button navigate={return_path(@return_to, @click)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    click = Urls.get_click!(id)

    socket
    |> assign(:page_title, "Edit Click")
    |> assign(:click, click)
    |> assign(:form, to_form(Urls.change_click(click)))
  end

  defp apply_action(socket, :new, _params) do
    click = %Click{}

    socket
    |> assign(:page_title, "New Click")
    |> assign(:click, click)
    |> assign(:form, to_form(Urls.change_click(click)))
  end

  @impl true
  def handle_event("validate", %{"click" => click_params}, socket) do
    changeset = Urls.change_click(socket.assigns.click, click_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"click" => click_params}, socket) do
    save_click(socket, socket.assigns.live_action, click_params)
  end

  defp save_click(socket, :edit, click_params) do
    case Urls.update_click(socket.assigns.click, click_params) do
      {:ok, click} ->
        {:noreply,
         socket
         |> put_flash(:info, "Click updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, click))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_click(socket, :new, click_params) do
    case Urls.create_click(click_params) do
      {:ok, click} ->
        {:noreply,
         socket
         |> put_flash(:info, "Click created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, click))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _click), do: ~p"/clicks"
  defp return_path("show", click), do: ~p"/clicks/#{click}"
end
