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
        expire_at: ~U[2025-09-25 21:00:00Z],
        long: "some long",
        short: "some short"
      })

    {:ok, url} = Expire.Urls.create_url(scope, attrs)
    url
  end
end
