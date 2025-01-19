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

  # make this run on startup and integrate a way to subscribe and request response in one go for testing
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

  def handle_cast(:process, state) do
    Task.start(fn ->
      new_state = process_work(state)
      GenServer.cast(__MODULE__, {:done_process, new_state})
    end)

    {:noreply, state}
  end

  def handle_cast({:done_process, new_state}, _old_state) do
    for sub <- new_state.subscribers, do: send(sub, :worker_server_done)
    {:noreply, new_state}
  end

  def handle_call(:get_context_version, _from, state) do
    {:reply, {:ok, state.version}, state}
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

  def handle_info(:retry_process, state) do
    process()
    {:noreply, state}
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

  # a note on eventual consistency: It's ok if this asks if an ortho has been found and gets a false negative. It will just be replayed.
  # The only place where consistency must be strong is on ingestion. These can even be handled in batches if desired.

  # this can be faster - offhand, it would be faster to pull prefixes out of a DB and check a set for what
  # comes after rather than checking each thing. There may be more compact ways to store remediations as well
  # given that remediations generated in a single loop will all have the same prefixes
  # also appending to lists is slow
  defp process_work(state) do
    # right now if the server dies popped messages will be lost
    status_top_and_version = WorkServer.pop()
    state = update_state_from_version(status_top_and_version, state)

    case status_top_and_version do
      {:ok, top, _version} ->
        {forbidden, required} = Ortho.get_requirements(top)
        working_vocabulary = Enum.reject(state.vocabulary, &MapSet.member?(forbidden, &1))

        {candidates, remediations} =
          Enum.reduce(working_vocabulary, {[], []}, fn word, {cands, rems} ->
            missing_required =
              Enum.find(required, &(!MapSet.member?(state.pairs, &1 ++ [word])))
            if missing_required do
              {cands, [{top, missing_required ++ [word]} | rems]}
            else
              {[word | cands], rems}
            end
          end)

        new_orthos =
          Enum.flat_map(candidates, fn word ->
            Ortho.add(top, word)
          end)

        new_orthos = ContextKeeper.add_orthos(new_orthos)

        # Enum.each(new_orthos, fn ortho ->
        #   unless Enum.all?(ortho.shape, &(&1 == 2)) do
        #     IO.inspect(ortho, label: "Ortho with non-2 shape")
        #   end
        # end)

        ContextKeeper.add_remediations(remediations)
        WorkServer.push(new_orthos)
        process_work(state)

      {:empty, _top, _version} ->
        # IO.inspect("queue is empty...")
        Process.send_after(WorkerServer, :retry_process, 5_000)
        state
    end
  end
end
