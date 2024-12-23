defmodule CounterTest do
  use ExUnit.Case, async: true

  alias Counter

  test "can be incremented, skipping the first two and all already visited while increasing dimensionality" do
    counter = Counter.new()
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 1]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0, 1]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 1, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 1, 1]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0, 0, 0]
  end

  # a b (0 0) (0 1)  | (0 0 0) (0 0 1)
  # c d (1 0) (1 1)  | (0 1 0) (0 1 1)

  # e f              | (1 0 0) (1 0 1)
  # g h              | (1 1 0) (1 1 1)
end
