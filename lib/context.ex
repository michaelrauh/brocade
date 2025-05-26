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

  def handle_cast(:poll, state) do
    # Offload pop_all to a Task
    Task.start(fn ->
      new_state = pop_all(state)
      GenServer.cast(__MODULE__, {:poll_result, new_state})
    end)
    {:noreply, state}
  end

  def handle_cast({:poll_result, new_state}, _old_state) do
    {:noreply, new_state}
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
