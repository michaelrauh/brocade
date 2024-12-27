defmodule WorkerServer do
  use GenServer

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_context_version do
    GenServer.call(__MODULE__, :get_context_version)
  end

  def get_pairs do
    GenServer.call(__MODULE__, :get_pairs)
  end

  def get_vocabulary do
    GenServer.call(__MODULE__, :get_vocabulary)
  end

  def process do
    GenServer.cast(__MODULE__, :process)
  end

  def subscribe(pid \\ self()) do
    GenServer.call(__MODULE__, {:subscribe, pid})
  end

  # Server (callbacks)

  def init(_init_arg) do
    {:ok, %{version: -1, pairs: [], vocabulary: [], subscribers: []}}
  end

  def handle_call(:get_context_version, _from, state) do
    {:reply, {:ok, state.version}, state}
  end

  def handle_cast(:process, state) do
    Task.start(fn ->
      new_state = process_work(state)
      GenServer.cast(__MODULE__, {:done_process, new_state})
    end)
    {:noreply, state}
  end

  def handle_cast({:done_process, new_state}, _old_state) do
    Enum.each(new_state.subscribers, fn sub -> send(sub, :worker_server_done) end)
    {:noreply, new_state}
  end

  def handle_call(:get_pairs, _from, state) do
    {:reply, {:ok, state.pairs}, state}
  end

  def handle_call(:get_vocabulary, _from, state) do
    {:reply, {:ok, state.vocabulary}, state}
  end

  def handle_call({:subscribe, pid}, _from, state) do
    {:reply, :ok, %{state | subscribers: [pid | state.subscribers]}}
  end

  defp update_state_from_version({_code, _top, version}, state) do
    if version != state.version do
      %{
        state
        | version: version,
          pairs: MapSet.new(ContextKeeper.get_pairs()),
          vocabulary: ContextKeeper.get_vocabulary()
      }
    else
      state
    end
  end

  defp process_work(state) do
    status_top_and_version = WorkServer.pop()
    state = update_state_from_version(status_top_and_version, state)

    case status_top_and_version do
      {:ok, top, _version} ->
        found_items = Enum.map(state.vocabulary, fn word ->
          case Ortho.add(top, word, state.pairs) do
            {:ok, new_item} ->
              new_item

            {:error, _missing_pair} ->
              nil

            {:diag, _extra_word_in_shell} ->
              nil
          end
        end)
        |> Enum.reject(fn x -> x == nil end)
        new_orthos = ContextKeeper.add_orthos(found_items)
        WorkServer.push(new_orthos)
        process_work(state)

        {:error, _top, _version} ->
          state
      end
  end
end
