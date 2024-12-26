defmodule Brocade.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Brocade.WorkServer, []},

      Supervisor.child_spec(
        {Brocade.WorkerServer, []},
        id: :worker_server_1
      ),
    ]
    opts = [strategy: :one_for_one, name: Brocade.Supervisor]
    ContextKeeper.start()
    Supervisor.start_link(children, opts)
  end
end
