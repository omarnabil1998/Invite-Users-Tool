import Config

config :instructor,
  gemini: [
    api_key: System.fetch_env!("GEMINI_API_KEY")
  ]

config :invite_tool, :github,
  github_token: System.fetch_env!("ACCESS_TOKEN"),
  github_repo: System.fetch_env!("REPO"),
  github_org: System.fetch_env!("ORG")
