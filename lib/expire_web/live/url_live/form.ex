defmodule ExpireWeb.UrlLive.Form do
  use ExpireWeb, :live_view

  alias Expire.Urls
  alias Expire.Urls.Url

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="card bg-base-100 shadow-sm">
        <figure>
          <img
            src="https://img.daisyui.com/images/stock/photo-1606107557195-0e29a4b5b4aa.webp"
            alt="Shoes"
          />
        </figure>
        <div class="card-body">
          <h2 class="card-title">{@page_title}</h2>
          <.form for={@form} id="url-form" phx-change="validate" phx-submit="save">
            <.input field={@form[:long]} type="text" />
            <.input field={@form[:expires_at]} type="datetime-local" label="Expire at" />
            <footer>
              <.button phx-disable-with="Saving..." variant="primary">Save Url</.button>
              <.button navigate={return_path(@current_scope, @return_to, @url)}>Cancel</.button>
            </footer>
          </.form>
        </div>
      </div>
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
    url = Urls.get_url!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Url")
    |> assign(:url, url)
    |> assign(:form, to_form(Urls.change_url(socket.assigns.current_scope, url)))
  end

  defp apply_action(socket, :new, _params) do
    url = %Url{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "Shorten URL")
    |> assign(:url, url)
    |> assign(:form, to_form(Urls.change_url(socket.assigns.current_scope, url)))
  end

  @impl true
  def handle_event("validate", %{"url" => url_params}, socket) do
    changeset = Urls.change_url(socket.assigns.current_scope, socket.assigns.url, url_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"url" => url_params}, socket) do
    save_url(socket, socket.assigns.live_action, url_params)
  end

  defp save_url(socket, :edit, url_params) do
    case Urls.update_url(socket.assigns.current_scope, socket.assigns.url, url_params) do
      {:ok, url} ->
        {:noreply,
         socket
         |> put_flash(:info, "Url updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, url)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_url(socket, :new, url_params) do
    case Urls.create_url(socket.assigns.current_scope, url_params) do
      {:ok, url} ->
        {:noreply,
         socket
         |> put_flash(:info, "Url created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, url)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _url), do: ~p"/urls"
  defp return_path(_scope, "show", url), do: ~p"/urls"
end
