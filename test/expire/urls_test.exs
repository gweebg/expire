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
end
