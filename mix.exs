defmodule TimeTravel.MixProject do
  use Mix.Project

  @source_url "https://github.com/JohnnyCurran/TimeTravel"

  def project do
    [
      app: :time_travel,
      version: "0.2.1",
      elixir: "~> 1.11",
      description: description(),
      package: package(),
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TimeTravel.Application, []}
    ]
  end

  defp description do
    """
    LiveView TimeTravel debugger allows you to record and replay your LiveView's lifecycle as you interact with the page
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files:
        ~w(assets/js lib priv) ++
          ~w(LICENSE mix.exs package.json README.md .formatter.exs)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.8"},
      {:esbuild, "~> 0.5", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.6"}
    ]
  end

  defp aliases do
    [
      "assets.build": ["esbuild module", "esbuild cdn", "esbuild cdn_min", "esbuild main"],
      "assets.watch": ["esbuild module --watch"]
    ]
  end
end
