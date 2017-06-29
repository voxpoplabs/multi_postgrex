defmodule MultiPostgrex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(MultiPostgrex.Registry, []),
      supervisor(MultiPostgrex.Pool.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: MultiPostgrex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
