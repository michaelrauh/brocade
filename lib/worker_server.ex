defmodule WorkerServer do
  use GenServer

  def start_link(name, init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: name)
  end

  def init(_init_arg) do
    {:ok, -1}
  end

  def get_context_version() do
    GenServer.call(:worker_server, {:get_context_version})
  end

  def handle_call({:get_context_version}, _from, context_version) do
    {:reply, context_version, context_version}
  end
end
