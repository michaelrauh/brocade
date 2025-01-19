defmodule CounterTest do
  use ExUnit.Case, async: false

  alias Counter

  test "can be incremented, skipping all already visited while increasing dimensionality in a branching up and over fashion" do
    Counter.start()
    assert {:same, [{[2, 2], [0, 1]}]} == Counter.get_next([2, 2], [0, 0])
    assert {:same, [{[2, 2], [1, 0]}]} == Counter.get_next([2, 2], [0, 1])
    assert {:same, [{[2, 2], [1, 1]}]} == Counter.get_next([2, 2], [1, 0])
    assert {:both, [{[2, 2, 2], [1, 0, 0]}, {[3, 2], [2, 0]}]} == Counter.get_next([2, 2], [1, 1]) # this returns two things. One is an up result. That result should have padded visited and the other should not. The over result is showing a padded visited.

    # up result
    # assert {:same, [{[2, 2, 2], [1, 0, 1]}]} == Counter.get_next([2, 2, 2], [1, 0, 0])
    # assert {:same, [{[2, 2, 2], [1, 1, 0]}]} == Counter.get_next([2, 2, 2], [1, 0, 1])
    # assert {:same, [{[2, 2, 2], [1, 1, 1]}]} == Counter.get_next([2, 2, 2], [1, 1, 0])

    # assert {:both, [{[2, 2, 2, 2], [1, 0, 0, 0]}, {[3, 2, 2], [2, 0, 0]}]} ==
    #          Counter.get_next([2, 2, 2], [1, 1, 1])

    # over result
    assert {:same, [{[3, 2], [2, 1]}]} == Counter.get_next([3, 2], [2, 0])
    # assert {:over, [{[4, 2], [3, 0]}, {[3, 3], [0, 2]}]} == Counter.get_next([3, 2], [2, 1])

    # # over tall
    # assert {:same, [{[4, 2], [3, 1]}]} == Counter.get_next([4, 2], [3, 0])
    # assert {:over, [{[5, 2], [4, 0]}, {[4, 3], [0, 2]}]} == Counter.get_next([4, 2], [3, 1])

    # # over squat
    # assert {:same, [{[3, 3], [1, 2]}]} == Counter.get_next([3, 3], [0, 2])
    # assert {:same, [{[3, 3], [2, 1]}]} == Counter.get_next([3, 3], [1, 2])
    # assert {:same, [{[3, 3], [2, 2]}]} == Counter.get_next([3, 3], [2, 1])
    # assert {:over, [{[4, 3], [3, 0]}]} == Counter.get_next([3, 3], [2, 2])
    Counter.stop()
  end

  # test "it memoizes and calculates shells" do
  #   Counter.start()
  #   assert {:same, [{[2, 2], [0, 1], 1}]} = Counter.increment([2, 2], [0, 0])
  #   assert {:same, [{[2, 2], [1, 0], 1}]} = Counter.increment([2, 2], [0, 1])
  #   assert {:same, [{[2, 2], [1, 1], 2}]} = Counter.increment([2, 2], [1, 0])

  #   assert {:both, [{[2, 2, 2], [1, 0, 0], 1}, {[3, 2], [2, 0], 2}]} =
  #            Counter.increment([2, 2], [1, 1])

  #   Counter.stop()
  # end
end
