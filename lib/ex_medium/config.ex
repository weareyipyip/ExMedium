defmodule ExMedium.Config do

	def getMediumURl do
		Application.get_env(:ex_medium, :medium_url, "https://medium.com/feed/we-are-yipyip")
	end

end