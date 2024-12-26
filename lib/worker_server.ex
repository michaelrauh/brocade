defmodule WorkerServer do
  use GenServer

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_context_version do
    GenServer.call(__MODULE__, :get_context_version)
  end

  # Server (callbacks)

  def init(_init_arg) do
    {:ok, -1}
  end

  def handle_call(:get_context_version, _from, version) do
    {:reply, {:ok, version}, version}
  end

end
