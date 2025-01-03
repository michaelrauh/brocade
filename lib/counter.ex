defmodule Counter do
  @table_name :counter

  def start() do
    :ets.new(@table_name, [:named_table, :set, :public])
  end

  def stop() do
    :ets.delete(@table_name)
  end

  # def increment(shape, current_position) do
  #   case :ets.lookup(@table_name, {shape, current_position}) do
  #     [] ->
  #       {new_shape, new_position} = get_next(shape, current_position)
  #       shell = Enum.sum(new_position)
  #       :ets.insert(@table_name, {{shape, current_position}, {new_shape, new_position, shell}})
  #       {new_shape, new_position, shell}

  #     [{{_shape, _current_position}, {new_shape, new_position, shell}}] ->
  #       {new_shape, new_position, shell}
  #   end
  # end

  def get_next(shape, current_position) do
    possibilities = sorted_cartesian(shape)
    current = Enum.find_index(possibilities, fn x -> x == current_position end)
    desired = Enum.at(possibilities, current + 1)

    if desired == nil do
        # over - later do both
        magnitudes = Enum.uniq(shape)

        locations =
          Enum.map(magnitudes, fn mag ->
            Enum.find_index(shape, fn shape_member -> shape_member == mag end)
          end)

        new_shapes =
          Enum.map(locations, fn location ->
            List.update_at(shape, location, fn x -> x + 1 end)
          end)

        next_positions =
          Enum.map(new_shapes, fn new_shape ->
            sorted_cartesian(new_shape)
            |> Enum.reject(fn x -> Enum.member?(possibilities, x) end)
            |> List.first()
          end)

        shapes_and_positions = Enum.zip(new_shapes, next_positions)
        if Enum.all?(shape, fn x -> x == 2 end) do
          # up on base
          new_shape = [2 | shape]
          new_possibilities = sorted_cartesian(new_shape)
          used_possibilities = Enum.map(possibilities, fn x -> [0 | x] end)

          desired =
            new_possibilities
            |> Enum.reject(fn x -> Enum.member?(used_possibilities, x) end)
            |> List.first()

          result_to_add = {new_shape, desired}
          shapes_and_positions = shapes_and_positions ++ [result_to_add]
          {:both, shapes_and_positions}
        end
        {:over, shapes_and_positions}
    else
      {:same, [{shape, desired}]}
    end
  end

  defp sorted_cartesian(shape) do
    Utils.cartesian_product(shape)
    |> Enum.sort_by(&{Enum.sum(&1), &1})
  end
end
