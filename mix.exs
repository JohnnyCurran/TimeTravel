defmodule TimeTravel.MixProject do
  use Mix.Project

  @source_url "https://github.com/JohnnyCurran/TimeTravel"

  def project do
    [
      app: :time_travel,
      version: "0.1.0",
      elixir: "~> 1.11",
      description: description(),
      package: package(),
      source_url: @source_url,
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

  defp description do
  """
  LiveView TimeTravel debugger allows you to record and replay your LiveView's lifecycle as you interact with the page
  """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
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
