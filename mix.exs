defmodule Chess.MixProject do
  use Mix.Project

  @description """
  Elixir package for playing chess game
  """

  def project do
    [
      app: :chess,
      version: "0.4.2",
      elixir: "~> 1.7",
      name: "Chess",
      description: @description,
      source_url: "https://github.com/kortirso/chess",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Anton Bogdanov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kortirso/chess"}
    ]
  end
end
