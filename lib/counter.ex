defmodule Counter do
  @table_name :counter

  def start() do
    :ets.new(@table_name, [:named_table, :set, :public])
  end

  def stop() do
    :ets.delete(@table_name)
  end

  def increment(shape, current_position) do
    case :ets.lookup(@table_name, {shape, current_position}) do
      [] ->
        {new_shape, new_position} = get_next(shape, current_position)
        shell = Enum.sum(new_position)
        :ets.insert(@table_name, {{shape, current_position}, {new_shape, new_position, shell}})
        {new_shape, new_position, shell}

      [{{_shape, _current_position}, {new_shape, new_position, shell}}] ->
        {new_shape, new_position, shell}
    end
  end

  def get_next(shape, current_position) do
    options =
      if shape == [2, 2] do
        shape
        |> sorted_cartesian()
      else
        shape
        |> sorted_cartesian()
        |> Enum.reject(&(hd(&1) == 0))
      end

    index = Enum.find_index(options, &(&1 == current_position))

    if index == length(options) - 1 do
      new_shape = [2 | shape]

      new_options =
        new_shape
        |> sorted_cartesian()
        |> Enum.reject(&(hd(&1) == 0))

      {new_shape, hd(new_options)}
    else
      {shape, Enum.at(options, index + 1)}
    end
  end

  defp sorted_cartesian(shape) do
    Utils.cartesian_product(shape)
    |> Enum.sort_by(&{Enum.sum(&1), &1})
  end
end
