defmodule NtucScraper.Repo do
  use Ecto.Repo,
    otp_app: :ntuc_scraper,
    adapter: Ecto.Adapters.SQLite3
end
