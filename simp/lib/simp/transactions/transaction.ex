defmodule Simp.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :decimal
    field :category, :string
    field :currency, :string
    field :date, :date
    field :description, :string
    field :is_expense, :boolean, default: true
    field :name, :string
    field :price, :decimal
    belongs_to :user, Simp.Users.User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :is_expense,
      :date,
      :category,
      :name,
      :description,
      :price,
      :amount,
      :currency
    ])
    |> validate_required([
      :is_expense,
      :date,
      :category,
      :name,
      :price,
      :amount,
      :currency
    ])
    |> check_constraint(:price, name: :price_must_be_positive)
    |> check_constraint(:amount, name: :amount_must_be_positive)
  end
end
