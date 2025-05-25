defmodule ContextQueue do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, channel} = Queue.create_channel(name: ContextQueue.Channel)
    {:ok, channel}
  end

  def push(item) do
    GenServer.call(__MODULE__, {:push, item})
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  def ack(receipt) do
    Queue.ack(receipt)
  end

  def nack(receipt) do
    Queue.nack(receipt)
  end

  def child_spec(init_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]}
    }
  end

  def handle_call({:push, item}, _from, channel) do
    Queue.push(channel, item)
    {:reply, :ok, channel}
  end

  def handle_call(:pop, _from, channel) do
    case Queue.pop(channel) do
      {:ok, receipt, item} ->
        {:reply, {:ok, receipt, item}, channel}
      :empty ->
        {:reply, nil, channel}
    end
  end
end
