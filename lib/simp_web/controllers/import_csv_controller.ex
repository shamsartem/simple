defmodule SimpWeb.ImportCSVController do
  use SimpWeb, :controller

  alias Simp.Files.ImportCSV
  alias Simp.Transactions

  def new(conn, _params) do
    changeset = ImportCSV.changeset(%ImportCSV{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"import_csv" => %{"file" => file}}) do
    sos =
      file.path
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.to_list()
      |> Enum.map(fn t ->
        t =
          if t["amount"] == "" do
            Map.put(t, "amount", "1")
          else
            t
          end

        t =
          if t["is_expense"] == "TRUE" do
            Map.put(t, "is_expense", true)
          else
            Map.put(t, "is_expense", false)
          end

        t =
          if t["description"] == "" do
            Map.put(t, "description", nil)
          else
            t
          end

        t
        |> Map.put("date", t["date"] |> String.split(".") |> Enum.reverse() |> Enum.join("-"))
        |> Map.put("price", t["price"] |> String.replace(",", "."))
        |> Map.put("amount", t["amount"] |> String.replace(",", "."))
      end)

    Transactions.create_transactions(sos, conn.assigns.current_user)

    conn
    |> put_flash(:info, "File created successfully.")
    |> redirect(to: Routes.import_csv_path(conn, :new))
  end
end
