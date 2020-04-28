defmodule Simp.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Simp.Repo

  alias Simp.Transactions.Transaction
  alias Simp.Users.User

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  def list_transactions(%User{} = current_user) do
    Repo.all(
      from t in Transaction, where: t.user_id == ^current_user.id, order_by: [desc: t.date]
    )
  end

  def list_transactions(%User{} = current_user, current_page) do
    per_page = 7

    Repo.all(
      from t in Transaction,
        where: t.user_id == ^current_user.id,
        offset: ^((current_page - 1) * per_page),
        order_by: [desc: t.date],
        limit: ^per_page
    )
  end

  def list_categories(%User{} = current_user, is_expense) do
    Repo.all(
      from t in Transaction,
        select: t.category,
        group_by: t.category,
        where: t.user_id == ^current_user.id,
        where: t.is_expense == ^is_expense,
        order_by: [desc: count(t.category)]
    )
  end

  def list_names(%User{} = current_user, category) do
    Repo.all(
      from t in Transaction,
        select: t.name,
        group_by: t.name,
        where: t.user_id == ^current_user.id,
        where: t.category == ^category,
        order_by: [desc: count(t.name)]
    )
  end

  def list_currencies(%User{} = current_user) do
    Repo.all(
      from t in Transaction,
        select: t.currency,
        group_by: t.currency,
        where: t.user_id == ^current_user.id,
        order_by: [desc: count(t.currency)]
    )
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  def get_previous_transaction(%User{} = current_user) do
    Repo.all(
      from t in Transaction,
        where: t.user_id == ^current_user.id,
        order_by: [desc: t.updated_at],
        limit: 1
    )
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}, %User{} = user) do
    user
    |> Ecto.build_assoc(:transactions)
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def create_transactions(attrs \\ [%{}], %User{} = user) do
    changesets =
      attrs
      |> Enum.map(fn attr ->
        user
        |> Ecto.build_assoc(:transactions)
        |> Transaction.changeset(attr)
      end)

    all_is_correct =
      !(changesets
        |> Enum.any?(fn x ->
          !x.valid?
        end))

    inserted_at =
      DateTime.utc_now()
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)

    if all_is_correct do
      Enum.map(changesets, fn changeset ->
        c = Ecto.Changeset.apply_changes(changeset)

        %{
          amount: c.amount,
          category: c.category,
          currency: c.currency,
          date: c.date,
          description: c.description,
          is_expense: c.is_expense,
          name: c.name,
          price: c.price,
          user_id: c.user_id,
          inserted_at: inserted_at,
          updated_at: inserted_at
        }
      end)
      |> Enum.chunk_every(5000)
      |> Enum.each(fn chunk ->
        Repo.insert_all(
          Transaction,
          chunk
        )
      end)
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  def get_sum(%Transaction{} = transaction, decimals) do
    "#{
      if transaction.is_expense do
        "-"
      else
        "+"
      end
    }#{
      Decimal.round(
        Decimal.mult(transaction.price || 0, transaction.amount),
        Map.get(decimals, transaction.currency) || 0
      )
    } #{transaction.currency}"
  end
end
