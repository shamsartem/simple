defmodule Simp.FilesTest do
  use Simp.DataCase

  alias Simp.Files

  describe "files" do
    alias Simp.Files.ImportCSV

    @valid_attrs %{file: "some file"}
    @update_attrs %{file: "some updated file"}
    @invalid_attrs %{file: nil}

    def import_csv_fixture(attrs \\ %{}) do
      {:ok, import_csv} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Files.create_import_csv()

      import_csv
    end

    test "list_files/0 returns all files" do
      import_csv = import_csv_fixture()
      assert Files.list_files() == [import_csv]
    end

    test "get_import_csv!/1 returns the import_csv with given id" do
      import_csv = import_csv_fixture()
      assert Files.get_import_csv!(import_csv.id) == import_csv
    end

    test "create_import_csv/1 with valid data creates a import_csv" do
      assert {:ok, %ImportCSV{} = import_csv} = Files.create_import_csv(@valid_attrs)
      assert import_csv.file == "some file"
    end

    test "create_import_csv/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Files.create_import_csv(@invalid_attrs)
    end

    test "update_import_csv/2 with valid data updates the import_csv" do
      import_csv = import_csv_fixture()
      assert {:ok, %ImportCSV{} = import_csv} = Files.update_import_csv(import_csv, @update_attrs)
      assert import_csv.file == "some updated file"
    end

    test "update_import_csv/2 with invalid data returns error changeset" do
      import_csv = import_csv_fixture()
      assert {:error, %Ecto.Changeset{}} = Files.update_import_csv(import_csv, @invalid_attrs)
      assert import_csv == Files.get_import_csv!(import_csv.id)
    end

    test "delete_import_csv/1 deletes the import_csv" do
      import_csv = import_csv_fixture()
      assert {:ok, %ImportCSV{}} = Files.delete_import_csv(import_csv)
      assert_raise Ecto.NoResultsError, fn -> Files.get_import_csv!(import_csv.id) end
    end

    test "change_import_csv/1 returns a import_csv changeset" do
      import_csv = import_csv_fixture()
      assert %Ecto.Changeset{} = Files.change_import_csv(import_csv)
    end
  end
end
