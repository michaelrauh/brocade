defmodule Counter do
  defstruct shape: [2, 2], options: Enum.sort(Utils.cartesian_product([2, 2])) -- [[0, 0], [0, 1]]

  def new() do
    %Counter{}
  end

  def increment(%Counter{shape: shape, options: options}) do

    case List.pop_at(options, 0) do
      {nil, []} ->
        new_shape = [2 | shape]
        all_new_options = Enum.sort_by(Utils.cartesian_product(new_shape), fn(l) -> {Enum.sum(l), l} end)
        {current, remaining} = List.pop_at(all_new_options, 0)

        {current, %Counter{shape: new_shape, options: remaining}}

      {current, remaining} ->
        {current, %Counter{shape: shape, options: remaining}}
    end
  end
end
