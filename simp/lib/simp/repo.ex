defmodule Simp.Repo do
  use Ecto.Repo,
    otp_app: :simp,
    adapter: Ecto.Adapters.Postgres
end
