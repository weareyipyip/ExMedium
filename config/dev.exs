use Mix.Config

# Do not include metadata nor timestamps in development logs
config :ex_medium, 
	medium_url: "https://medium.com/feed/we-are-yipyip",
	interval: 60 * 1000

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
