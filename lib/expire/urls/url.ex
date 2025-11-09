defmodule Expire.Urls.Url do
  use Ecto.Schema
  import Ecto.Changeset

  @url_regex ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)/

  @optional_fields ~w(user_id expires_at anon_id)a
  @required_fields ~w(long)a

  schema "urls" do
    field :short, :string
    field :long, :string
    field :expires_at, :utc_datetime
    field :anon_id, :binary

    belongs_to :user, Expire.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(url, attrs, user_scope \\ nil) do
    url
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:long, @url_regex, message: "must be a valid url (protocol included)")
    |> validate_change(:expires_at, &in_future/2)
    |> maybe_put_user(user_scope)
  end

  defp maybe_put_user(changeset, nil), do: changeset

  defp maybe_put_user(changeset, user_scope) do
    put_change(changeset, :user_id, user_scope.user.id)
  end

  defp in_future(field, %DateTime{} = value) do
    if DateTime.compare(value, DateTime.utc_now()) == :gt do
      []
    else
      [{field, "must be in the future"}]
    end
  end

  @doc false
  def short_changeset(url, attrs) do
    url
    |> cast(attrs, [:short])
    |> validate_required(:short)
    |> unique_constraint(:short)
  end
end
