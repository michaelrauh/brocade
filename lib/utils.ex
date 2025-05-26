defmodule Utils do
  def cartesian_product(lists) do
    if Enum.all?(lists, &(&1 > 0)) do
      lists
      |> Enum.map(&Enum.to_list(0..(&1 - 1)//1))
      |> Enum.reduce([[]], fn list, acc ->
        for x <- list, y <- acc, do: [x | y]
      end)
      |> Enum.map(&Enum.reverse/1)
    else
      []
    end
  end
end
