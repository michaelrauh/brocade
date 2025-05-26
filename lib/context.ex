defmodule Context do
  use GenServer
  import Bitwise

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, :ok}
  end

  def poll do
    GenServer.cast(__MODULE__, :poll)
  end

  def bitmasks do
    {_, bitmasks} = ContextDB.get_all()
    bitmasks
  end

  def get_context do
    {vocab, bitmasks} = ContextDB.get_all()
    version = map_size(vocab) + map_size(bitmasks)
    {vocab, bitmasks, version}
  end

  def handle_cast(:poll, state) do
    Task.start(fn ->
      {vocab, bitmasks} = ContextDB.get_all()
      new_state = pop_all({vocab, bitmasks})
      ContextDB.set_all(new_state)
      version = map_size(elem(new_state, 0)) + map_size(elem(new_state, 1))
      WorkQueue.push({:ortho, version})
      GenServer.cast(__MODULE__, :poll_result)
    end)
    {:noreply, state}
  end

  def handle_cast(:poll_result, state) do
    {:noreply, state}
  end

  defp pop_all({vocab, bitmasks}) do
    case ContextQueue.pop() do
      {:ok, receipt, data} ->
        case data do
          {:vocab, word} ->
            vocab = Map.put_new(vocab, word, map_size(vocab))
            bitmasks = Map.put_new(bitmasks, [word], empty_bitmask())
            ContextQueue.ack(receipt)
            pop_all({vocab, bitmasks})

          {:subphrase, subphrase} ->
            front = Enum.slice(subphrase, 0, length(subphrase) - 1)
            back = List.last(subphrase)
            position = Map.get(vocab, back)

            bitmasks =
              Map.update(
                bitmasks,
                front,
                make_bitmask_for_position(position),
                fn mask -> mask ||| make_bitmask_for_position(position) end
              )

            ContextQueue.ack(receipt)
            pop_all({vocab, bitmasks})
        end

      nil ->
        {vocab, bitmasks}
    end
  end

  def make_bitmask_for_position(position) do
    1 <<< position
  end

  def empty_bitmask() do
    0
  end
end
