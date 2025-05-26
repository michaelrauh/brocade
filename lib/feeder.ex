defmodule Feeder do
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def poll() do
    GenServer.call(__MODULE__, :poll)
  end

  @impl true
  def handle_call(:poll, _from, state) do
    {:ok, receipt, {:ortho, ortho, version}} = ResultsQueue.pop()
    ResultsDatabase.insert_orthos([ortho])
    WorkQueue.push({:ortho, ortho, version})
    ResultsQueue.ack(receipt)

    {:reply, :ok, state}
  end
  # Server (callbacks)

  @impl true
  def init(_args) do
    {:ok, %{}}
  end
end
