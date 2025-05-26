defmodule ContextDB do
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_all do
    GenServer.call(__MODULE__, :get_all)
  end

  def add_vocab(word, position) do
    GenServer.cast(__MODULE__, {:add_vocab, word, position})
  end

  def add_bitmask(key, mask) do
    GenServer.cast(__MODULE__, {:add_bitmask, key, mask})
  end

  def set_all({vocab, bitmasks}) do
    GenServer.cast(__MODULE__, {:set_all, vocab, bitmasks})
  end

  # Server Callbacks

  def init(_) do
    {:ok, {%{}, %{}}}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add_vocab, word, position}, {vocab, bitmasks}) do
    vocab = Map.put(vocab, word, position)
    {:noreply, {vocab, bitmasks}}
  end

  def handle_cast({:add_bitmask, key, mask}, {vocab, bitmasks}) do
    bitmasks = Map.put(bitmasks, key, mask)
    {:noreply, {vocab, bitmasks}}
  end

  def handle_cast({:set_all, vocab, bitmasks}, _state) do
    {:noreply, {vocab, bitmasks}}
  end
end
