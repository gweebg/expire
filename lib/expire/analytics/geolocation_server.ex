defmodule Expire.Analytics.GeolocationServer do
  @moduledoc """
  Provides geolocation information based on the IP
  address of the request. It handled both IPv4 and IPv6
  addresses and uses the IP2Location database for
  getting the geographical information of the address.
  """

  use GenServer

  @impl true
  def init(_opts) do
    path = Application.fetch_env!(:expire, :iplocation_db_path)
    :ok = :ip2location.new(path)
    {:ok, []}
  end

  @impl true
  def handle_call({:lookup, ip}, _from, state) when is_binary(ip) do
    case :ip2location.query(to_charlist(ip)) do
      {} ->
        {:reply, {:error, "invalid ip address"}, state}

      rec when is_tuple(rec) ->
        country_short = elem(rec, 1)
        country_long = elem(rec, 2)
        region = elem(rec, 3)
        city = elem(rec, 4)

        reply =
          {:ok,
           %{
             country_code: to_string(country_short),
             country_name: to_string(country_long),
             region: to_string(region),
             city: to_string(city)
           }}

        {:reply, reply, state}
    end
  end

  # Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def lookup(ip) when is_binary(ip) do
    GenServer.call(__MODULE__, {:lookup, ip})
  end

  def lookup(_ip), do: {:error, "ip must be a valid binary string (ipv4 and ipv6 are supported)"}
end
