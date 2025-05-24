defmodule Queue do
  use GenServer

  # Only needed for supervision tree
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  # Channel creation
  def create_channel(name: channel_name) do
    case Queue.Channel.start_link(name: channel_name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def push(channel, data), do: GenServer.call(channel, {:push, data})
  def pop(channel), do: GenServer.call(channel, :pop)
  def ack(receipt), do: GenServer.call(receipt.channel, {:ack, receipt.id})
  def nack(receipt), do: GenServer.call(receipt.channel, {:nack, receipt.id})

  defmodule Channel do
    use GenServer

    def start_link(opts) do
      name = Keyword.get(opts, :name)
      if name do
        GenServer.start_link(__MODULE__, %{queue: :queue.new(), pending: %{}, counter: 0}, name: name)
      else
        GenServer.start_link(__MODULE__, %{queue: :queue.new(), pending: %{}, counter: 0})
      end
    end

    def init(state), do: {:ok, state}

    def handle_call({:push, data}, _from, state) do
      queue = :queue.in(data, state.queue)
      {:reply, :ok, %{state | queue: queue}}
    end

    def handle_call(:pop, _from, %{queue: queue, pending: pending, counter: counter} = state) do
      case :queue.out(queue) do
        {{:value, data}, new_queue} ->
          id = counter + 1
          receipt = %{id: id, channel: self()}
          new_pending = Map.put(pending, id, data)
          {:reply, {:ok, receipt, data}, %{state | queue: new_queue, pending: new_pending, counter: id}}
        {:empty, _} ->
          {:reply, :empty, state}
      end
    end

    def handle_call({:ack, id}, _from, %{pending: pending} = state) do
      {:reply, :ok, %{state | pending: Map.delete(pending, id)}}
    end

    def handle_call({:nack, id}, _from, %{pending: pending, queue: queue} = state) do
      data = Map.get(pending, id)
      new_queue = :queue.in(data, queue)
      {:reply, :ok, %{state | pending: Map.delete(pending, id), queue: new_queue}}
    end
  end
end
