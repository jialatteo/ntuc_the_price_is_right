# lib/crawly_example/books_to_scrape.ex
defmodule BooksToScrape do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.fairprice.com.sg/category/potato-chips"

  @impl Crawly.Spider
  def init() do
    [start_urls: ["https://www.fairprice.com.sg/category/potato-chips"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    items =
      document
      |> Floki.find(".product-container")
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
              "[data-testid='product'] div:last-of-type div:nth-of-type(1) div:nth-of-type(1) span:nth-of-type(1) span:nth-of-type(1)"
            )
            |> Floki.text(),
          image:
            Floki.find(
              x,
              "[data-testid='recommended-product-image'] img"
            )
            |> Floki.attribute("src")
            |> Floki.text()
            |> String.split("https://")
            |> List.last()
            # Concatenate "https://" with the rest of the URL
            |> (fn url -> "https://" <> url end).()
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
