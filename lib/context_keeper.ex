defmodule ContextKeeper do
  @pair_table_name :pairs
  @vocabulary_table_name :vocabulary
  @ortho_table_name :ortho
  @remediation_table_name :remediation

  # todo have this flush to disk on version update and load from disk on start
  def start do
    unless :ets.whereis(@pair_table_name) != :undefined do
      :ets.new(@pair_table_name, [:named_table, :set, :private])
    end

    unless :ets.whereis(@vocabulary_table_name) != :undefined do
      :ets.new(@vocabulary_table_name, [:named_table, :set, :private])
    end

    unless :ets.whereis(@ortho_table_name) != :undefined do
      :ets.new(@ortho_table_name, [:named_table, :set, :private])
    end

    unless :ets.whereis(@remediation_table_name) != :undefined do
      :ets.new(@remediation_table_name, [:named_table, :set, :private])
    end

    :ok
  end

  def stop do
    :ets.delete(@pair_table_name)
    :ets.delete(@vocabulary_table_name)
    :ets.delete(@ortho_table_name)
    :ets.delete(@remediation_table_name)
    :ok
  end

  def add_pairs(pairs) when is_list(pairs) do
    Enum.reduce(pairs, [], fn %Pair{first: f, second: s} = pair, acc ->
      case :ets.insert_new(@pair_table_name, {{f, s}, pair}) do
        true -> [pair | acc]
        false -> acc
      end
    end)
  end

  def add_vocabulary(words) when is_list(words) do
    Enum.reduce(words, [], fn word, acc ->
      case :ets.insert_new(@vocabulary_table_name, {word}) do
        true -> [word | acc]
        false -> acc
      end
    end)
  end

  def add_orthos(orthos) when is_list(orthos) do
    Enum.reduce(orthos, [], fn %Ortho{id: id} = ortho, acc ->
      case :ets.insert_new(@ortho_table_name, {id, ortho}) do
        true -> [ortho | acc]
        false -> acc
      end
    end)
  end

  def add_remediations(remediations) when is_list(remediations) do
    Enum.reduce(remediations, [], fn {ortho, %Pair{first: f, second: s} = remediation}, acc ->
      case :ets.insert_new(@remediation_table_name, {{f, s}, ortho}) do
        true -> [{ortho, remediation} | acc]
        false -> acc
      end
    end)
  end

  def get_remediations() do
    :ets.tab2list(@remediation_table_name)
    |> Enum.map(fn {{f, s}, val} -> {val, Pair.new(f, s)} end)
  end

  def get_vocabulary() do
    :ets.tab2list(@vocabulary_table_name) |> Enum.map(fn {w} -> w end)
  end

  def get_pairs() do
    :ets.tab2list(@pair_table_name) |> Enum.map(fn {_key, val} -> val end)
  end

  def get_orthos() do
    :ets.tab2list(@ortho_table_name) |> Enum.map(fn {_key, val} -> val end)
  end

  def get_relevant_context_for_remediations(remediations) do
    remediations
    |> Enum.filter(fn %Pair{first: f, second: s} ->
      :ets.member(@pair_table_name, {f, s})
    end)
  end

  def remove_remediations(remediations) do
    Enum.each(remediations, fn %Pair{first: f, second: s} ->
      :ets.delete(@remediation_table_name, {f, s})
    end)
  end
end
