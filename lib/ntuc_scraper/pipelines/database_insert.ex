defmodule NtucScraper.Pipelines.DatabaseInsert do
  @behaviour Crawly.Pipeline
  alias NtucScraper.Product
  alias NtucScraper.Repo

  def run(product, state) do
    changeset = Product.changeset(%Product{}, product)

    case Repo.insert(changeset) do
      {:ok, _} ->
        {product, state}

      {:error, _} ->
        IO.puts("Failed to insert product #{product} into the database")
        {product, state}
    end
  end
end
