defmodule MultiPostgrex.Mixfile do
  use Mix.Project

  def project do
    [app: :multi_postgrex,
     version: "0.1.2",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {MultiPostgrex.Application, []}]
  end

  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:poolboy, ">= 0.0.0"},
    ]
  end
end
