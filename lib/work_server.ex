defmodule WorkServer do
  use GenServer

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def new_version do
    GenServer.call(__MODULE__, :new_version)
  end

  def push(work) when is_list(work) do
    GenServer.call(__MODULE__, {:push, work})
  end

  def push(work) do
    GenServer.call(__MODULE__, {:push, [work]})
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  # Server (callbacks)

  def init(_init_arg) do
    {:ok, {[], 0}}
  end

  def handle_call({:push, work}, _from, {stack, version}) do
    {:reply, :ok, {work ++ stack, version}}
  end

  def handle_call(:pop, _from, {[top | rest], version}) do
    IO.inspect(length(rest) + 1)
    {:reply, {:ok, top, version}, {rest, version}}
  end

  # todo change error to empty
  def handle_call(:pop, _from, {[], version}) do
    {:reply, {:error, nil, version}, {[], version}}
  end

  def handle_call(:new_version, _from, {stack, version}) do
    {:reply, :ok, {stack, version + 1}}
  end
end
