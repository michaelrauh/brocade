defmodule Utils do
  def cartesian_product(lists) do
    lists
    |> Enum.map(&Enum.to_list(0..(&1 - 1)))
    |> Enum.reduce([[]], fn list, acc ->
      for x <- list, y <- acc, do: [x | y]
    end)
    |> Enum.map(&Enum.reverse/1)
  end
end
