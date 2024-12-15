defmodule Ingestor do
  use GenServer
  alias Splitter
  alias Work
  alias WorkRepositoryServer

  # Client API
  def start_link(_) do
    children = [
      {WorkRepositoryServer, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def process_input(work), do: GenServer.cast(__MODULE__, {:process_input, work})

  # Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:process_input, input}, state) do
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
    {:noreply, state}
  end
end
