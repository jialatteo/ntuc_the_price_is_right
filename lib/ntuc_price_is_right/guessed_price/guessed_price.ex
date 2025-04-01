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
  end
end
