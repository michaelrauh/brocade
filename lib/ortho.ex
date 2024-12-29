defmodule Ortho do
  defstruct grid: %{}, counter: nil, id: nil

  alias Counter

  def new do
    %Ortho{counter: Counter.new()}
  end

  def example do
    :eflame.apply(
      fn ->
        # Generate a flame graph of a single function call

        context = MapSet.new()
        ortho = Ortho.new()
        {:ok, ortho} = Ortho.add(ortho, "a", context)
        {_status, _remediation} = Ortho.add(ortho, "b", context)

        context = MapSet.new([Pair.new("a", "b")])

        ortho = Ortho.new()
        {:ok, ortho} = Ortho.add(ortho, "a", context)
        {:ok, ortho} = Ortho.add(ortho, "b", context)
        {:diag, _reason} = Ortho.add(ortho, "b", context)

        context =
          MapSet.new([
            Pair.new("a", "b"),
            Pair.new("c", "d"),
            Pair.new("a", "c"),
            Pair.new("b", "d"),
            Pair.new("a", "e")
          ])

        ortho = Ortho.new()
        {:ok, ortho} = Ortho.add(ortho, "a", context)
        {:ok, ortho} = Ortho.add(ortho, "b", context)
        {:ok, ortho} = Ortho.add(ortho, "c", context)
        {:ok, ortho} = Ortho.add(ortho, "d", context)
        {:ok, _ortho} = Ortho.add(ortho, "e", context)
      end,
      []
    )
  end

  def previous_positions(position) do
    position
    |> Enum.with_index()
    |> Enum.map(&List.replace_at(position, elem(&1, 1), elem(&1, 0) - 1))
    |> Enum.filter(fn pos -> Enum.all?(pos, fn x -> x >= 0 end) end)
  end

  def pad_grid(grid) do
    Enum.reduce(grid, %{}, fn {key, value}, acc ->
      Map.put(acc, [0 | key], value)
    end)
  end

  def get_requirements(%Ortho{grid: grid, counter: counter}) do
    # todo pass useful state back out to prevent recalculating
    {next_position, _} = Counter.increment(counter)
    shell = Enum.sum(next_position)
    forbidden = Map.get(calculate_diagonals(grid), shell, MapSet.new())

    grid = optionally_pad_grid(grid, next_position)

    required = find_all_pair_prefixes(grid, next_position)

    {forbidden, required}
  end

  # Todo remove checks
  def add(%Ortho{grid: grid, counter: counter} = ortho, item, context) do
    {next_position, new_counter} = Counter.increment(counter)
    shell = Enum.sum(next_position)
    forbidden = Map.get(calculate_diagonals(grid), shell, MapSet.new())

    if MapSet.member?(forbidden, item) do
      {:diag, {shell, item}}
    else
      grid = optionally_pad_grid(grid, next_position)

      case search_for_missing_pair(grid, next_position, context, item) do
        nil ->
          new_grid = Map.put(grid, next_position, item)
          {:ok, %Ortho{ortho | grid: new_grid, counter: new_counter, id: calculate_id(new_grid)}}

        missing_pair ->
          {:error, missing_pair}
      end
    end
  end

  defp search_for_missing_pair(grid, next_position, context, item) do
    previous_positions(next_position)
    |> Enum.map(&Map.get(grid, &1))
    |> Enum.map(&Pair.new(&1, item))
    |> Enum.find(&(not MapSet.member?(context, &1)))
  end

  defp find_all_pair_prefixes(grid, next_position) do
    previous_positions(next_position)
    |> Enum.map(&Map.get(grid, &1))
  end

  defp optionally_pad_grid(grid, next_position) do
    if Enum.count(List.first(Map.keys(grid), [0, 0])) != Enum.count(next_position) do
      pad_grid(grid)
    else
      grid
    end
  end

  # todo memoize the parts of this that are common to all orthos
  defp calculate_diagonals(grid) do
    Enum.reduce(Map.keys(grid), %{}, fn key, acc ->
      distance = Enum.sum(key)

      Map.update(
        acc,
        distance,
        MapSet.new([Map.get(grid, key)]),
        &MapSet.put(&1, Map.get(grid, key))
      )
    end)
  end

  # todo speed this up
  defp calculate_id(grid) do
    dimension = Enum.count(List.first(Map.keys(grid)))
    permutations = permutations(Enum.to_list(0..(dimension - 1)))

    canonical_forms =
      for perm <- permutations do
        grid
        |> Enum.map(fn {pos, val} ->
          new_pos =
            Enum.with_index(pos)
            |> Enum.sort_by(fn {_elem, index} -> Enum.find_index(perm, fn x -> x == index end) end)
            |> Enum.map(&elem(&1, 0))

          {new_pos, val}
        end)
        |> Enum.sort()
      end

    canonical_form = Enum.min(canonical_forms)

    :crypto.hash(:sha256, :erlang.term_to_binary(canonical_form))
    |> Base.encode16()
  end

  defp permutations([]), do: [[]]

  defp permutations(list) do
    for x <- list, y <- permutations(list -- [x]), do: [x | y]
  end
end
