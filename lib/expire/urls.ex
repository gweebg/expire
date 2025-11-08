defmodule Expire.Urls do
  @moduledoc """
  The Urls context.
  """

  import Ecto.Query, warn: false
  alias Expire.Repo

  alias Expire.Urls.{Url, Base62}
  alias Expire.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any url changes.

  The broadcasted messages match the pattern:

    * {:created, %Url{}}
    * {:updated, %Url{}}
    * {:deleted, %Url{}}

  """
  def subscribe_urls(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Expire.PubSub, "user:#{key}:urls")
  end

  defp broadcast_url(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Expire.PubSub, "user:#{key}:urls", message)
  end

  @doc """
  Returns the list of urls.

  ## Examples

      iex> list_urls(scope)
      [%Url{}, ...]

  """
  def list_urls(%Scope{} = scope) do
    Repo.all_by(Url, user_id: scope.user.id)
  end

  @doc """
  Gets a single url.

  Raises `Ecto.NoResultsError` if the Url does not exist.

  ## Examples

      iex> get_url!(scope, 123)
      %Url{}

      iex> get_url!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_url!(%Scope{} = scope, id) do
    Url
    |> Repo.get_by!(id: id, user_id: scope.user.id)
  end

  @doc """
  Gets an url by its short form.

  Returns `nil` if it doesn't exist.

  ## Examples

      iex> get_url_by_short("aX1u")
      %Url{}

      iex> get_url_by_short("1")
      nil
  """
  def get_url_by_short(short_name) when is_binary(short_name) do
    Url
    |> Repo.get_by(short: short_name)
  end

  @doc """
  Creates a url.

  ## Examples

      iex> create_url(scope, %{field: value})
      {:ok, %Url{}}

      iex> create_url(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_url(scope, attrs) do
    with {:ok, u = %Url{}} <-
           %Url{}
           |> Url.changeset(attrs, scope)
           |> Repo.insert(),
         {:ok, url = %Url{}} <-
           u
           |> Url.short_changeset(%{short: Base62.encode(u.id)})
           |> Repo.update() do
      # broadcast_url(scope, {:created, url})

      {:ok, url}
    end
  end

  @doc """
  Updates a url.

  ## Examples

      iex> update_url(scope, url, %{field: new_value})
      {:ok, %Url{}}

      iex> update_url(scope, url, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_url(%Scope{} = scope, %Url{} = url, attrs) do
    true = url.user_id == scope.user.id

    with {:ok, url = %Url{}} <-
           url
           |> Url.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_url(scope, {:updated, url})
      {:ok, url}
    end
  end

  @doc """
  Deletes a url.

  ## Examples

      iex> delete_url(scope, url)
      {:ok, %Url{}}

      iex> delete_url(scope, url)
      {:error, %Ecto.Changeset{}}

  """
  def delete_url(%Scope{} = scope, %Url{} = url) do
    true = url.user_id == scope.user.id

    with {:ok, url = %Url{}} <-
           Repo.delete(url) do
      broadcast_url(scope, {:deleted, url})
      {:ok, url}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking url changes.

  ## Examples

      iex> change_url(scope, url)
      %Ecto.Changeset{data: %Url{}}

  """
  def change_url(%Scope{} = scope, %Url{} = url, attrs \\ %{}) do
    true = url.user_id == scope.user.id

    Url.changeset(url, attrs, scope)
  end
end
