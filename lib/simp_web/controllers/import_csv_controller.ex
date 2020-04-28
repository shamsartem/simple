defmodule SimpWeb.ImportCSVController do
  use SimpWeb, :controller

  alias Simp.Files.ImportCSV
  alias Simp.Transactions

  def new(conn, _params) do
    changeset = ImportCSV.changeset(%ImportCSV{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def download(conn, _params) do
    transactions_list =
      Transactions.list_transactions(conn.assigns.current_user)
      |> Enum.map(fn c ->
        [
          Date.to_string(c.date),
          c.category,
          c.name,
          c.description,
          c.price,
          c.amount,
          c.currency,
          if c.is_expense do
            "TRUE"
          else
            "FALSE"
          end
        ]
      end)

    csv_list = [
      ["date", "category", "name", "description", "price", "amount", "currency", "is_expense"]
      | transactions_list
    ]

    binary =
      csv_list
      |> CSV.encode()
      |> Enum.join("")

    send_download(conn, {:binary, binary}, filename: "transactions.csv")
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

        trim_extra_decimals = fn t, n ->
          t
          |> Map.put(
            "price",
            t["price"]
            |> String.split(".")
            |> (fn arr ->
                  [
                    Enum.at(arr, 0)
                    | arr
                      |> Enum.at(1)
                      |> (fn str ->
                            if str do
                              [
                                str
                                |> String.split("")
                                |> Enum.take(n + 1)
                                |> Enum.join("")
                              ]
                            else
                              []
                            end
                          end).()
                  ]
                end).()
            |> Enum.join(".")
          )
        end

        rename_currency = fn t, c ->
          Map.put(t, "currency", c)
        end

        t =
          case t["currency"] do
            "BYN" ->
              trim_extra_decimals.(t, 2)

            "EUR" ->
              trim_extra_decimals.(t, 2)

            "BYR" ->
              trim_extra_decimals.(t, 0)

            "RUB" ->
              t

            "USD" ->
              t

            "PLN" ->
              t

            "EU" ->
              rename_currency.(t, "EUR")

            "RUR" ->
              rename_currency.(t, "RUB")

            "US" ->
              rename_currency.(t, "USD")

            "USA" ->
              rename_currency.(t, "USD")

            "" ->
              rename_currency.(t, "BYN")

            _ ->
              IO.inspect(t)
              t
          end

        t
        # |> Map.put("date", t["date"] |> String.split(".") |> Enum.reverse() |> Enum.join("-"))
      end)

    Transactions.create_transactions(sos, conn.assigns.current_user)

    conn
    |> redirect(to: Routes.transaction_index_path(conn, :index))
  end
end
