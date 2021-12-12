defmodule Bonfire.Data.Social.MixProject do
  use Mix.Project

  def project do
    [
      app: :bonfire_data_social,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "Interactions and relationships between users",
      homepage_url: "https://github.com/bonfire-networks/bonfire_data_social",
      source_url: "https://github.com/bonfire-networks/bonfire_data_social",
      package: [
        licenses: ["MPL 2.0"],
        links: %{
          "Repository" => "https://github.com/bonfire-networks/bonfire_data_social",
          "Hexdocs" => "https://hexdocs.pm/bonfire_data_social",
        },
      ],
      docs: [
        main: "readme", # The first page to display from the docs
        extras: ["README.md"], # extra pages to include
      ],
      deps: deps()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:pointers, [env: :prod, git: "https://github.com/bonfire-networks/pointers", branch: "main", override: true]},
      {:ecto_materialized_path, [env: :prod, git: "https://github.com/bonfire-networks/ecto_materialized_path", branch: "master", override: true]}
    ]
  end

end
