defmodule ContextKeeperTest do
  use ExUnit.Case, async: false
  alias ContextKeeper

  setup do
    ContextKeeper.start()
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

  test "it can take in vocabulary" do
    ContextKeeper.add_vocabulary([
      "a", "b", "b", "c"
    ])
    assert ContextKeeper.get_vocabulary() == ["b", "a", "c"]
    ContextKeeper.stop()
  end

  test "it can return which pairs were new when adding" do
    ContextKeeper.add_pairs([
      Pair.new("a", "b"),
      Pair.new("a", "b"),
      Pair.new("c", "d")
    ])

    assert ContextKeeper.add_pairs([
      Pair.new("a", "b"),
      Pair.new("c", "d"),
      Pair.new("e", "f")
    ]) == [Pair.new("e", "f")]
  end

  test "it can return which words were new when adding" do
    ContextKeeper.add_vocabulary([
      "a", "b", "b", "c"
    ])

    assert ContextKeeper.add_vocabulary([
      "a", "b", "c", "d"
    ]) == ["d"]
  end
end
