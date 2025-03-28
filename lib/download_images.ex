defmodule DownloadImages do
  @behaviour Crawly.Pipeline

  def run(item, state) do
    case Map.get(item, :image) do
      nil ->
        {item, state}

      image_url ->
        filename = image_url |> String.split("/") |> List.last()
        save_path = Path.join(["./images", filename])

        case download_image(image_url, save_path) do
          :ok ->
            {item, state}

          # updated_item = Map.put(item, :image_path, save_path)
          # {updated_item, state}

          :error ->
            {item, state}
        end
    end
  end

  defp download_image(url, path) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        File.write(path, body)

      _ ->
        :error
    end
  end
end
