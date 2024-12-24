defmodule OrthoTest do
  use ExUnit.Case, async: true

  alias Ortho

  test "an ortho may add again" do
    # a b
    # c d

    # e

    context = MapSet.new([Pair.new("a", "b")])

    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    assert ortho.grid == %{[0, 0] => "a"} 
    {:ok, ortho} = Ortho.add(ortho, "b", context)
    assert ortho.grid == %{[0, 0] => "a", [0, 1] => "b"}


    # todo add several
    # # test slots are updated on shape fill (next dimension)
    #todo strip grid checks

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
    {:diag, reason} = Ortho.add(ortho, "b", context)
    assert reason == {1, "b"}
  end
end
