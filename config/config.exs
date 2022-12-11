import Config

config :phoenix, :json_library, Jason

if Mix.env() == :dev do
  esbuild = fn args ->
    [
      args: ~w(./js/time_travel --bundle) ++ args,
      cd: Path.expand("../assets", __DIR__)
    ]
  end

  config :esbuild,
    version: "0.14.41",
    module: esbuild.(~w(--format=esm --sourcemap --outfile=../priv/static/time_travel.esm.js)),
    main: esbuild.(~w(--format=cjs --sourcemap --outfile=../priv/static/time_travel.cjs.js)),
    cdn:
      esbuild.(
        ~w(--format=iife --target=es2016 --global-name=TimeTravel --outfile=../priv/static/time_travel.js)
      ),
    cdn_min:
      esbuild.(
        ~w(--format=iife --target=es2016 --global-name=TimeTravel --minify --outfile=../priv/static/time_travel.min.js)
      )
end
