import Config

config :crawly,
  fetcher: {Crawly.Fetchers.CrawlyRenderServer, [base_url: "http://localhost:3000/render"]},
  closespider_timeout: 10,
  concurrent_requests_per_domain: 8,
  closespider_itemcount: 100,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]},
    {Crawly.Middlewares.RequestOptions, [timeout: 30_000, recv_timeout: 500_000]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:title, :price]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :title},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "./tmp"}
  ]
