defmodule CounterTest do
  use ExUnit.Case, async: false

  alias Counter

  test "can be incremented, skipping all already visited while increasing dimensionality and returning shell" do
    Counter.start()
    {_, next_position, 1} = Counter.increment([2, 2], [0, 0])
    assert next_position == [0, 1]
    {_, next_position, 1} = Counter.increment([2, 2], next_position)
    assert next_position == [1, 0]
    {_, next_position, 2} = Counter.increment([2, 2], next_position)
    assert next_position == [1, 1]
    {shape, next_position, 1} = Counter.increment([2, 2], next_position)
    assert next_position == [1, 0, 0]
    assert shape == [2, 2, 2]
    {shape, next_position, 2} = Counter.increment(shape, next_position)
    assert next_position == [1, 0, 1]
    assert shape == [2, 2, 2]

    Counter.increment([2, 2], [0, 0])
    Counter.increment([2, 2], [0, 0])
    Counter.increment([2, 2], [0, 0])
    Counter.increment([2, 2], [0, 0])
    Counter.increment([2, 2], [0, 0])
    Counter.increment([2, 2], [0, 0])

    Counter.stop()
  end

  # a b (0 0) (0 1)  | (0 0 0) (0 0 1)
  # c d (1 0) (1 1)  | (0 1 0) (0 1 1)

  # e f              | (1 0 0) (1 0 1)
  # g h              | (1 1 0) (1 1 1)
end
