defmodule NtucPriceIsRight.Pipelines.DownloadImages do
  @behaviour Crawly.Pipeline

  def run(item, state) do
    case Map.get(item, :image) do
      nil ->
        {item, state}

      image_url ->
        filename =
          image_url
          |> String.split("/")
          |> List.last()
          |> String.split("?")
          |> List.first()

        save_path =
          Path.join(["priv", "static", "images", filename])

        relative_path = Path.join(["images", filename])

        case download_image(image_url, save_path) do
          :ok ->
            updated_item = Map.put(item, :image, relative_path)
            {updated_item, state}

          :error ->
            {item, state}
        end
    end
  end

  defp download_image(url, path) do
    IO.inspect(path, label: "path")
    dir = Path.dirname(path)
    IO.inspect(dir, label: "dir")
    File.mkdir_p!(dir)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        File.write(path, body)

      _ ->
        IO.puts("Failed to download image at #{url}")
        :error
    end
  end
end
