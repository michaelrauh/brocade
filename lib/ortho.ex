defmodule Ortho do
  defstruct grid: %{}, counter: nil, id: nil

  alias Counter

  def new do
    %Ortho{
      counter: Counter.new()
    }
  end

  # todo consider calculating some of these in advance or memoizing them

  def previous_positions(position) do
    position
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> List.replace_at(position, index, value - 1) end)
    |> Enum.filter(fn pos -> Enum.all?(pos, &(&1 >= 0)) end)
  end

  def pad_grid(grid) do
    grid
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      new_key = [0 | key]
      Map.put(acc, new_key, value)
    end)
  end

  def add(%Ortho{grid: grid, counter: counter} = ortho, item, context) do
    diagonals =
      grid
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, acc ->
        distance = Enum.sum(key)

        Map.update(
          acc,
          distance,
          MapSet.new([Map.get(grid, key)]),
          &MapSet.put(&1, Map.get(grid, key))
        )
      end)

    {next_position, new_counter} = Counter.increment(counter)
    shell = Enum.sum(next_position)
    forbidden = Map.get(diagonals, shell, MapSet.new())

    if MapSet.member?(forbidden, item) do
      {:diag, {shell, item}}
    else
      grid =
        if Map.keys(grid) |> List.first([0, 0]) |> Enum.count() != Enum.count(next_position) do
          pad_grid(grid)
        else
          grid
        end

      previous_positions = previous_positions(next_position)
      previous_terms = Enum.map(previous_positions, &Map.get(grid, &1))
      expected_terms = Enum.map(previous_terms, fn term -> Pair.new(term, item) end)

      missing_pair = Enum.find(expected_terms, fn term -> not MapSet.member?(context, term) end)

      if missing_pair == nil do
        new_grid = Map.put(grid, next_position, item)
        id = calculate_id(new_grid)
        {:ok, %Ortho{ortho | grid: new_grid, counter: new_counter, id: id}}
      else
        {:error, missing_pair}
      end
    end
  end

  defp calculate_id(grid) do
    dimension = Enum.count(List.first(Map.keys(grid)))
    permutations = permutations(Enum.to_list(0..(dimension - 1)))

    canonical_forms =
      for perm <- permutations do
        grid
        |> Enum.map(fn {pos, val} ->
          new_pos =
            Enum.with_index(pos)
            |> Enum.sort_by(fn {_, i} -> Enum.find_index(perm, &(&1 == i)) end)
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
