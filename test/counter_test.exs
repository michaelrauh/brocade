defmodule CounterTest do
  use ExUnit.Case, async: false

  alias Counter

  test "can be incremented, skipping all already visited while increasing dimensionality and returning shell" do
    # {:same, [2, 2], [0, 1]} = Counter.get_next([2, 2], [0, 0])
    # {:same, [2, 2], [1, 0]} = Counter.get_next([2, 2], [0, 1])
    # {:same, [2, 2], [1, 1]} = Counter.get_next([2, 2], [1, 0])
    # {:up, [2, 2, 2], [1, 0, 0]} = Counter.get_next([2, 2], [1, 1])
    Counter.get_next([2, 3], [1, 2])
    # a b (0 0) (0 1)  | (0 0 0) (0 0 1)
    # c d (1 0) (1 1)  | (0 1 0) (0 1 1)

    # e f              | (1 0 0) (1 0 1)
    # g h              | (1 1 0) (1 1 1)
  end

  # test "can expand any dimension in size and fill in there" do
  #   Counter.start()
  #   {[2, 2], [0, 1], 1} = Counter.increment_over([2, 2], [0, 0])
  #   {[2, 2], [1, 0], 1} = Counter.increment_over([2, 2], [1, 0])
  #   {[2, 2], [1, 1], 2} = Counter.increment_over([2, 2], [1, 1])
  #   {[2, 3], [0, 2], 2} = Counter.increment_over([2, 2], [1, 1])
  #   {[2, 3], [1, 2], 3} = Counter.increment_over([2, 2], [1, 1])

  #   Counter.stop()
  #   # [2, 2]
  #   # a b (0 0) (0 1)
  #   # c d (1 0) (1 1)

  #   # [2, 3]
  #   # a b e (0 0) (0 1) (0 2)
  #   # c d f (1 0) (1 1) (1 2)
  #
  #   # [3, 3]
  #   # a b c (0, 0) (0, 1) (0, 2)
  #   # d e f (1, 0) (1, 1) (1, 2)
  #   # g h i (2, 0) (2, 1) (2, 2)
  # end

  # does it only need to do up on base? - yes
  # todo combine and make sure there are no straightforward or rotational duplicates
end
