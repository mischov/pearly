defmodule Pearly.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :pearly,
     name: "Pearly",
     version: @version,
     description: description(),
     elixir: "~> 1.3",
     deps: deps(),
     package: package(),
     source_url: "https://github.com/mischov/pearly",
     docs: [main: "Pearly"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:rustler] ++ Mix.compilers(),
     rustler_crates: rustler_crates()]
  end

  def rustler_crates do
    [pearly_nif: [
        path: "native/pearly_nif",
        cargo: :system,
        default_features: false,
        features: [],
        mode: :release,
        # mode: (if Mix.env == :prod, do: :release, else: :debug),
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:rustler, "~> 0.10.1"},

     # docs
     {:ex_doc, "~> 0.14", only: :docs},
     {:markdown, github: "devinus/markdown", only: :docs}]
  end

  defp description do
    """
    Pearly is a library for syntax highlighting using Sublime Text syntax definitions.
    """
  end

  defp package do
    [maintainers: ["Mischov"],
     licenses: ["MIT"],
     files: ["lib", "native", "mix.exs", "README.md", "LICENSE"],
     links: %{"GitHub" => "https://github.com/mischov/pearly"}]
  end
end
