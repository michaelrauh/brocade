defmodule PairTest do
  use ExUnit.Case, async: true

  alias Pair

  test "creating a pair allows access to the first and second members" do
    pair = Pair.new("hello", "world")
    assert Pair.first(pair) == "hello"
    assert Pair.second(pair) == "world"
  end
end
