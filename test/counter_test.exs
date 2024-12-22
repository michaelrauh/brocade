defmodule CounterTest do
  use ExUnit.Case, async: true

  alias Counter

  test "skips the first couple" do
    counter = Counter.new()
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 1]
  end

  test "can be incremented" do
    counter = Counter.new()
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 1]
  end

  test "can be incremented past the end" do
    counter = Counter.new()
    {current, counter} = Counter.increment(counter)
    {current, counter} = Counter.increment(counter)
    {current, counter} = Counter.increment(counter)
    assert current == [0, 0, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [0, 0, 1]
  end


  test "increments in distance shell order then by position order" do
    counter = Counter.new()
    {current, counter} = Counter.increment(counter)
    {current, counter} = Counter.increment(counter)
    {current, counter} = Counter.increment(counter)
    assert current == [0, 0, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [0, 0, 1]
    {current, counter} = Counter.increment(counter)
    assert current == [0, 1, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [1, 0, 0]
    {current, counter} = Counter.increment(counter)
    assert current == [0, 1, 1]
  end

end
