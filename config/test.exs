use Mix.Config

# Do not include metadata nor timestamps in development logs
config :ex_medium, 
	#: "https://medium.com/feed/we-are-yipyip",
	medium_url: "https://medium.com/feed/we-are-yipyip",
	interval: 60 * 1000

# Print only warnings and errors during test
config :logger, level: :warn