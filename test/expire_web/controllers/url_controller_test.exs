defmodule ExpireWeb.UrlControllerTest do
  use ExpireWeb.ConnCase

  import Expire.UrlsFixtures
  alias Expire.Urls.Url

  @create_attrs %{
    short: "some short",
    long: "some long",
    expires_at: ~U[2025-09-26 17:59:00Z]
  }
  @update_attrs %{
    short: "some updated short",
    long: "some updated long",
    expires_at: ~U[2025-09-27 17:59:00Z]
  }
  @invalid_attrs %{short: nil, long: nil, expires_at: nil}

  setup :register_and_log_in_user

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all urls", %{conn: conn} do
      conn = get(conn, ~p"/api/urls")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create url" do
    test "renders url when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/urls", url: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/urls/#{id}")

      assert %{
               "id" => ^id,
               "expires_at" => "2025-09-26T17:59:00Z",
               "long" => "some long",
               "short" => "some short"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/urls", url: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update url" do
    setup [:create_url]

    test "renders url when data is valid", %{conn: conn, url: %Url{id: id} = url} do
      conn = put(conn, ~p"/api/urls/#{url}", url: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/urls/#{id}")

      assert %{
               "id" => ^id,
               "expires_at" => "2025-09-27T17:59:00Z",
               "long" => "some updated long",
               "short" => "some updated short"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, url: url} do
      conn = put(conn, ~p"/api/urls/#{url}", url: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete url" do
    setup [:create_url]

    test "deletes chosen url", %{conn: conn, url: url} do
      conn = delete(conn, ~p"/api/urls/#{url}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/urls/#{url}")
      end
    end
  end

  defp create_url(%{scope: scope}) do
    url = url_fixture(scope)

    %{url: url}
  end
end
