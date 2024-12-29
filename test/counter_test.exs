defmodule CounterTest do
  use ExUnit.Case, async: true

  alias Counter

  test "can be incremented, skipping all already visited while increasing dimensionality" do
    {[2, 2], next_position} = Counter.get_next([2, 2], [0, 0])
    assert next_position == [0, 1]
    {[2, 2], next_position} = Counter.get_next([2, 2], next_position)
    assert next_position == [1, 0]
    {[2, 2], next_position} = Counter.get_next([2, 2], next_position)
    assert next_position == [1, 1]
    {shape, next_position} = Counter.get_next([2, 2], next_position)
    assert next_position == [1, 0, 0]
    assert shape = [2, 2, 2]
    {shape, next_position} = Counter.get_next(shape, next_position)
    assert next_position == [1, 0, 1]
    assert shape = [2, 2, 2]
  end

  # a b (0 0) (0 1)  | (0 0 0) (0 0 1)
  # c d (1 0) (1 1)  | (0 1 0) (0 1 1)

  # e f              | (1 0 0) (1 0 1)
  # g h              | (1 1 0) (1 1 1)
end
