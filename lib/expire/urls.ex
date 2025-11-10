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
  Returns the list of all urls.

  ## Examples

      iex> list_urls()
      [%Url{}, ...]
  """
  def list_urls() do
    Repo.all(Url)
  end

  @doc """
  Returns the list of urls for a given user.

  ## Examples

      iex> list_urls(scope)
      [%Url{}, ...]

  """
  def list_urls_by_user(%Scope{} = scope) do
    Repo.all_by(Url, user_id: scope.user.id)
  end

  @doc """
  Returns the list of all alerts of a given anon_id.

  ## Examples

      iex> list_urls_by_device(anon_id)
      [%Url{}, ...]
  """
  def list_urls_by_device(anon_id) when is_binary(anon_id) do
    hash = anon_hash(anon_id)
    Repo.all_by(Url, anon_id: hash)
  end

  defp anon_hash(anon_id) when is_binary(anon_id) do
    salt = Application.fetch_env!(:expire, :anon_salt)
    :crypto.hash(:sha256, salt <> ":" <> Ecto.UUID.dump!(anon_id))
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
    Repo.get_by(Url, short: short_name)
  end

  @doc """
  Creates a url by a given user.

  ## Examples

      iex> create_url(scope, %{field: value})
      {:ok, %Url{}}

      iex> create_url(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_url(scope, anon_id, attrs) do
    hash = anon_hash(anon_id)

    with {:ok, u = %Url{}} <-
           %Url{}
           |> Url.changeset(attrs, scope)
           |> Ecto.Changeset.put_change(:anon_id, hash)
           |> Repo.insert(),
         {:ok, url = %Url{}} <-
           u
           |> Url.short_changeset(%{short: Base62.encode(u.id)})
           |> Repo.update() do
      {:ok, url}
    end
  end

  @doc """
  Claim all created urls by an anon_id to a user on its login/sign up.
  """
  def claim_anon_urls(%{user: user}, anon_id) do
    hash = anon_hash(anon_id)

    Url
    |> where([u], is_nil(u.user_id) and u.anon_id == ^hash)
    |> Repo.update_all(set: [user_id: user.id])
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
  def change_url(scope, %Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs, scope)
  end
end
