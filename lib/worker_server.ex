defmodule Brocade.WorkerServer do
  use GenServer

  # Client API
  def process() do
    GenServer.call(__MODULE__, :process)
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Callbacks
  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:process, _from, state) do
    IO.puts "Processing..."
    Brocade.WorkServer.pop(WorkServer)

    {:reply, :ok, state}
  end


end
