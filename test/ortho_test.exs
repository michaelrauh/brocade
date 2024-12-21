defmodule OrthoTest do
  use ExUnit.Case, async: true

  alias Ortho

  test "an ortho can get the next relevant position" do
      # a-b (0, 0, 0) (0, 1, 0)
      # |
      # c-d (1, 0, 0) (1, 1, 0)

      # e f (0, 0, 1) (0, 1, 1)
      # g h (1, 0, 1) (1, 1, 1)
    ortho = Ortho.new(Pair.new("a", "b"))
    {pos, ortho} = Ortho.next_position(ortho)
    assert pos == {1, 0}
    {:ok, ortho} = Ortho.add_pair(ortho, Pair.new("a", "c"))
    {pos, ortho} = Ortho.next_position(ortho)
    assert pos == {1, 1}
    {:ok, ortho} = Ortho.add_pair(ortho, Pair.new("b", "d"))
    {pos, ortho} = Ortho.next_position(ortho)
    assert pos == {0, 0, 1}
    {:ok, ortho} = Ortho.add_pair(ortho, Pair.new("a", "e"))
    {pos, ortho} = Ortho.next_position(ortho)
    assert pos == {0, 1, 1}
  end

  # test "an ortho may add a pair to a slot if it passes the rules" do
  #   ortho = Ortho.new(Pair.new("a", "b"))
  #   {status, _} = Ortho.add_pair(ortho, Pair.new("a", "c"), MapSet.new())
  #   assert status == :ok
  # end

  # test "an ortho may fail to add a pair if it doesnt have the right forwards" do
  #   ortho = Ortho.new(Pair.new("a", "b"))

  #   {status, _} = Ortho.add_pair(ortho, Pair.new("c", "d"), MapSet.new())
  #   assert status == :error
  # end

  # test "an ortho may fail to add a pair if it conflicts diagonally" do
  #   ortho = Ortho.new(Pair.new("a", "b"))

  #   {status, _} = Ortho.add_pair(ortho, Pair.new("a", "b"), MapSet.new())
  #   assert status == :error
  # end

  # test "an ortho may need to check context and still pass" do
  #   # a-b (0, 0) (0, 1)
  #   # |
  #   # c-d (1, 0) (1, 1)
  #   ortho = Ortho.new(Pair.new("a", "b"))
  #   {:ok, ortho} = Ortho.add_pair(ortho, Pair.new("a", "c"), MapSet.new())
  #   {:ok, ortho} = Ortho.add_pair(ortho, Pair.new("c", "d"), MapSet.new({"b", "d"}))
  # end

  # test "an ortho may need to check context and fail" do
  #   # a-b (0, 0) (0, 1)
  #   # |
  #   # c-d (1, 0) (1, 1)
  #   ortho = Ortho.new(Pair.new("a", "b"))
  #   {:ok, ortho} = Ortho.add_pair(ortho, Pair.new("a", "c"), MapSet.new())
  #   {:error, _} = Ortho.add_pair(ortho, Pair.new("c", "d"), MapSet.new({"b", "a"}))
  # end

  # # test slots are updated on shape fill (next dimension)
end
