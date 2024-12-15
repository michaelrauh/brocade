defmodule Ingestor do
  use GenServer
  alias Splitter
  alias Work
  alias WorkRepositoryServer

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def process_input(input) do
    splines = Splitter.splines(input)
    lines = Splitter.lines(input)

    Enum.each(splines, fn spline ->
      IO.puts("Adding spline to server: #{spline}")
      WorkRepositoryServer.add(Work.new(1, spline))
    end)

    Enum.each(lines, fn line ->
      IO.puts("Adding line to server: #{line}")
      WorkRepositoryServer.add(Work.new(1, line))
    end)
  end

  # Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:process_input, input}, state) do
    # ...existing code...
    {:noreply, state}
  end
end
