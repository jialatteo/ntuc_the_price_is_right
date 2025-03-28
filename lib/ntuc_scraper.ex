defmodule NtucScraper do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.fairprice.com.sg/category/meat-seafood"

  @impl Crawly.Spider
  def init() do
    [start_urls: ["https://www.fairprice.com.sg/category/meat-seafood"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    items =
      document
      |> Floki.find(".product-container")
      |> Enum.filter(fn x ->
        image_url =
          Floki.find(x, "[data-testid='recommended-product-image'] img")
          |> Floki.attribute("src")
          |> List.first()

        image_url && !String.starts_with?(image_url, "data:image/gif;base64,")
      end)
      |> Enum.map(fn x ->
        %{
          title:
            Floki.find(
              x,
              "[data-testid='product-name-and-metadata'] div:nth-of-type(1) span:nth-of-type(2)"
            )
            |> Floki.text()
            |> String.split("•")
            |> List.first(),
          quantity:
            Floki.find(
              x,
              "[data-testid='product-name-and-metadata'] div:nth-of-type(2) div:nth-of-type(1) span:nth-of-type(1)"
            )
            |> Floki.text()
            |> String.split("•")
            |> List.first(),
          price:
            Floki.find(
              x,
              "[data-testid='product'] div:last-of-type div:nth-of-type(1) div:nth-of-type(1) div:nth-of-type(1) span:nth-of-type(1) span:nth-of-type(1)"
            )
            |> Floki.text()
            |> String.replace("$", "")
            |> String.trim()
            |> String.to_float(),
          image:
            Floki.find(
              x,
              "[data-testid='recommended-product-image'] img"
            )
            |> Floki.attribute("src")
            |> List.first()
        }
      end)

    IO.inspect(items, label: "products", pretty: true)

    # next_requests =
    #   document
    #   |> Floki.find(".next a")
    #   |> Floki.attribute("href")
    #   |> Enum.map(fn url ->
    #     Crawly.Utils.build_absolute_url(url, response.request.url)
    #     |> Crawly.Utils.request_from_url()
    #   end)

    %Crawly.ParsedItem{items: items}
  end
end
