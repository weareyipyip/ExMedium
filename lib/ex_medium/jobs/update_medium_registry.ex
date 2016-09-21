defmodule ExMedium.Jobs.UpdateMediumRegistry do
  require Logger

	@moduledoc """
  	Provides a method to update the `Medium.MediumUtil.MediumRegistry` state
	"""

	@doc """
  	used by `quantum` to update `Medium.MediumUtil.MediumRegistry/1` \n
	Uses `Medium.MediumUtil.RequestHandler.updateArticles/0`. \n

	Returns: `:ok`
  	"""
  def run do
    Logger.info("Running UpdateMediumRegistry Job")
    ExMedium.MediumUtil.RequestHandler.updateArticles
  end
end