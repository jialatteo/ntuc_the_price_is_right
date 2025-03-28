defmodule NtucScraper.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field(:title, :string)
    field(:price, :float)
    field(:quantity, :string)
    field(:image, :string)

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:title, :price, :quantity, :image])
    |> validate_required([:title, :price, :quantity, :image])
  end
end
