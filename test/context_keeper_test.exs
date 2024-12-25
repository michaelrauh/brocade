defmodule ContextKeeperTest do
  use ExUnit.Case, async: false
  alias ContextKeeper

  setup do
    ContextKeeper.start()
  end

  test "it can store a set of values which may or may not be new" do
    ContextKeeper.add_pair(Pair.new("a", "b"))
    ContextKeeper.add_pair(Pair.new("a", "b"))
    ContextKeeper.add_pair(Pair.new("c", "d"))
    assert ContextKeeper.get_pairs() == [Pair.new("a", "b"), Pair.new("c", "d")]
    ContextKeeper.stop()
  end

  test "it can take multiple values at once" do
    ContextKeeper.add_pairs([
      Pair.new("a", "b"),
      Pair.new("a", "b"),
      Pair.new("c", "d")
    ])
    assert ContextKeeper.get_pairs() == [Pair.new("a", "b"), Pair.new("c", "d")]
    ContextKeeper.stop()
  end
end
