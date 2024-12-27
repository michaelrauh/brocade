defmodule Ingestor do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def ingest(input) do
    GenServer.call(__MODULE__, {:ingest, input})
  end

  def handle_call({:ingest, input}, _from, state) do
    pairs = Splitter.lines(input) |> Enum.map(fn [f, s] -> %Pair{first: f, second: s} end)
    vocabulary = Splitter.vocabulary(input)
    relevant_remediation_pairs = ContextKeeper.get_relevant_context_for_remediations(pairs)
    ContextKeeper.add_pairs(pairs)
    ContextKeeper.add_vocabulary(vocabulary)
    WorkServer.new_version()
    all_remediations = ContextKeeper.get_remediations()

    # todo push this filter down into the context keeper
    remediations =
      Enum.filter(all_remediations, fn {_, pair} ->
        Enum.member?(relevant_remediation_pairs, pair)
      end)

    WorkServer.push(remediations)
    WorkServer.push(Ortho.new())
    ContextKeeper.remove_remediations(relevant_remediation_pairs)

    {:reply, :ok, state}
  end
end
