defmodule Ortho do
  defstruct grid: %{}, counter: nil

  alias Counter

  def new do
    %Ortho{
      counter: Counter.new()
    }
  end

  def previous_positions(position) do
    position
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> List.replace_at(position, index, value - 1) end)
    |> Enum.filter(fn pos -> Enum.all?(pos, &(&1 >= 0)) end)
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
    forbidden = Map.get(diagonals, Enum.sum(next_position), MapSet.new())

    if MapSet.member?(forbidden, item) do
      :diag
    else
      previous_positions = previous_positions(next_position)
      previous_terms = Enum.map(previous_positions, &Map.get(grid, &1))
      expected_terms = Enum.map(previous_terms, fn term -> Pair.new(term, item) end)

      missing_pair = Enum.find(expected_terms, fn term -> not MapSet.member?(context, term) end)

      if missing_pair == nil do
        new_grid = Map.put(grid, next_position, item)
        {:ok, %Ortho{ortho | grid: new_grid, counter: new_counter}}
      else
        {:error, missing_pair}
      end
    end
  end
end
