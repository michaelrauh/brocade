defmodule Ortho do
  defstruct grid: %{}, shape: [2, 2], position: [0, 0], shell: 0, id: nil

  alias Counter

  def new() do
    %Ortho{grid: %{}, shape: [2, 2], position: [0, 0], shell: 0, id: nil}
  end

  def previous_positions(position) do
    position
    |> Enum.with_index()
    |> Stream.filter(fn {val, _idx} -> val > 0 end)
    |> Enum.map(fn {val, idx} -> List.replace_at(position, idx, val - 1) end)
  end

  def pad_grid(grid) do
    Map.new(grid, fn {key, value} -> {[0 | key], value} end)
  end

  def get_requirements(%Ortho{grid: grid, position: position, shell: shell}) do
    forbidden = get_others_in_same_shell(grid, shell)
    required = find_all_pair_prefixes(grid, position)

    {forbidden, required}
  end

  def add(%Ortho{grid: grid, position: position, shape: shape} = ortho, item) do
    {new_shape, next_position, shell} = Counter.increment(shape, position)
    grid = if shape == new_shape, do: grid, else: pad_grid(grid)
    new_grid = Map.put(grid, position, item)
    new_id = calculate_id(new_grid)

    %Ortho{
      ortho
      | grid: new_grid,
        position: next_position,
        shape: new_shape,
        shell: shell,
        id: new_id
    }
  end

  defp find_all_pair_prefixes(grid, next_position) do
    previous_positions(next_position)
    |> Enum.map(&Map.get(grid, &1))
  end

  defp get_others_in_same_shell(grid, shell) do
    grid
    |> Enum.reduce(MapSet.new(), fn {pos, val}, acc ->
      if Enum.sum(pos) == shell, do: MapSet.put(acc, val), else: acc
    end)
  end

  defp calculate_id(grid) do
    one_hot_positions =
      grid
      |> Enum.filter(fn {coords, _} -> Enum.sum(coords) == 1 end)
      |> Enum.sort_by(fn {_, val} -> val end)
      |> Enum.map(fn {coords, _} -> coords end)

    axis_order =
      one_hot_positions
      |> Enum.map(fn coords -> Enum.find_index(coords, &(&1 == 1)) end)

    sorted_positions =
      grid
      |> Enum.sort_by(fn {coords, _} ->
        Enum.map(axis_order, &Enum.at(coords, &1))
      end)
      |> Enum.map(fn {_, val} -> val end)

    sorted_positions
    |> :erlang.term_to_binary()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end
end
