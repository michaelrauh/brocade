defmodule WorkServer do
  use GenServer

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add(pid, work) do
    GenServer.call(pid, {:add, work})
  end

  # Server (callbacks)

  def init(_init_arg) do
    {:ok, []}
  end

  def handle_call({:add, work}, _from, state) do
    new_state = [work | state]
    {:reply, :ok, new_state}
  end
end
