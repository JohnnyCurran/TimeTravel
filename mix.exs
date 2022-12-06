defmodule TimeTravel.MixProject do
  use Mix.Project

  def project do
    [
      app: :time_travel,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TimeTravel.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.6"},
      {:ecto, "~> 3.8"},
      {:jason, "~> 1.0"}
    ]
  end
end
