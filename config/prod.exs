use Mix.Config

# Do not include metadata nor timestamps in development logs
config :ex_medium, 
	medium_url: "https://medium.com/feed/we-are-yipyip"

# Do not print debug messages in production
config :logger, level: :info

config :quantum, cron: [
  update_medium_registry: [
    schedule: "* */1 * * *",
    task: {ExMedium.Jobs.UpdateMediumRegistry, :run},
    overlap: false
  ]
]