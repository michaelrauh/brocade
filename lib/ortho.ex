defmodule Ortho do
  defstruct grid: %{}, counter: nil

  alias Counter

  def new(%{first: first, second: second}) do
    %Ortho{
      grid: %{[0, 0] => first, [0, 1] => second},
      counter: Counter.new()
    }
  end

  def add_pair(%Ortho{grid: grid, counter: counter} = ortho, %Pair{second: second}) do
    {next_position, new_counter} = Counter.increment(counter)
    new_grid = Map.put(grid, next_position, second)
    %Ortho{ortho | grid: new_grid, counter: new_counter}
  end
end
