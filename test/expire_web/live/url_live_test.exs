defmodule ExpireWeb.UrlLiveTest do
  use ExpireWeb.ConnCase

  import Phoenix.LiveViewTest
  import Expire.UrlsFixtures

  @create_attrs %{short: "some short", long: "some long", expires_at: "2025-09-25T21:00:00Z"}
  @update_attrs %{short: "some updated short", long: "some updated long", expires_at: "2025-09-26T21:00:00Z"}
  @invalid_attrs %{short: nil, long: nil, expires_at: nil}

  setup :register_and_log_in_user

  defp create_url(%{scope: scope}) do
    url = url_fixture(scope)

    %{url: url}
  end

  describe "Index" do
    setup [:create_url]

    test "lists all urls", %{conn: conn, url: url} do
      {:ok, _index_live, html} = live(conn, ~p"/urls")

      assert html =~ "Listing Urls"
      assert html =~ url.short
    end

    test "saves new url", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/urls")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Url")
               |> render_click()
               |> follow_redirect(conn, ~p"/urls/new")

      assert render(form_live) =~ "New Url"

      assert form_live
             |> form("#url-form", url: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#url-form", url: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/urls")

      html = render(index_live)
      assert html =~ "Url created successfully"
      assert html =~ "some short"
    end

    test "updates url in listing", %{conn: conn, url: url} do
      {:ok, index_live, _html} = live(conn, ~p"/urls")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#urls-#{url.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/urls/#{url}/edit")

      assert render(form_live) =~ "Edit Url"

      assert form_live
             |> form("#url-form", url: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#url-form", url: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/urls")

      html = render(index_live)
      assert html =~ "Url updated successfully"
      assert html =~ "some updated short"
    end

    test "deletes url in listing", %{conn: conn, url: url} do
      {:ok, index_live, _html} = live(conn, ~p"/urls")

      assert index_live |> element("#urls-#{url.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#urls-#{url.id}")
    end
  end

  describe "Show" do
    setup [:create_url]

    test "displays url", %{conn: conn, url: url} do
      {:ok, _show_live, html} = live(conn, ~p"/urls/#{url}")

      assert html =~ "Show Url"
      assert html =~ url.short
    end

    test "updates url and returns to show", %{conn: conn, url: url} do
      {:ok, show_live, _html} = live(conn, ~p"/urls/#{url}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/urls/#{url}/edit?return_to=show")

      assert render(form_live) =~ "Edit Url"

      assert form_live
             |> form("#url-form", url: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#url-form", url: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/urls/#{url}")

      html = render(show_live)
      assert html =~ "Url updated successfully"
      assert html =~ "some updated short"
    end
  end
end
