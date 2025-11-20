defmodule Expire.Workers.Analytics do
  require Logger

  use Oban.Worker,
    queue: :url_analytics,
    max_attempts: 3,
    tags: ["url", "analytics"]

  # :ok = Oban.Telemetry.attach_default_logger()
  # error reporting at https://hexdocs.pm/oban/error_handling.html
  # auto re-indexing (schedule)
  # auto pruning completed and discarded jobs
  # uniqueness?

  @impl Oban.Worker
  def perform(%Oban.Job{
        args:
          %{
            "url_id" => url_id,
            "ip_address" => ip_address,
            "user_agent" => user_agent,
            "referrer" => referrer
          } = job
      }) do
    IO.inspect(job)
    :ok
  end
end
