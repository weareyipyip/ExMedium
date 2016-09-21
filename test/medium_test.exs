defmodule MediumTest do
  use ExUnit.Case
  doctest Medium

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "the link" do
  	if Application.get_env(:medium, :medium_url) == "https://fake" do
  		assert Medium.MediumUtil.RequestHandler.getYipyipMedium == {:error, nil}
  	end
  end
end
