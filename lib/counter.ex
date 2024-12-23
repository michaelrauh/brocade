defmodule Counter do
  defstruct shape: [2, 2], options: Enum.sort(Utils.cartesian_product([2, 2])) -- [[0, 0], [0, 1]]

  def new(), do: %Counter{}

  def increment(%Counter{shape: shape, options: []}) do
    new_shape = [2 | shape]

    all_new_options =
      Utils.cartesian_product(new_shape)
      |> Enum.sort_by(&{Enum.sum(&1), &1})
      |> Enum.reject(&(hd(&1) == 0))

    {current, remaining} = List.pop_at(all_new_options, 0)

    {current, %Counter{shape: new_shape, options: remaining}}
  end

  def increment(%Counter{shape: shape, options: options}) do
    {current, remaining} = List.pop_at(options, 0)
    {current, %Counter{shape: shape, options: remaining}}
  end
end
