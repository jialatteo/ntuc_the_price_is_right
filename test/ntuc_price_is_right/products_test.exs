defmodule NtucPriceIsRight.ProductsTest do
  use NtucPriceIsRight.DataCase

  alias NtucPriceIsRight.Products

  describe "products" do
    alias NtucPriceIsRight.Products.Product

    import NtucPriceIsRight.ProductsFixtures

    @invalid_attrs %{title: nil, image: nil, price: nil, quantity: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{title: "some title", image: "some image", price: 120.5, quantity: "some quantity"}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.title == "some title"
      assert product.image == "some image"
      assert product.price == 120.5
      assert product.quantity == "some quantity"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{title: "some updated title", image: "some updated image", price: 456.7, quantity: "some updated quantity"}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.title == "some updated title"
      assert product.image == "some updated image"
      assert product.price == 456.7
      assert product.quantity == "some updated quantity"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
