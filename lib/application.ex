defmodule Brocade.Application do
  use Application

  def start(_type, _args) do
    children = [
      {WorkServer, []},
      {WorkerServer, []},
      {Ingestor, []},
      {ContextKeeper, []}
    ]

    # todo scale workers

    opts = [strategy: :one_for_one, name: Brocade.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
    # Ingestor.ingest(File.read!("example.txt"))
    WorkerServer.process()

    {:ok, pid}
  end
end
