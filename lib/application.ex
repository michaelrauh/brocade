defmodule Brocade.Application do
  use Application

  def start(_type, _args) do
    children = [
      {WorkServer, []},
      {WorkerServer, []},
      {Ingestor, []},
      {ContextKeeper, []}
    ]

    opts = [strategy: :one_for_one, name: Brocade.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    WorkerServer.process()
    # :observer.start()

    Profiler.profile_app()
    {:ok, pid}
  end
end
