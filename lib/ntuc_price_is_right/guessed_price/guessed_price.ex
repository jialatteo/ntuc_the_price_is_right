defmodule NtucPriceIsRight.GuessedPrice do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :price, :decimal
  end

  def changeset(guessed_price, params) do
    guessed_price
    |> cast(params, [:price])
    |> validate_required([:price])
    |> validate_number(:price, greater_than_or_equal_to: 0, less_than: 1000)
  end
end
