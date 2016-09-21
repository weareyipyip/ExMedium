defmodule ExMedium.MediumUtil.RequestHandler do
	require Logger

	@moduledoc """
  	Provides a methods to load the get the medium api data, process it and update the state of the `Medium.MediumUtil.MediumRegistry`

  	"""
	@yipyipMediumUrl Application.get_env(:ex_medium, :medium_url)

	@doc """
	HTTPoisen to get Medium Api XML. \n
	If response `:ok` Returns `{:ok, response}` uses `Medium.MediumUtil.RequestHandler.process_response/1` to process response data. \n
	If response `:error` Returns: `{:error, :nil}`.

  	"""
	def getYipyipMedium do
		case HTTPoison.get(@yipyipMediumUrl) do
			{:ok, response} -> process_response(response)
			{:error, _response} -> {:error, nil}
		end
	end

	@doc ~S"""
	Parses given `response` XML, using `Exml`. \n
	Looks for `<item>` nodes which contain a `<title>` and a `<link>`
	Returns: `map` of articles. \n
	One article buildup: '%{title: "the title", link: "the link"}`

	## Examples

		iex> Medium.MediumUtil.RequestHandler.process_response(%{body: "<node>text</node>"})
		{:error, nil}

		iex> Medium.MediumUtil.RequestHandler.process_response(%{body: "This is text"})
		{:error, nil}

		iex> Medium.MediumUtil.RequestHandler.process_response(%{somethingElse: "This is text"})
		{:error, nil}

		iex> Medium.MediumUtil.RequestHandler.process_response(%{})
		{:error, nil}

		iex> Medium.MediumUtil.RequestHandler.process_response("not a map")
		{:error, nil}

		iex> Medium.MediumUtil.RequestHandler.process_response(%{body: "<body><item><title>This is a title</title><link>This is a link</link></item><item><title>This is a title 2</title><link>This is a link2</link></item></body>"})
		{:ok, %{1 => %{link: "This is a link", title: "This is a title"}, 2 => %{link: "This is a link2", title: "This is a title 2"}}}

		iex> Medium.MediumUtil.RequestHandler.process_response(%{body: "<item><title>This is a title</title></item>"})
		{:ok, %{1 => %{link: nil, title: "This is a title"}}}
		
  	"""
	def process_response(response) do
		case is_map(response) && Map.has_key?(response, :body) do
			true -> try do
						parsed_body = Exml.parse response.body
						case Exml.get(parsed_body, "//item/title") do
							nil -> {:error, nil}
							[_head | _tail] -> count = length(Exml.get(parsed_body, "//item/title"))
								map = Enum.reduce(1..count, %{},  fn x, acc -> 
									Map.put(acc, x, %{title: Exml.get(parsed_body, "//item[#{x}]/title"), link: Exml.get(parsed_body, "//item[#{x}]/link")})
								end)
								{:ok, map}
							_is_binary -> {:ok, Map.put(%{}, 1, %{title: Exml.get(parsed_body, "//item/title"), link: Exml.get(parsed_body, "//item/link")})}
						end
					catch 
						:exit, _ -> {:error, nil}
					end
			false -> {:error, nil}
		end
	end

	@doc """
	Updates articles in `Medium.MediumUtil.MediumRegistry` through `Medium.MediumUtil.MediumRegistry.updateMediumArticles/1`. \n
	If `:ok` updates the articles
	if `:error` keeps the old data \n
	Returns: `:ok` or logs warning  \n
  	"""
	def updateArticles do
		case getYipyipMedium do
			{:ok, response} -> ExMedium.MediumUtil.MediumRegistry.updateMediumArticles({:ok, response})
			{:error, nil} -> Logger.warn("Error retrieving new data, leaving old data in place")
		end
	end
end