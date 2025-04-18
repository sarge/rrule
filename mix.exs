defmodule RRule.MixProject do
  use Mix.Project

  @version "0.7.0"

  def project do
    [
      app: :rrule,
      version: @version,
      elixir: "~> 1.13 or ~> 1.14",
      description: "Elixir wrapper for Rust based RRule parsing",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Martin Feckie"],
      links: %{
        "Github" => "https://github.com/mfeckie/rrule"
      },
      files: ["lib", "native", "README.md", "mix.exs", "checksum-*.exs"],
      exclude_patterns: [
        "native/rrule/target"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.36.0", optional: true},
      {:rustler_precompiled, "~> 0.8.0"},
      {:ex_doc, "0.37.3", only: :dev, optional: true}
    ]
  end
end
