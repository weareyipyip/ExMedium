defmodule Medium.MediumUtil.MediumRegistry do
	use GenServer
	@moduledoc """
  	`Genserver` module, starts registry, keeps state, updates state, lookup state
  	"""

	## Client API
	@doc """
	Starts the registry with the given `name` (we use module name: `Medium.MediumUtil.MediumRegistry`)
	"""
	def start_link(name) do
		GenServer.start_link(__MODULE__, :ok, name: name)
	end

	@doc """
	lookup the medium articles.
	Returns: `map` of articles.
	One article buildup: '%{title: "the title", link: "the link"}`.
	"""
	def lookupMediumArticles() do
		GenServer.call(Medium.MediumUtil.MediumRegistry, :lookupMediumArticles)
	end

	@doc """
	update the medium articles with the given `articles`, a map of articles.
	Returns: `:ok`.
	"""
	def updateMediumArticles(articles) do
		GenServer.cast(Medium.MediumUtil.MediumRegistry, {:updateMediumArticles, articles})
	end

	@doc """
	stops the registry
	"""
	def stop() do
    	GenServer.stop(Medium.MediumUtil.MediumRegistry)
  	end

	## Server Callbacks

	@doc """
	initialises registry
	sets initial state using `Medium.MediumUtil.RequestHandler.getYipyipMedium/0'
	"""
	def init(:ok) do
		mediumData = Medium.MediumUtil.RequestHandler.getYipyipMedium
		{:ok, mediumData}
	end

	@doc """
	handles `Medium.MediumUtil.MediumRegistry.lookupMediumArticles/0`
	if `:ok` Returns: 'response': map of articles
	if `:error Returns: '%{}'
	"""
	def handle_call(:lookupMediumArticles, _from, mediumData) do
		case mediumData do
			{:ok, response} -> {:reply, response, {:ok, response}}
			{:error, nil} -> case Medium.MediumUtil.RequestHandler.getYipyipMedium do
								{:ok, response} -> {:reply, response, {:ok, response}}
								{:error, _} -> {:reply, %{}, {:error, nil}}
							 end
		end
	end

	@doc """
	casts `Medium.MediumUtil.MediumRegistry.updateMediumArticles/1`
	updates state with new given `articles`
	"""
	def handle_cast({:updateMediumArticles, articles}, mediumData) do
		{:noreply, articles}
	end

end