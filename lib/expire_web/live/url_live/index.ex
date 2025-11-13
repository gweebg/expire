defmodule ExpireWeb.UrlLive.Index do
  use ExpireWeb, :live_view

  alias Expire.Urls
  alias Expire.Urls.Url
  alias Expire.Accounts.Scope

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) and socket.assigns.current_scope do
      Urls.subscribe_urls(socket.assigns.current_scope)
    end

    search_key = socket.assigns.current_scope || socket.assigns.anon_id
    empty_url = Urls.change_url(socket.assigns.current_scope, %Url{})

    {:ok,
     socket
     |> assign(:page_title, "Shortener")
     |> assign(:form, to_form(empty_url))
     |> assign(:current, nil)
     |> stream(:urls, maybe_list_urls(search_key))}
  end

  defp maybe_list_urls(nil), do: []
  defp maybe_list_urls(anon_id) when is_binary(anon_id), do: Urls.list_urls_by_device(anon_id)
  defp maybe_list_urls(%Scope{} = current_scope), do: Urls.list_urls_by_user(current_scope)

  @impl true
  def handle_event("validate", %{"url" => url_params}, socket) do
    changeset =
      socket.assigns.current_scope
      |> Urls.change_url(%Url{}, url_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"url" => url_params}, socket) do
    scope = socket.assigns.current_scope
    anon_id = socket.assigns.anon_id

    case Urls.create_url(scope, anon_id, url_params) do
      {:ok, url} ->
        {:noreply,
          socket
          |> Toast.put_toast(:success, "Changes saved!", duration: 1000)
          |> assign(:form, to_form(Urls.change_url(scope, %Url{})))
          |> assign(:current, url)
          |> stream_insert(:urls, url)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   url = Urls.get_url!(socket.assigns.current_scope, id)
  #   {:ok, _} = Urls.delete_url(socket.assigns.current_scope, url)

  #   {:noreply, stream_delete(socket, :urls, url)}
  # end

  # @impl true
  # def handle_info({type, %Expire.Urls.Url{}}, socket)
  #     when type in [:created, :updated, :deleted] do
  #   {:noreply, stream(socket, :urls, list_urls(socket.assigns.current_scope), reset: true)}
  # end
end
