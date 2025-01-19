defmodule Counter do
  @table_name :counter
  @visited :visited

  def start do
    :ets.new(@table_name, [:named_table, :set, :public])
    :ets.new(@visited, [:named_table, :set, :public])

    insert_visited([2, 2], [0, 0], [])
  end

  def stop do
    :ets.delete(@table_name)
    :ets.delete(@visited)
  end

  def increment(shape, current_position) do
    case :ets.lookup(@table_name, {shape, current_position}) do
      [] ->
        {type, results} = get_next(shape, current_position)

        results_with_shells =
          for {new_shape, new_position} <- results do
            {new_shape, new_position, Enum.sum(new_position)}
          end

        :ets.insert(@table_name, {{shape, current_position}, {type, results_with_shells}})
        {type, results_with_shells}

      [{{_shape, _pos}, {type, results_with_shells}}] ->
        {type, results_with_shells}
    end
  end

  def get_next(shape, current_position) do
    visited = get_visited(shape, current_position)

    possibilities = sorted_cartesian(shape)
    valid_possibilities = possibilities |> Enum.reject(&Enum.member?(visited, &1))
    current_index = Enum.find_index(valid_possibilities, &(&1 == current_position))

    IO.inspect("**********")
    IO.inspect({"shape", shape})
    IO.inspect({"current_position", current_position})
    IO.inspect({"current_index", current_index})
    IO.inspect({"possibilities", possibilities})
    IO.inspect({"visited", visited})
    IO.inspect({"valid_possibilities", valid_possibilities})
    IO.inspect({"position", Enum.at(valid_possibilities, current_index + 1)})

    case Enum.at(valid_possibilities, current_index + 1) do
      nil ->
        over_list = over_shapes(shape, possibilities)

        if Enum.all?(shape, &(&1 == 2)) do
          up = up_shape(shape, possibilities)
          res = [up | over_list]
          Enum.each(res, fn {shape, pos} -> insert_visited(shape, pos, [[0|current_position] | Enum.map(visited, fn x -> [0|x] end)]) end) # only pad up, not both
          {:both, res}
        else
          res = over_list
          Enum.each(res, fn {shape, pos} -> insert_visited(shape, pos, [current_position | visited]) end)
          {:over, res}
        end

      desired ->
        res = [{shape, desired}]
        Enum.each(res, fn {shape, pos} -> insert_visited(shape, pos, [current_position | visited]) end)
        {:same, res}
    end
  end

  defp get_visited(shape, position) do
    case :ets.lookup(@visited, {shape, position}) do
      [{_key, previous}] -> previous
    end
  end

  defp insert_visited(shape, position, previous) do
    :ets.insert(@visited, {{shape, position}, previous})
  end

  defp over_shapes(shape, existing) do
    for location <- distinct_locations(shape) do
      new_shape = List.update_at(shape, location, &(&1 + 1))

      new_pos =
        sorted_cartesian(new_shape)
        |> Enum.reject(&Enum.member?(existing, &1))
        |> List.first()

      {new_shape, new_pos}
    end
  end

  defp up_shape(shape, existing) do
    new_shape = [2 | shape]

    new_pos =
      sorted_cartesian(new_shape)
      |> Enum.reject(&Enum.member?(Enum.map(existing, fn x -> [0 | x] end), &1))
      |> List.first()

    {new_shape, new_pos}
  end

  defp distinct_locations(shape) do
    Enum.uniq(shape)
    |> Enum.map(fn mag -> Enum.find_index(shape, &(&1 == mag)) end)
  end

  defp sorted_cartesian(shape) do
    Utils.cartesian_product(shape)
    |> Enum.sort_by(&{Enum.sum(&1), &1})
  end
end
