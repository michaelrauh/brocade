defmodule OrthoTest do
  use ExUnit.Case, async: true

  alias Ortho

  test "an ortho may be queried for its requirements" do
    ortho = Ortho.new()
    {forbidden, required} = Ortho.get_requirements(ortho)
    assert forbidden == MapSet.new()
    assert required == []
  end

  test "an ortho may have forbidden diagonals and required pair prefixes" do
    context = MapSet.new([Pair.new("a", "b")])

    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {:ok, ortho} = Ortho.add(ortho, "b", context)

    {forbidden, required} = Ortho.get_requirements(ortho)
    assert forbidden == MapSet.new(["b"])
    assert required == ["a"]

    # when calling:
    # filter forbidden from vocabulary
    # to manage required:
    # give back all in context that don't violate.
    # for example, required "a" means filter for pairs that have "a" as the first element
    # if there is a second requirement, then it must intersect for a particular second value.
    # if it is empty it's an empty series of filters and will return the whole vocabulary

    # pair filtering example:
    # required = ["a", "b"]
    # pairs = [{"a", "c"}, {"b", "c"}, {"a", "d"}, {"b", "d"}, {"a", "e"}]
    # This will return valid things are c and d.
    # that's because c and d each follow both a and b. e follows a but not b.

    # tracking remediations:
    # run the filters in series and if any filter fails, that becomes the remediation.
    # this will be a big change to remediations, as it is only a single prefix rather than the whole pair.
    # that will mean that when seeing if a remediation is invalidated it will be necessary to pull by prefix and
    # invalidate by prefix. It will also cut down on storage.
  end

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
