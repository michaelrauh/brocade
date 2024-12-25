defmodule ContextKeeper do
  @pair_table_name :pairs
  @vocabulary_table_name :vocabulary

  # todo have this flush to disk on version update and load from disk on start
  def start do
    unless :ets.whereis(@pair_table_name) != :undefined do
      :ets.new(@pair_table_name, [:named_table, :set, :private])
    end
    unless :ets.whereis(@vocabulary_table_name) != :undefined do
      :ets.new(@vocabulary_table_name, [:named_table, :set, :private])
    end

    :ok
  end

  def stop do
    :ets.delete(@pair_table_name)
    :ets.delete(@vocabulary_table_name)
    :ok
  end

  def add_pairs(pairs) when is_list(pairs) do
    Enum.each(pairs, fn %Pair{first: f, second: s} ->
      :ets.insert(@pair_table_name, {f, s})
    end)
  end

  def add_vocabulary(words) when is_list(words) do
    Enum.each(words, fn word ->
      :ets.insert(@vocabulary_table_name, {word})
    end)
  end

  def get_vocabulary() do
    :ets.tab2list(@vocabulary_table_name) |> Enum.map(fn {w} -> w end)
  end

  def get_pairs() do
    :ets.tab2list(@pair_table_name) |> Enum.map(fn {f, s} -> Pair.new(f, s) end)
  end
end
