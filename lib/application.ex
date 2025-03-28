defmodule NtucScraper.Application do
  use Application

  def start(_type, _args) do
    children = [
      NtucScraper.Repo
    ]

    opts = [strategy: :one_for_one, name: NtucScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
