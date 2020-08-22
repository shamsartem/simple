defmodule Simp.Search.Search do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search" do
    field :query, :string
  end

  @doc false
  def changeset(search, attrs) do
    search
    |> cast(attrs, [:query])
    |> validate_required([:query])
  end
end
