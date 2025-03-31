defmodule NtucPriceIsRight.PriceInput do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :price, :decimal
  end

  def changeset(price_input, params) do
    price_input
    |> cast(params, [:price])
    |> validate_required([:price])
  end
end
