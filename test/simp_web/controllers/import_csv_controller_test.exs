defmodule SimpWeb.ImportCSVControllerTest do
  use SimpWeb.ConnCase

  alias Simp.Files

  @create_attrs %{file: "some file"}
  @update_attrs %{file: "some updated file"}
  @invalid_attrs %{file: nil}

  def fixture(:import_csv) do
    {:ok, import_csv} = Files.create_import_csv(@create_attrs)
    import_csv
  end

  describe "index" do
    test "lists all files", %{conn: conn} do
      conn = get(conn, Routes.import_csv_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Files"
    end
  end

  describe "new import_csv" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.import_csv_path(conn, :new))
      assert html_response(conn, 200) =~ "New Import csv"
    end
  end

  describe "create import_csv" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.import_csv_path(conn, :create), import_csv: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.import_csv_path(conn, :show, id)

      conn = get(conn, Routes.import_csv_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Import csv"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.import_csv_path(conn, :create), import_csv: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Import csv"
    end
  end

  describe "edit import_csv" do
    setup [:create_import_csv]

    test "renders form for editing chosen import_csv", %{conn: conn, import_csv: import_csv} do
      conn = get(conn, Routes.import_csv_path(conn, :edit, import_csv))
      assert html_response(conn, 200) =~ "Edit Import csv"
    end
  end

  describe "update import_csv" do
    setup [:create_import_csv]

    test "redirects when data is valid", %{conn: conn, import_csv: import_csv} do
      conn =
        put(conn, Routes.import_csv_path(conn, :update, import_csv), import_csv: @update_attrs)

      assert redirected_to(conn) == Routes.import_csv_path(conn, :show, import_csv)

      conn = get(conn, Routes.import_csv_path(conn, :show, import_csv))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, import_csv: import_csv} do
      conn =
        put(conn, Routes.import_csv_path(conn, :update, import_csv), import_csv: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Import csv"
    end
  end

  describe "delete import_csv" do
    setup [:create_import_csv]

    test "deletes chosen import_csv", %{conn: conn, import_csv: import_csv} do
      conn = delete(conn, Routes.import_csv_path(conn, :delete, import_csv))
      assert redirected_to(conn) == Routes.import_csv_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.import_csv_path(conn, :show, import_csv))
      end
    end
  end

  defp create_import_csv(_) do
    import_csv = fixture(:import_csv)
    %{import_csv: import_csv}
  end
end
