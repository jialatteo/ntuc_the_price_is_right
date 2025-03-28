defmodule NtucScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ntuc_scraper,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ecto, :ecto_sql],
      mod: {NtucScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  # mix.exs
  defp deps do
    [
      {:crawly, "~> 0.17.2"},
      {:floki, "~> 0.33.0"},
      {:hackney, "~> 1.21.0", override: true},
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, "~> 0.17"}
    ]
  end
end
