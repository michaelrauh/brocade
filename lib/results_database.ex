defmodule ResultsDatabase do
  use GenServer

  # State: %{orthos: %{id => ortho}, remediations: %{{ortho_id, version} => {ortho, [string], version}}}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{
      orthos: %{},
      remediations: %{}
    }, name: __MODULE__)
  end

  # Insert orthos, return only new ones
  def insert_orthos(orthos) do
    GenServer.call(__MODULE__, {:insert_orthos, orthos})
  end

  # Insert remediations (list of {ortho, [string], version})
  def insert_remediations(remediations) do
    GenServer.cast(__MODULE__, {:insert_remediations, remediations})
  end

  # Get latest version among all remediations
  def get_latest_version do
    GenServer.call(__MODULE__, :get_latest_version)
  end

  # Get up to 100 remediations with version < given version
  def get_out_of_date(version) do
    GenServer.call(__MODULE__, {:get_out_of_date, version})
  end

  # Update given remediations to new version
  def update_remediations(remediations, new_version) do
    GenServer.cast(__MODULE__, {:update_remediations, remediations, new_version})
  end

  # Server callbacks

  def init(state), do: {:ok, state}

  def handle_call({:insert_orthos, orthos}, _from, state) do
    new_orthos =
      orthos
      |> Enum.filter(fn ortho -> Map.get(state.orthos, ortho.id) == nil end)

    new_orthos_map =
      new_orthos
      |> Enum.map(&{&1.id, &1})
      |> Enum.into(%{})

    orthos = Map.merge(state.orthos, new_orthos_map)
    {:reply, new_orthos, %{state | orthos: orthos}}
  end

  def handle_call(:get_latest_version, _from, state) do
    latest =
      state.remediations
      |> Map.values()
      |> Enum.map(fn {_, _, version} -> version end)
      |> Enum.max(fn -> nil end)
    {:reply, latest, state}
  end

  def handle_call({:get_out_of_date, version}, _from, state) do
    out_of_date =
      state.remediations
      |> Map.values()
      |> Enum.filter(fn {_, _, v} -> v < version end)
      |> Enum.take(100)
    {:reply, out_of_date, state}
  end

  def handle_cast({:insert_remediations, remediations}, state) do
    new_remediations =
      Enum.reduce(remediations, state.remediations, fn {ortho, strings, version}, acc ->
        Map.put(acc, {ortho.id, version}, {ortho, strings, version})
      end)

    {:noreply, %{state | remediations: new_remediations}}
  end

  def handle_cast({:update_remediations, remediations, new_version}, state) do
    updated =
      Enum.reduce(remediations, state.remediations, fn {ortho, strings, _old_version}, acc ->
        # Remove all old versions for this ortho
        acc =
          acc
          |> Enum.reject(fn {{oid, _}, _} -> oid == ortho.id end)
          |> Enum.into(%{})
        # Insert new version
        Map.put(acc, {ortho.id, new_version}, {ortho, strings, new_version})
      end)
    {:noreply, %{state | remediations: updated}}
  end
end
