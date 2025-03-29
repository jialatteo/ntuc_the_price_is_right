defmodule NtucPriceIsRight.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NtucPriceIsRight.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        image: "some image",
        price: 120.5,
        quantity: "some quantity",
        title: "some title"
      })
      |> NtucPriceIsRight.Products.create_product()

    product
  end
end
