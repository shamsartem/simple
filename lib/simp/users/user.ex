defmodule Simp.Users.User do
  use Ecto.Schema

  use Pow.Ecto.Schema,
    password_hash_methods: {&Argon2.hash_pwd_salt/1, &Argon2.verify_pass/2}

  schema "users" do
    pow_user_fields()
    has_many :transactions, Simp.Transactions.Transaction

    timestamps()
  end
end
