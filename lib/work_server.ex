defmodule WorkServer do
  use GenServer

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def push(pid, work) do
    GenServer.call(pid, {:push, work})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  def init(_init_arg) do
    {:ok, []}
  end

  def handle_call({:push, work}, _from, state) do
    new_state = [work | state]
    {:reply, :ok, new_state}
  end

  def handle_call(:pop, _from, [top | rest]) do
    {:reply, {:ok, top}, rest}
  end
end
