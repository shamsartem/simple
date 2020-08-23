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
    categories =
      Transactions.list_categories(
        current_user,
        Ecto.Changeset.get_field(changeset, :is_expense)
      )

    names =
      Transactions.list_names(
        current_user,
        Ecto.Changeset.get_field(changeset, :category)
      )

    assign(socket,
      categories: categories,
      names: names,
      currencies: Transactions.list_currencies(current_user)
    )
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Transactions.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(changeset: changeset)
      |> set_data()

    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"transaction" => transaction_params},
        %{
          assigns: %{
            action: :edit,
            current_user: current_user,
            transaction: transaction,
            return_to: return_to
          }
        } = socket
      ) do
    if current_user.id == transaction.user_id do
      case Transactions.update_transaction(transaction, transaction_params) do
        {:ok, _transaction} ->
          {:noreply,
           socket
           |> put_flash(:info, "Transaction updated successfully")
           |> push_redirect(to: return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "save",
        %{"transaction" => transaction_params},
        %{
          assigns: %{
            action: :new,
            current_user: current_user,
            return_to: return_to
          }
        } = socket
      ) do
    case Transactions.create_transaction(transaction_params, current_user) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_redirect(to: return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def is_new(list, property, changeset) do
    if Enum.member?(list, Ecto.Changeset.get_field(changeset, property)) do
      ""
    else
      "_new"
    end
  end
end
