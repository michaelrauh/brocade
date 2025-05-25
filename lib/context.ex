defmodule Context do
  use GenServer
  import Bitwise

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, {%{}, %{}}}
  end

  def poll do
    GenServer.cast(__MODULE__, :poll)
  end

  def bitmasks do
    GenServer.call(__MODULE__, :bitmasks)
  end

  def handle_call(:bitmasks, _from, state = {_, bitmasks}) do
    {:reply, bitmasks, state}
  end

  def handle_cast(:poll, {vocab, bitmasks}) do
    {:noreply, pop_all({vocab, bitmasks})}
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
            front = List.delete_at(subphrase, -1)
            back = List.last(subphrase)
            bitmasks = Map.update(bitmasks, front, empty_bitmask(), fn mask ->
              position = Map.get(vocab, back)
              mask ||| make_bitmask_for_position(position)
            end)
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
