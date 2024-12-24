defmodule OrthoTest do
  use ExUnit.Case, async: true

  alias Ortho

  test "an ortho may add again" do
    context = MapSet.new([Pair.new("a", "b")])

    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    assert ortho.grid == %{[0, 0] => "a"}
    {:ok, ortho} = Ortho.add(ortho, "b", context)
    assert ortho.grid == %{[0, 0] => "a", [0, 1] => "b"}
  end

  test "an ortho may fail to add a word if it doesnt have the right context" do
    context = MapSet.new()
    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {status, remediation} = Ortho.add(ortho, "b", context)
    assert status == :error
    assert remediation == Pair.new("a", "b")
  end

  test "an ortho may fail to add a pair if it conflicts diagonally" do
    context = MapSet.new([Pair.new("a", "b")])

    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {:ok, ortho} = Ortho.add(ortho, "b", context)
    :diag = Ortho.add(ortho, "b", context)
  end
  # todo have diag give back the bad thing that it ran into - distance shell and identity

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
