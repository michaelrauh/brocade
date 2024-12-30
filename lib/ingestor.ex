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

  def ingest_example() do
    WorkerServer.subscribe()
    ingest(File.read!("example.txt"))
    # ingest("a b. c d. a c. b d. e f. g h. e g. f h. a e. b f. c g. d h.")
    receive do
      :worker_server_done -> :ok
    after
      5000 -> {:error, :timeout}
    end
  end

  def handle_call({:ingest, input}, _from, state) do
    pairs = Splitter.lines(input) |> Enum.map(fn [f, s] -> %Pair{first: f, second: s} end)
    vocabulary = Splitter.vocabulary(input)
    new_pairs = ContextKeeper.add_pairs(pairs)
    ContextKeeper.add_vocabulary(vocabulary)
    WorkServer.new_version()

    # todo consider making these casts
    # todo consider combining calls into the server
    # todo only pass in new pairs here
    ortho_id_pair_list = ContextKeeper.get_relevant_remediations(new_pairs)
    remediation_ortho_ids = Enum.map(ortho_id_pair_list, fn {ortho_id, _pair} -> ortho_id end)
    remediation_orthos = ContextKeeper.get_orthos_by_id(remediation_ortho_ids)
    remediation_pairs = Enum.map(ortho_id_pair_list, fn {_ortho_id, pair} -> pair end)

    WorkServer.push(remediation_orthos)
    WorkServer.push(Ortho.new())
    ContextKeeper.remove_remediations(remediation_pairs)

    {:reply, :ok, state}
  end
end
