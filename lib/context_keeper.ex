defmodule ContextKeeper do
  @table_name :context_keeper

  # todo have this flush to disk on version update and load from disk on start
  def start do
    unless :ets.whereis(@table_name) != :undefined do
      :ets.new(@table_name, [:named_table, :set, :private])
    end

    :ok
  end

  def stop do
    :ets.delete(@table_name)
    :ok
  end

  def add(%Pair{first: f, second: s}) do
    :ets.insert(@table_name, {f, s})
  end

  def add(pairs) when is_list(pairs) do
    Enum.each(pairs, fn %Pair{first: f, second: s} ->
      :ets.insert(@table_name, {f, s})
    end)
  end

  def get() do
    :ets.tab2list(@table_name) |> Enum.map(fn {f, s} -> Pair.new(f, s) end)
  end
end
