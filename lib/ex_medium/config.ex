defmodule ExMedium.Config do

	def getMediumURl do
		Application.get_env(:ex_medium, :medium_url, "https://medium.com/feed/we-are-yipyip")
	end

	def getInterval do
		Application.get_env(:ex_medium, :interval, 1 * 60 * 60 * 1000)
	end

end