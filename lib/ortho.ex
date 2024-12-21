defmodule Ortho do
  defstruct grid: %{}, shape: {2, 2}

  def new(%{first: f, second: s}) do
    %Ortho{grid: %{{0, 0} => f, {0, 1} => s}}
  end

  defp cartesian_product(ranges) do
    Enum.reduce(ranges, [[]], fn range, acc ->
      for x <- range, y <- acc, do: [x | y]
    end)
    |> Enum.map(&List.to_tuple/1)
  end

  def next_position(%Ortho{grid: grid, shape: shape} = ortho) do
    ranges = for dim <- Tuple.to_list(shape), do: 0..(dim - 1)
    possibles = cartesian_product(ranges)
    positions = Map.keys(grid)
    case List.first(possibles -- positions) do
      nil ->
        {pos, updated_ortho} = expand_shape_and_get_first_position(ortho)
        {pos, updated_ortho}
      pos -> {pos, ortho}
    end
  end

  defp expand_shape_and_get_first_position(%Ortho{grid: grid, shape: shape}) do
    new_shape = Tuple.append(shape, 2)
    updated_grid = Enum.into(grid, %{}, fn {key, value} ->
      {Tuple.append(key, 0), value}
    end)
    ranges = for dim <- Tuple.to_list(new_shape), do: 0..(dim - 1)
    possibles = cartesian_product(ranges)
    new_ortho = %Ortho{grid: updated_grid, shape: new_shape}
    {List.first(possibles -- Map.keys(updated_grid)), new_ortho}
  end

  def add_pair(%Ortho{grid: grid} = ortho, %Pair{first: _f, second: s}) do
    {pos, updated_ortho} = next_position(ortho)
    new_grid = Map.put(updated_ortho.grid, pos, s)
    {:ok, %Ortho{grid: new_grid, shape: updated_ortho.shape}}
  end
end
