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
     |> assign(:previous_is_expense, Ecto.Changeset.get_field(changeset, :is_expense))
     |> set_data()}
  end

  defp set_data(
         %{
           assigns: %{
             current_user: current_user,
             changeset: changeset,
             previous_is_expense: previous_is_expense
           }
         } = socket
       ) do
    is_expense = Ecto.Changeset.get_field(changeset, :is_expense)

    categories =
      Transactions.list_categories(
        current_user,
        is_expense
      )

    changeset =
      if previous_is_expense == is_expense do
        changeset
      else
        Ecto.Changeset.change(changeset, category: List.first(categories) || "")
      end

    names =
      Transactions.list_names(
        current_user,
        Ecto.Changeset.get_field(changeset, :category)
      )

    assign(socket,
      categories: categories,
      names: names,
      currencies: Transactions.list_currencies(current_user),
      changeset: changeset,
      previous_is_expense: is_expense
    )
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    transaction_params = parse_price_and_amount(transaction_params)

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
    transaction_params = parse_price_and_amount(transaction_params)

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
    transaction_params = parse_price_and_amount(transaction_params)

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

  def parse_price_and_amount(%{"price" => price, "amount" => amount} = transaction_params) do
    price_parsed = parse_price_or_amount(price)
    transaction_params = Map.put(transaction_params, "price", price_parsed)

    amount_parsed = parse_price_or_amount(amount)
    Map.put(transaction_params, "amount", amount_parsed)
  end

  def parse_price_or_amount(string) do
    parsingError = %{
      hasError: true,
      isDotUsed: false,
      sign: nil,
      num: "",
      res: 0
    }

    %{sign: sign, num: num, res: res, isDotUsed: isDotUsed, hasError: hasError} =
      Enum.reduce(
        String.graphemes(string),
        %{sign: "+", num: "", res: 0, isDotUsed: false, hasError: false},
        fn symbol, %{sign: sign, num: num, res: res, isDotUsed: isDotUsed, hasError: hasError} ->
          cond do
            hasError or
              (Enum.member?(["+", "-"], symbol) and num === "") or
                ((symbol === "." and isDotUsed) or
                   (symbol === "." and num === "")) ->
              parsingError

            Enum.member?(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], symbol) ->
              %{
                hasError: false,
                sign: sign,
                num: num <> symbol,
                res: res,
                isDotUsed: isDotUsed
              }

            symbol === "." ->
              %{
                hasError: false,
                sign: sign,
                num: num <> symbol,
                res: res,
                isDotUsed: true
              }

            Enum.member?(["+", "-"], symbol) ->
              %{
                hasError: false,
                sign: symbol,
                num: "",
                isDotUsed: false,
                res:
                  res +
                    if sign === "+" do
                      {parsed, _} = Float.parse(num)
                      parsed
                    else
                      {parsed, _} = Float.parse(num)
                      -parsed
                    end
              }

            true ->
              parsingError
          end
        end
      )

    cond do
      hasError ->
        "error"

      true ->
        if num === "" do
          ""
        else
          res =
            res +
              if sign === "+" do
                {parsed, _} = Float.parse(num)
                parsed
              else
                {parsed, _} = Float.parse(num)
                -parsed
              end

          [integer_part, decimal_part] = String.split(Float.to_string(res), ".")

          if decimal_part == "0" do
            String.to_integer(integer_part)
          else
            res
          end
        end
    end
  end
end
