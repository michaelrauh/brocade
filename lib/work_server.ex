defmodule WorkServer do
  use GenServer

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def new_version(pid) do
    GenServer.call(pid, :new_version)
  end

  def push(pid, work) when is_list(work) do
    GenServer.call(pid, {:push, work})
  end

  def push(pid, work) do
    GenServer.call(pid, {:push, [work]})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  def init(_init_arg) do
    {:ok, {[], 0}}
  end

  def handle_call({:push, work}, _from, {stack, version}) do
    {:reply, :ok, {work ++ stack, version}}
  end

  def handle_call(:pop, _from, {[top | rest], version}) do
    {:reply, {:ok, top, version}, {rest, version}}
  end

  def handle_call(:pop, _from, {[], version}) do
    {:reply, {:error, nil, version}, {[], version}}
  end

  def handle_call(:new_version, _from, {stack, version}) do
    {:reply, :ok, {stack, version + 1}}
  end
end
