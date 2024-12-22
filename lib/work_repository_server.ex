defmodule WorkRepositoryServer do
  use GenServer

  alias WorkRepository

  @persist_file "work_repository_backup"

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def clear_and_stop, do: GenServer.call(__MODULE__, :clear_and_stop)

  def add(work), do: GenServer.cast(__MODULE__, {:add, work})

  def get_largest_and_smallest, do: GenServer.call(__MODULE__, :get_largest_and_smallest)

  def complete(smallest, largest, additional) do
    GenServer.cast(__MODULE__, {:complete, smallest, largest, additional})
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  ## Callbacks

  @impl true
  def init(_args) do
    state =
      if File.exists?(@persist_file) do
        File.read!(@persist_file) |> :erlang.binary_to_term()
      else
        %WorkRepository{}
      end

    :timer.send_interval(5000, :save_to_disk)
    {:ok, state}
  end

  @impl true
  def handle_cast({:add, work}, repo) do
    {:noreply, WorkRepository.add(repo, work)}
  end

  @impl true
  def handle_cast({:complete, smallest, largest, additional}, repo) do
    {:noreply, WorkRepository.complete(repo, smallest, largest, additional)}
  end

  @impl true
  def handle_call(:get_largest_and_smallest, _from, repo) do
    case WorkRepository.get_largest_and_smallest(repo) do
      {:ok, smallest, largest, updated_repo} ->
        {:reply, {:ok, smallest, largest}, updated_repo}

      {:same, work, updated_repo} ->
        {:reply, {:same, work}, updated_repo}

      {:empty, updated_repo} ->
        {:reply, {:empty}, updated_repo}
    end
  end

  @impl true
  def handle_call(:clear_and_stop, _from, _state) do
    if File.exists?(@persist_file) do
      File.rm!(@persist_file)
    end

    {:stop, :normal, :ok, %{}}
  end

  @impl true
  def handle_info(:save_to_disk, repo) do
    File.write!(@persist_file, :erlang.term_to_binary(repo))
    {:noreply, repo}
  end
end
