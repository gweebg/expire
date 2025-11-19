defmodule Expire.Urls.Click do
  use Ecto.Schema
  import Ecto.Changeset

  alias Expire.Urls.Url

  @required_fiels ~w(ip user_agent country referrer)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clicks" do
    field :ip, :string
    field :user_agent, :string
    field :country, :string
    field :referrer, :string

    belongs_to :url, Url, type: :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(click, attrs) do
    click
    |> cast(attrs, @required_fiels)
    |> validate_required(@required_fiels)
  end
end
