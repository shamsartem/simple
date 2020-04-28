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
    |> validate_length(:category, max: 255)
    |> validate_length(:name, max: 255)
    |> validate_length(:description, max: 255)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:amount, greater_than: 0)
  end
end
