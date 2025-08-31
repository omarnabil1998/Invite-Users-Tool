import Config

config :instructor,
  adapter: Instructor.Adapters.Gemini,
  max_retries: 2,
  gemini: [
    api_key: "AIzaSyCGmxaeP4Oj_I8ockafX5xP2-_ZoB5vJ_E"
  ]
