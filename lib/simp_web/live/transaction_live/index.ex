defmodule SimpWeb.TransactionLive.Index do
  use SimpWeb, :live_view

  alias Simp.Transactions
  alias Simp.Transactions.Transaction

  @impl true
  def mount(_params, %{"simp_auth" => token}, socket) do
    current_user = SimpWeb.Live.AuthHelper.get_credentials(socket, token)

    if current_user == nil do
      {:ok, redirect(socket, to: "/")}
    else
      socket = assign(socket, current_user: current_user)
      {:ok, set_transactions(socket)}
    end
  end

  defp fetch(socket) do
    %{page: page} = socket.assigns
    transactions = Transactions.list_transactions(socket.assigns.current_user, page)
    assign(socket, transactions_to_show: transactions)
  end

  defp set_transactions(socket) do
    previous_transaction =
      case Transactions.get_previous_transaction(socket.assigns.current_user) do
        [previous_transaction | _] -> previous_transaction
        _ -> %Transaction{date: Date.utc_today()}
      end

    transactions = Transactions.list_transactions(socket.assigns.current_user)

    decimals =
      Enum.reduce(transactions, %{}, fn transaction, acc ->
        number_of_decimals =
          transaction.price
          |> Decimal.to_string()
          |> String.split(".")
          |> Enum.at(1)
          |> (fn str ->
                if str do
                  String.length(str)
                else
                  0
                end
              end).()

        if Map.has_key?(acc, transaction.currency) do
          if acc[transaction.currency] < number_of_decimals do
            Map.put(acc, transaction.currency, number_of_decimals)
          else
            acc
          end
        else
          Map.put(acc, transaction.currency, number_of_decimals)
        end
      end)

    socket
    |> assign(
      transactions: transactions,
      decimals: decimals,
      previous_transaction: %Transaction{
        is_expense: previous_transaction.is_expense,
        date: previous_transaction.date,
        category: previous_transaction.category,
        currency: previous_transaction.currency,
        amount: 1
      },
      page: 1
    )
    |> fetch()
  end

  def handle_params(%{"page" => page}, _url, socket) do
    {page, ""} = Integer.parse(page || "1")
    {:noreply, assign(socket, page: page) |> fetch}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:transaction, Transactions.get_transaction!(id))
  end

  defp apply_action(
         %{assigns: %{previous_transaction: previous_transaction}} = socket,
         :new,
         _params
       ) do
    socket
    |> assign(:transaction, previous_transaction)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Transactions.get_transaction!(id)

    if socket.assigns.current_user.id == transaction.user_id do
      {:ok, _} = Transactions.delete_transaction(transaction)

      {:noreply, set_transactions(socket)}
    else
      {:noreply, socket}
    end
  end
end
