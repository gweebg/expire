defmodule Expire.Workers.Analytics do
  @moduledoc """
  Oban worker responsible for handling analytic data fetching from the shortened URLs.

  The analytical processing of data is done asynchronously upon request to the URL shortener
  API controller (`http(s)://ExpireWeb.Endpoint.url()/u/<slug>`) and can (and will) happen even
  after the client is redirected. This way even if heavy operations are done in this step, the
  redirection flow isn't interrupted.
  """

  require Logger

  alias Expire.{Urls, Analytics}

  use Oban.Worker,
    queue: :url_analytics,
    max_attempts: 3,
    tags: ["url", "analytics"]

  # :ok = Oban.Telemetry.attach_default_logger()
  # error reporting at https://hexdocs.pm/oban/error_handling.html
  # auto re-indexing (schedule)
  # auto pruning completed and discarded jobs
  # uniqueness?

  # don't forget to re-download user-agent database (mix ua_inspector.download)

  # figure a way of getting geo data from the address
  # 1) request outside api - slower, rate limits, might be payed
  # 2) local database - fast, needs manual updates
  # 3) fetch 'visitor' header, let the proxy handle the geolocation

  @impl Oban.Worker
  def perform(%Oban.Job{
        args:
          %{
            "url_id" => url_id,
            "ip_address" => ip_address,
            "user_agent" => user_agent,
            "referrer" => referrer
          } = _job
      }) do
    ua = UAInspector.parse(user_agent)
    ua_attrs = Analytics.UserAgent.to_embed_attrs(ua)
    bot? = match?(^ua, %UAInspector.Result.Bot{})

    geolocation =
      case Analytics.GeolocationServer.lookup(ip_address) do
        {:ok, geo_attrs} ->
          geo_attrs

        {:error, reason} ->
          Logger.error(
            "failed to lookup ip address geolocation for #{inspect(ip_address)} with error: #{inspect(reason)}"
          )

          nil
      end

    case Urls.create_click(%{
           ip: ip_address,
           geolocation: geolocation,
           referrer: referrer,
           bot: bot?,
           user_agent: ua_attrs,
           url_id: url_id
         }) do
      {:ok, %Urls.Click{} = _click} ->
        :ok

      {:error, changeset} ->
        Logger.error("failed to create click: #{inspect(changeset.errors, pretty: true)}")
        {:cancel, :failed_creating_click}
    end
  end
end
