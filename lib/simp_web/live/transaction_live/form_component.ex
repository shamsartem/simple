defmodule SimpWeb.TransactionLive.FormComponent do
  use SimpWeb, :live_component

  alias Simp.Transactions

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Transactions.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> set_data()}
  end

  defp set_data(
         %{
           assigns: %{
             current_user: current_user,
             changeset: changeset
           }
         } = socket
       ) do
    socket =
      assign(socket,
        categories:
          Transactions.list_categories(
            current_user,
            Ecto.Changeset.get_field(changeset, :is_expense)
          )
      )

    socket =
      assign(socket,
        names:
          Transactions.list_names(current_user, Ecto.Changeset.get_field(changeset, :category))
      )

    assign(socket,
      currencies: Transactions.list_currencies(current_user)
    )
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Transactions.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, changeset: changeset)

    {:noreply, socket |> set_data()}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    if socket.assigns.current_user.id == socket.assigns.transaction.user_id do
      case Transactions.update_transaction(socket.assigns.transaction, transaction_params) do
        {:ok, _transaction} ->
          {:noreply,
           socket
           |> put_flash(:info, "Transaction updated successfully")
           |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    case Transactions.create_transaction(transaction_params, socket.assigns.current_user) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
