defmodule Expire.UrlsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Expire.Urls` context.
  """

  @doc """
  Generate a url.
  """
  def url_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        long: "https://github.com/gweebg",
        collect_stats: true
      })

    {:ok, url} =
      Expire.Urls.create_url(
        scope,
        Ecto.UUID.generate(),
        attrs
      )

    url
  end

  @doc """
  Generate a click.
  """
  def click_fixture(attrs \\ %{}) do
    {:ok, click} =
      attrs
      |> Enum.into(%{
        country: "some country",
        ip: "some ip",
        referrer: "some referrer",
        user_agent: "some user_agent"
      })
      |> Expire.Urls.create_click()

    click
  end
end
