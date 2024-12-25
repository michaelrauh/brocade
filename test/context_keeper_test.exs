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
end
