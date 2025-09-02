defmodule InviteTool.MixProject do
  use Mix.Project

  def project do
    [
      app: :invite_tool,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  defp releases do
  [
    invite_tool: [
      steps: [:assemble, &Burrito.wrap/1],
      burrito: [
        targets: [
          linux:   [os: :linux,  cpu: :x86_64]
        ]
      ]
    ]
  ]
end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {InviteTool, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:instructor, "~> 0.1.0"},
      {:burrito, "~> 1.3.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
