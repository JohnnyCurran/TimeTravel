import Config

config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(js/app.js),
    cd: Path.expand("../assets", __DIR__)
  ]
