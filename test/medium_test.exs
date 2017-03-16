defmodule ExMediumTest do
  use ExUnit.Case
  doctest ExMedium

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "the false link" do
  	if Application.get_env(:ex_medium, :medium_url) == "https://fake" do
  		assert ExMedium.MediumUtil.RequestHandler.getYipyipMedium == {:error, nil}
  	end
  end

end
