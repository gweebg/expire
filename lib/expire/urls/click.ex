defmodule Expire.Urls.Click do
  use Ecto.Schema
  import Ecto.Changeset

  alias Expire.Urls

  @required_fiels ~w(ip country)a
  @optional_fields ~w(bot referrer)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clicks" do
    field :ip, :string
    field :country, :string
    field :referrer, :string
    field :bot, :boolean, default: false

    embeds_one :user_agent, Urls.UserAgent, on_replace: :update

    belongs_to :url, Urls.Url, type: :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(click, attrs) do
    click
    |> cast(attrs, @required_fiels ++ @optional_fields)
    |> validate_required(@required_fiels)
    |> cast_embed(:user_agent, required: true)
  end
end
