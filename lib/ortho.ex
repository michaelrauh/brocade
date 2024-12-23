defmodule Ortho do
  defstruct grid: %{}, counter: nil

  alias Counter

  def new do
    %Ortho{
      counter: Counter.new()
    }
  end

  def add(%Ortho{grid: grid, counter: counter} = ortho, s) do
    {next_position, new_counter} = Counter.increment(counter)
    new_grid = Map.put(grid, next_position, s)
    %Ortho{ortho | grid: new_grid, counter: new_counter}
  end
end
