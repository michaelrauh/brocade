defmodule Ortho do
  defstruct grid: %{}, shape: [2, 2], position: [0, 0], shell: 0, id: nil

  alias Counter

  def new() do
    %Ortho{grid: %{}, shape: [2, 2], position: [0, 0], shell: 0, id: nil}
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

  def get_requirements(%Ortho{grid: grid, position: position, shell: shell}) do
    forbidden = get_others_in_same_shell(grid, shell)
    required = find_all_pair_prefixes(grid, position)

    {forbidden, required}
  end

  def add(%Ortho{grid: grid, position: position, shape: shape} = ortho, item) do
    {new_shape, next_position, shell} = Counter.increment(shape, position)
    grid = optionally_pad_grid(grid, shape, new_shape)
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

  defp optionally_pad_grid(grid, shape, new_shape) do
    if shape != new_shape do
      pad_grid(grid)
    else
      grid
    end
  end

  defp get_others_in_same_shell(grid, shell) do
    grid
    |> Enum.filter(fn {pos, _val} -> Enum.sum(pos) == shell end)
    |> Enum.map(fn {_pos, val} -> val end)
    |> MapSet.new()
  end

  defp calculate_id(grid) do
    one_hot_positions =
      grid
      |> Enum.filter(fn {coords, _} ->
        coords
        |> Enum.sum() == 1
      end)
      |> Enum.sort_by(fn {_, val} -> val end)
      |> Enum.map(fn {coords, _} -> coords end)

    axis_order =
      one_hot_positions
      |> Enum.map(fn coords -> Enum.find_index(coords, &(&1 == 1)) end)

    sorted_positions =
      grid
      |> Enum.sort_by(fn {coords, _} ->
        Enum.map(axis_order, &Enum.at(coords, &1))
      end) |> Enum.map(fn {_, val} -> val end)

    sorted_positions
    |> :erlang.term_to_binary()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end
end
