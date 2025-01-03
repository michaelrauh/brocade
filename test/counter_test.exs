defmodule CounterTest do
  use ExUnit.Case, async: false

  alias Counter

  test "can be incremented, skipping all already visited while increasing dimensionality in a branching up and over fashion and returning shell" do
    assert {:same, [{[2, 2], [0, 1]}]} == (Counter.get_next([2, 2], [0, 0]))
    assert {:same, [{[2, 2], [1, 0]}]} == (Counter.get_next([2, 2], [0, 1]))
    assert {:same, [{[2, 2], [1, 1]}]} == (Counter.get_next([2, 2], [1, 0]))
    assert {:both, [{[2, 2, 2], [1, 0, 0]}, {[3, 2], [2, 0]}]} == (Counter.get_next([2, 2], [1, 1]))
  end

end
