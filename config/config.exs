# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ntuc_price_is_right,
  ecto_repos: [NtucPriceIsRight.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :ntuc_price_is_right, NtucPriceIsRightWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: NtucPriceIsRightWeb.ErrorHTML, json: NtucPriceIsRightWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: NtucPriceIsRight.PubSub,
  live_view: [signing_salt: "VKD1LJ65"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :ntuc_price_is_right, NtucPriceIsRight.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ntuc_price_is_right: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  ntuc_price_is_right: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :crawly,
  fetcher: {Crawly.Fetchers.CrawlyRenderServer, [base_url: "http://localhost:3000/render"]},
  closespider_timeout: 100,
  concurrent_requests_per_domain: 8,
  closespider_itemcount: 1000,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]},
    {Crawly.Middlewares.RequestOptions, [timeout: 30_000, recv_timeout: 500_000]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:title, :price]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :title},
    NtucPriceIsRight.Pipelines.DownloadImages,
    NtucPriceIsRight.Pipelines.DatabaseInsert
  ]
