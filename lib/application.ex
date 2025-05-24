defmodule Brocade.Application do
  use Application

  def start(_type, _args) do
    children = [
      {WorkServer, []},
      {WorkerServer, []},
      {Ingestor, []},
      {ContextKeeper, []}
    ]

    Counter.start()
    opts = [strategy: :one_for_one, name: Brocade.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
    Ingestor.ingest(File.read!("example.txt"))
    WorkerServer.process()
    :observer.start()
    # :timer.sleep(1000)
    # Ingestor.ingest(File.read!("example2.txt"))
    # :timer.sleep(2000)
    # Ingestor.ingest(File.read!("example3.txt"))

    {:ok, pid}
  end
end
