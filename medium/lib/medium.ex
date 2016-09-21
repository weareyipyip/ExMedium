defmodule Medium do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Medium.Worker.start_link(arg1, arg2, arg3)
      # worker(Medium.Worker, [arg1, arg2, arg3]),
      worker(Medium.MediumUtil.MediumRegistry, [Medium.MediumUtil.MediumRegistry]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Medium.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
