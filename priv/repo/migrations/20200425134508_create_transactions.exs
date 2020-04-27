defmodule Simp.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :is_expense, :boolean, default: false, null: false
      add :date, :date, null: false
      add :category, :string, null: false
      add :name, :string, null: false
      add :description, :string
      add :price, :decimal, null: false
      add :amount, :decimal, null: false
      add :currency, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:transactions, [:user_id])
    create constraint(:transactions, :price_must_be_positive, check: "price > 0")
    create constraint(:transactions, :amount_must_be_positive, check: "amount > 0")
  end
end
