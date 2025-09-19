defmodule Expire.Repo do
  use Ecto.Repo,
    otp_app: :expire,
    adapter: Ecto.Adapters.Postgres
end
