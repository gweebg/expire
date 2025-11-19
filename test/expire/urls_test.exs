defmodule Expire.UrlsTest do
  use Expire.DataCase

  alias Expire.Urls

  describe "urls" do
    alias Expire.Urls.Url

    import Expire.AccountsFixtures, only: [user_scope_fixture: 0]
    import Expire.UrlsFixtures

    @invalid_attrs %{long: nil, expires_at: nil}

    test "list_urls/1 returns all scoped urls" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      url = url_fixture(scope)
      other_url = url_fixture(other_scope)
      assert Urls.list_urls(scope) == [url]
      assert Urls.list_urls(other_scope) == [other_url]
    end

    test "get_url!/2 returns the url with given id" do
      scope = user_scope_fixture()
      url = url_fixture(scope)
      other_scope = user_scope_fixture()
      assert Urls.get_url!(scope, url.id) == url
      assert_raise Ecto.NoResultsError, fn -> Urls.get_url!(other_scope, url.id) end
    end

    test "create_url/2 with valid data creates a url" do
      valid_attrs = %{short: "some short", long: "some long", expires_at: ~U[2025-09-25 21:00:00Z]}
      scope = user_scope_fixture()

      assert {:ok, %Url{} = url} = Urls.create_url(scope, valid_attrs)
      assert url.short == "some short"
      assert url.long == "some long"
      assert url.expires_at == ~U[2025-09-25 21:00:00Z]
      assert url.user_id == scope.user.id
    end

    test "create_url/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Urls.create_url(scope, @invalid_attrs)
    end

    test "update_url/3 with valid data updates the url" do
      scope = user_scope_fixture()
      url = url_fixture(scope)

      update_attrs = %{
        short: "some updated short",
        long: "some updated long",
        expires_at: ~U[2025-09-26 21:00:00Z]
      }

      assert {:ok, %Url{} = url} = Urls.update_url(scope, url, update_attrs)
      assert url.short == "some updated short"
      assert url.long == "some updated long"
      assert url.expires_at == ~U[2025-09-26 21:00:00Z]
    end

    test "update_url/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      url = url_fixture(scope)

      assert_raise MatchError, fn ->
        Urls.update_url(other_scope, url, %{})
      end
    end

    test "update_url/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      url = url_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Urls.update_url(scope, url, @invalid_attrs)
      assert url == Urls.get_url!(scope, url.id)
    end

    test "delete_url/2 deletes the url" do
      scope = user_scope_fixture()
      url = url_fixture(scope)
      assert {:ok, %Url{}} = Urls.delete_url(scope, url)
      assert_raise Ecto.NoResultsError, fn -> Urls.get_url!(scope, url.id) end
    end

    test "delete_url/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      url = url_fixture(scope)
      assert_raise MatchError, fn -> Urls.delete_url(other_scope, url) end
    end

    test "change_url/2 returns a url changeset" do
      scope = user_scope_fixture()
      url = url_fixture(scope)
      assert %Ecto.Changeset{} = Urls.change_url(scope, url)
    end
  end

  describe "clicks" do
    alias Expire.Urls.Click

    import Expire.UrlsFixtures

    @invalid_attrs %{ip: nil, user_agent: nil, country: nil, referrer: nil}

    test "list_clicks/0 returns all clicks" do
      click = click_fixture()
      assert Urls.list_clicks() == [click]
    end

    test "get_click!/1 returns the click with given id" do
      click = click_fixture()
      assert Urls.get_click!(click.id) == click
    end

    test "create_click/1 with valid data creates a click" do
      valid_attrs = %{ip: "some ip", user_agent: "some user_agent", country: "some country", referrer: "some referrer"}

      assert {:ok, %Click{} = click} = Urls.create_click(valid_attrs)
      assert click.ip == "some ip"
      assert click.user_agent == "some user_agent"
      assert click.country == "some country"
      assert click.referrer == "some referrer"
    end

    test "create_click/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Urls.create_click(@invalid_attrs)
    end

    test "update_click/2 with valid data updates the click" do
      click = click_fixture()
      update_attrs = %{ip: "some updated ip", user_agent: "some updated user_agent", country: "some updated country", referrer: "some updated referrer"}

      assert {:ok, %Click{} = click} = Urls.update_click(click, update_attrs)
      assert click.ip == "some updated ip"
      assert click.user_agent == "some updated user_agent"
      assert click.country == "some updated country"
      assert click.referrer == "some updated referrer"
    end

    test "update_click/2 with invalid data returns error changeset" do
      click = click_fixture()
      assert {:error, %Ecto.Changeset{}} = Urls.update_click(click, @invalid_attrs)
      assert click == Urls.get_click!(click.id)
    end

    test "delete_click/1 deletes the click" do
      click = click_fixture()
      assert {:ok, %Click{}} = Urls.delete_click(click)
      assert_raise Ecto.NoResultsError, fn -> Urls.get_click!(click.id) end
    end

    test "change_click/1 returns a click changeset" do
      click = click_fixture()
      assert %Ecto.Changeset{} = Urls.change_click(click)
    end
  end
end
