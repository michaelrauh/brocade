defmodule Counter do
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
