defmodule ContextTest do
  use ExUnit.Case
  import Bitwise

  setup do
    start_supervised!(ContextQueue)
    start_supervised!(Context)
    :ok
  end

  test "when adding a vocab word, it sets the mapping to the empty bitmask (0)" do
    :ok = ContextQueue.push({:vocab, "one"})
    Context.poll()

    bitmasks = Context.bitmasks()
    assert Map.get(bitmasks, ["one"]) == 0
  end

  test "it runs until the queue is empty" do
    :ok = ContextQueue.push({:vocab, "one"})
    :ok = ContextQueue.push({:vocab, "two"})
    Context.poll()

    bitmasks = Context.bitmasks()
    assert Map.get(bitmasks, ["one"]) == 0
    assert Map.get(bitmasks, ["two"]) == 0
  end

  test "when adding a phrase it updates the mapping" do
    :ok = ContextQueue.push({:vocab, "one"})
    :ok = ContextQueue.push({:vocab, "two"})
    :ok = ContextQueue.push({:subphrase, ["one", "two"]})
    Context.poll()

    # Set bit for "two" at index 1:
    mask = 0
    mask = Bitwise.bor(mask, 1 <<< 1)

    bitmasks = Context.bitmasks()
    assert Map.get(bitmasks, ["one"]) == mask
  end

  test "when adding a subphrase, it updates the bitmask map" do
    :ok = ContextQueue.push({:vocab, "one"})
    :ok = ContextQueue.push({:vocab, "two"})
    :ok = ContextQueue.push({:vocab, "three"})
    :ok = ContextQueue.push({:subphrase, ["one", "two"]})
    :ok = ContextQueue.push({:subphrase, ["one", "three"]})
    Context.poll()

    bitmasks = Context.bitmasks()

    mask = 0
    mask = Bitwise.bor(mask, 1 <<< 1)
    mask = Bitwise.bor(mask, 1 <<< 2)

    assert Map.get(bitmasks, ["one"]) == mask
  end

  # TODO when it is done polling it posts a seed value
  # TODO when asked for context it returns the bitmasks and version number
end
