defmodule Expire.Analytics.Geolocation do
  use Ecto.Schema

  import Ecto.Changeset

  @fields ~w(country_code country_name region city)a

  @primary_key false
  embedded_schema do
    field :country_code, :string
    field :country_name, :string
    field :region, :string
    field :city, :string
  end

  @doc false
  def changeset(geolocation, attrs) do
    geolocation
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
