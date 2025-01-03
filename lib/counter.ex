defmodule Counter do
  @table_name :counter

  def start do
    :ets.new(@table_name, [:named_table, :set, :public])
  end

  def stop do
    :ets.delete(@table_name)
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
    possibilities = sorted_cartesian(shape)
    current_index = Enum.find_index(possibilities, &(&1 == current_position))

    case Enum.at(possibilities, current_index + 1) do
      nil ->
        over_list = over_shapes(shape, possibilities)

        if Enum.all?(shape, &(&1 == 2)) do
          up = up_shape(shape, possibilities)
          {:both, [up | over_list]}
        else
          {:over, over_list}
        end

      desired ->
        {:same, [{shape, desired}]}
    end
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
