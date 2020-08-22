defmodule Simp.Files.ImportCSV do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :file, :binary
  end

  @doc false
  def changeset(import_csv, attrs) do
    import_csv
    |> cast(attrs, [:file])
    |> validate_required([:file])
  end
end
