defmodule ExMedium.MediumUtil.MediumRegistry do
	use GenServer
	require Logger
	@moduledoc """
  	`Genserver` module, starts registry, keeps state, updates state, lookup state
  	"""

	## Client API
	@doc """
	Starts the registry with the given `name` (we use module name: `ExMedium.MediumUtil.MediumRegistry`)
	__MODULE__ deffinieert plaats van server callbacks (current moduel)
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
		GenServer.call(ExMedium.MediumUtil.MediumRegistry, :lookupMediumArticles)
	end

	@doc """
	update the medium articles with the given `articles`, a map of articles.
	Returns: `:ok`.
	"""
	def updateMediumArticles(articles) do
		GenServer.cast(ExMedium.MediumUtil.MediumRegistry, {:updateMediumArticles, articles})
	end

	@doc """
	stops the registry
	"""
	def stop() do
    	GenServer.stop(ExMedium.MediumUtil.MediumRegistry)
  	end

  	@doc """
	schedule to update registry
	"""
  	defp schedule_work do
		Process.send_after(self(), :work, ExMedium.Config.getInterval)
	end

	## Server Callbacks

	@doc """
	initialises registry
	sets initial state using `ExMedium.MediumUtil.RequestHandler.getYipyipMedium/0'
	"""
	def init(:ok) do
		schedule_work
		mediumData = ExMedium.MediumUtil.RequestHandler.getYipyipMedium
		{:ok, mediumData}
	end

	@doc """
	handles `Medium.MediumUtil.ExMediumRegistry.lookupMediumArticles/0`
	if `:ok` Returns: 'response': map of articles
	if `:error Returns: '%{}'
	"""
	def handle_call(:lookupMediumArticles, _from, mediumData) do
		case mediumData do
			{:ok, response} -> {:reply, response, {:ok, response}}
			{:error, nil} -> case ExMedium.MediumUtil.RequestHandler.getYipyipMedium do
								{:ok, response} -> {:reply, response, {:ok, response}}
								{:error, _} -> {:reply, %{}, {:error, nil}}
							 end
		end
	end

	@doc """
	casts `ExMedium.MediumUtil.MediumRegistry.updateMediumArticles/1`
	updates state with new given `articles`
	"""
	def handle_cast({:updateMediumArticles, articles}, mediumData) do
		{:noreply, articles}
	end

	@doc """
	executes `ExMedium.MediumUtil.RequestHandler.updateArticles/0` to update state
	"""
	def handle_info(:work, state) do
	    Logger.info("Running UpdateMediumRegistry Job")
    	ExMedium.MediumUtil.RequestHandler.updateArticles
    	schedule_work
	    {:noreply, state}
	 end

end