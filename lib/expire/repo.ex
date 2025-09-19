defmodule Expire.Repo do
  use Ecto.Repo,
    otp_app: :expire,
    adapter: Ecto.Adapters.SQLite3
end
