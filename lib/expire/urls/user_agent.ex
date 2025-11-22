defmodule Expire.Urls.UserAgent do
  use Ecto.Schema

  import Ecto.Changeset

  @fields ~w(raw browser browser_version device_type os_name)a

  @primary_key false
  embedded_schema do
    field :raw, :string

    field :browser, :string
    field :browser_version, :string
    field :device_type, :string
    field :os_name, :string
  end

  @doc false
  def changeset(user_agent, attrs) do
    user_agent
    |> cast(attrs, @fields)
    |> validate_required([:raw])
  end

  def to_embed_attrs(%UAInspector.Result{} = user_agent) do
    %{
      raw: user_agent.user_agent,
      browser: user_agent.browser_family,
      browser_version: user_agent.client.version,
      device_type: user_agent.device.type,
      os_name: user_agent.os.name
    }
  end

  def to_embed_attrs(%UAInspector.Result.Bot{} = bot_ua) do
    %{
      raw: bot_ua.user_agent,
      os_name: bot_ua.name,
      device_type: bot_ua.category
    }
  end
end
