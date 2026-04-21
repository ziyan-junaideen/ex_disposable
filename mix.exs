defmodule ExDisposable.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_disposable,
      version: "0.5.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "0.40.1", only: :dev, runtime: false},
      {:ecto, "~> 3.13", optional: true}
    ]
  end

  defp description do
    "Disposable email domain checks with optional Ecto changeset validation."
  end

  defp package do
    [
      files: ~w(lib priv mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ziyan-junaideen/ex_disposable",
        "Upstream blocklist" =>
          "https://github.com/disposable-email-domains/disposable-email-domains"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_url: "https://github.com/ziyan-junaideen/ex_disposable",
      groups_for_modules: [
        {"Core", [ExDisposable]},
        {"Ecto", [ExDisposable.Ecto.Changeset]},
        {"Mix Tasks", [Mix.Tasks.ExDisposable.SyncBlocklist]}
      ]
    ]
  end
end
