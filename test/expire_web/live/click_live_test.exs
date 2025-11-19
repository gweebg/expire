defmodule ExpireWeb.ClickLiveTest do
  use ExpireWeb.ConnCase

  import Phoenix.LiveViewTest
  import Expire.UrlsFixtures

  @create_attrs %{ip: "some ip", user_agent: "some user_agent", country: "some country", referrer: "some referrer"}
  @update_attrs %{ip: "some updated ip", user_agent: "some updated user_agent", country: "some updated country", referrer: "some updated referrer"}
  @invalid_attrs %{ip: nil, user_agent: nil, country: nil, referrer: nil}
  defp create_click(_) do
    click = click_fixture()

    %{click: click}
  end

  describe "Index" do
    setup [:create_click]

    test "lists all clicks", %{conn: conn, click: click} do
      {:ok, _index_live, html} = live(conn, ~p"/clicks")

      assert html =~ "Listing Clicks"
      assert html =~ click.ip
    end

    test "saves new click", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/clicks")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Click")
               |> render_click()
               |> follow_redirect(conn, ~p"/clicks/new")

      assert render(form_live) =~ "New Click"

      assert form_live
             |> form("#click-form", click: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#click-form", click: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/clicks")

      html = render(index_live)
      assert html =~ "Click created successfully"
      assert html =~ "some ip"
    end

    test "updates click in listing", %{conn: conn, click: click} do
      {:ok, index_live, _html} = live(conn, ~p"/clicks")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#clicks-#{click.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/clicks/#{click}/edit")

      assert render(form_live) =~ "Edit Click"

      assert form_live
             |> form("#click-form", click: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#click-form", click: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/clicks")

      html = render(index_live)
      assert html =~ "Click updated successfully"
      assert html =~ "some updated ip"
    end

    test "deletes click in listing", %{conn: conn, click: click} do
      {:ok, index_live, _html} = live(conn, ~p"/clicks")

      assert index_live |> element("#clicks-#{click.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#clicks-#{click.id}")
    end
  end

  describe "Show" do
    setup [:create_click]

    test "displays click", %{conn: conn, click: click} do
      {:ok, _show_live, html} = live(conn, ~p"/clicks/#{click}")

      assert html =~ "Show Click"
      assert html =~ click.ip
    end

    test "updates click and returns to show", %{conn: conn, click: click} do
      {:ok, show_live, _html} = live(conn, ~p"/clicks/#{click}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/clicks/#{click}/edit?return_to=show")

      assert render(form_live) =~ "Edit Click"

      assert form_live
             |> form("#click-form", click: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#click-form", click: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/clicks/#{click}")

      html = render(show_live)
      assert html =~ "Click updated successfully"
      assert html =~ "some updated ip"
    end
  end
end
