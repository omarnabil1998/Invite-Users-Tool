import Config

config :instructor,
  adapter: Instructor.Adapters.Gemini,
  max_retries: 2
