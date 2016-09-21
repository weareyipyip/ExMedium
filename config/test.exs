use Mix.Config

# Do not include metadata nor timestamps in development logs
config :medium, 
	#: "https://medium.com/feed/we-are-yipyip",
	medium_url: "https://fake.test"

# Print only warnings and errors during test
config :logger, level: :warn

config :quantum, cron: [
  update_medium_registry: [
    schedule: "*/1 * * * *",
    task: {Medium.Jobs.UpdateMediumRegistry, :run},
    overlap: false
  ]
]