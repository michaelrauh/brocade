defmodule OrthoTest do
  use ExUnit.Case, async: true

  alias Ortho

  test "an ortho may add again" do
    # a b | e
    # c d |

    context =
      MapSet.new([
        Pair.new("a", "b"),
        Pair.new("c", "d"),
        Pair.new("a", "c"),
        Pair.new("b", "d"),
        Pair.new("a", "e")
      ])

    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {:ok, ortho} = Ortho.add(ortho, "b", context)
    {:ok, ortho} = Ortho.add(ortho, "c", context)
    {:ok, ortho} = Ortho.add(ortho, "d", context)
    {:ok, _ortho} = Ortho.add(ortho, "e", context)
  end

  test "orthos built in different orders may share ids" do
    context =
      MapSet.new([
        Pair.new("a", "b"),
        Pair.new("c", "d"),
        Pair.new("a", "c"),
        Pair.new("b", "d"),
        Pair.new("a", "e")
      ])

    ortho1 = Ortho.new()
    ortho2 = Ortho.new()
    {:ok, ortho1} = Ortho.add(ortho1, "a", context)
    {:ok, ortho2} = Ortho.add(ortho2, "a", context)
    assert ortho1.id == ortho2.id

    {:ok, ortho1} = Ortho.add(ortho1, "b", context)
    {:ok, ortho2} = Ortho.add(ortho2, "c", context)
    assert ortho1.id != ortho2.id

    {:ok, ortho1} = Ortho.add(ortho1, "c", context)
    {:ok, ortho2} = Ortho.add(ortho2, "b", context)
    assert ortho1.id == ortho2.id

    {:ok, ortho1} = Ortho.add(ortho1, "d", context)
    {:ok, ortho2} = Ortho.add(ortho2, "d", context)
    assert ortho1.id == ortho2.id
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
