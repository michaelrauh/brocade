defmodule Ingestor do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.merge([name: __MODULE__], opts))
  end

  # Public API
  def push(text) do
    GenServer.call(__MODULE__, {:push, text})
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:push, text}, _from, state) do
    vocab = Splitter.vocabulary(text)
    Enum.each(vocab, fn word ->
      ContextQueue.push({:vocab, word})
    end)

    phrases = Splitter.phrases(text)
    Enum.each(phrases, fn p ->
      ContextQueue.push({:phrase, p})
    end)
    Context.poll()

    {:reply, :accepted, state}
  end
end
