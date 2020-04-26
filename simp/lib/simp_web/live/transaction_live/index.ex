defmodule SimpWeb.TransactionLive.Index do
  use SimpWeb, :live_view

  alias Simp.Transactions
  alias Simp.Transactions.Transaction
  alias Simp.Users.User

  @impl true
  def mount(_params, %{"simp_auth" => token}, socket) do
    current_user = SimpWeb.Live.AuthHelper.get_credentials(socket, token)
    transactions = Transactions.list_transactions(current_user)
    [previous_transaction | _] = Transactions.get_previous_transaction(current_user)

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:transactions, transactions)
      |> assign(:previous_transaction, %Transaction{
        date: previous_transaction.date,
        category: previous_transaction.category,
        currency: previous_transaction.currency,
        amount: 1
      })

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Transaction")
    |> assign(:transaction, Transactions.get_transaction!(id))
  end

  defp apply_action(
         %{assigns: %{previous_transaction: previous_transaction}} = socket,
         :new,
         _params
       ) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, previous_transaction)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Transactions.get_transaction!(id)

    if socket.assigns.current_user.id == transaction.user_id do
      {:ok, _} = Transactions.delete_transaction(transaction)

      {:noreply,
       assign(socket, :transactions, Transactions.list_transactions(socket.assigns.current_user))}
    else
      {:noreply, socket}
    end
  end
end
