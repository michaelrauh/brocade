defmodule ContextKeeper do
  use GenServer

  @pair_table_name :pairs
  @vocabulary_table_name :vocabulary
  @ortho_table_name :ortho
  @remediation_table_name :remediation

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def stop do
    GenServer.call(__MODULE__, :stop)
  end

  def add_pairs(pairs) when is_list(pairs) do
    GenServer.call(__MODULE__, {:add_pairs, pairs})
  end

  def add_vocabulary(words) when is_list(words) do
    GenServer.call(__MODULE__, {:add_vocabulary, words})
  end

  def add_orthos(orthos) when is_list(orthos) do
    GenServer.call(__MODULE__, {:add_orthos, orthos})
  end

  def add_remediations(remediations) when is_list(remediations) do
    GenServer.call(__MODULE__, {:add_remediations, remediations})
  end

  def get_remediations() do
    GenServer.call(__MODULE__, :get_remediations)
  end

  def get_vocabulary() do
    GenServer.call(__MODULE__, :get_vocabulary)
  end

  # todo make this not just pairs but context of any length.
  # In ortho this can be accomplished by reading back to the edge and not differentiating by length
  def get_pairs() do
    GenServer.call(__MODULE__, :get_pairs)
  end

  def get_orthos() do
    GenServer.call(__MODULE__, :get_orthos)
  end

  def remove_remediations(remediations) do
    GenServer.call(__MODULE__, {:remove_remediations, remediations})
  end

  # Server Callbacks
  def init(_) do
    :ets.new(@pair_table_name, [:named_table, :set, :public])
    :ets.new(@vocabulary_table_name, [:named_table, :set, :public])
    :ets.new(@ortho_table_name, [:named_table, :set, :public])
    :ets.new(@remediation_table_name, [:named_table, :bag, :public])
    {:ok, %{}}
  end

  def handle_call(:stop, _from, state) do
    :ets.delete(@pair_table_name)
    :ets.delete(@vocabulary_table_name)
    :ets.delete(@ortho_table_name)
    :ets.delete(@remediation_table_name)
    {:stop, :normal, :ok, state}
  end

  def handle_call({:add_pairs, pairs}, _from, state) do
    new_pairs =
      Enum.reduce(pairs, [], fn %Pair{first: f, second: s} = pair, acc ->
        case :ets.insert_new(@pair_table_name, {{f, s}, pair}) do
          true -> [pair | acc]
          false -> acc
        end
      end)

    {:reply, new_pairs, state}
  end

  def handle_call({:add_vocabulary, words}, _from, state) do
    new_words =
      Enum.reduce(words, [], fn word, acc ->
        case :ets.insert_new(@vocabulary_table_name, {word}) do
          true -> [word | acc]
          false -> acc
        end
      end)

    {:reply, new_words, state}
  end

  def handle_call({:add_orthos, orthos}, _from, state) do
    new_orthos =
      Enum.reduce(orthos, [], fn %Ortho{id: id} = ortho, acc ->
        case :ets.insert_new(@ortho_table_name, {id, ortho}) do
          true -> [ortho | acc]
          false -> acc
        end
      end)

    {:reply, new_orthos, state}
  end

  # todo remove return and look at other returns in here too
  def handle_call({:add_remediations, remediations}, _from, state) do
    new_remediations =
      Enum.reduce(remediations, [], fn {ortho, %Pair{first: f, second: s} = pair}, acc ->
        case :ets.insert(@remediation_table_name, {{f, s}, ortho.id}) do
          true -> [{ortho.id, pair} | acc]
          false -> acc
        end
      end)

    {:reply, new_remediations, state}
  end

  def handle_call(:get_remediations, _from, state) do
    remediations =
      :ets.tab2list(@remediation_table_name)
      |> Enum.map(fn {{f, s}, val} -> {val, Pair.new(f, s)} end)

    {:reply, remediations, state}
  end

  def handle_call(:get_vocabulary, _from, state) do
    vocabulary = :ets.tab2list(@vocabulary_table_name) |> Enum.map(fn {w} -> w end)
    {:reply, vocabulary, state}
  end

  def handle_call(:get_pairs, _from, state) do
    pairs = :ets.tab2list(@pair_table_name) |> Enum.map(fn {_key, val} -> val end)
    {:reply, pairs, state}
  end

  def handle_call(:get_orthos, _from, state) do
    orthos = :ets.tab2list(@ortho_table_name) |> Enum.map(fn {_key, val} -> val end)
    {:reply, orthos, state}
  end

  def handle_call({:remove_remediations, pairs}, _from, state) do
    Enum.each(pairs, fn %Pair{first: f, second: s} ->
      :ets.delete(@remediation_table_name, {f, s})
    end)

    {:reply, :ok, state}
  end
end
