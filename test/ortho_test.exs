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
    ortho = Ortho.new()
    ortho = Ortho.add(ortho, "a")
    ortho = Ortho.add(ortho, "b")

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
    # remediation example:
    # required = ["a", "b"]
    # pairs = [{"a", "c"}, {"b", "c"}, {"a", "d"}, {"b", "d"}, {"a", "e"}]
    # this will return a remediation for "e". The remediation will be of the form {ortho, Pair.new("a", "e")}
  end

  test "an ortho may add again" do
    # a b | e
    # c d |

    ortho = Ortho.new()
    ortho = Ortho.add(ortho, "a")
    ortho = Ortho.add(ortho, "b")
    ortho = Ortho.add(ortho, "c")
    ortho = Ortho.add(ortho, "d")
    _ortho = Ortho.add(ortho, "e")
  end

  test "orthos built in different orders may share ids" do
    ortho1 = Ortho.new()
    ortho2 = Ortho.new()
    ortho1 = Ortho.add(ortho1, "a")
    ortho2 = Ortho.add(ortho2, "a")
    assert ortho1.id == ortho2.id

    ortho1 = Ortho.add(ortho1, "b")
    ortho2 = Ortho.add(ortho2, "c")
    assert ortho1.id != ortho2.id

    ortho1 = Ortho.add(ortho1, "c")
    ortho2 = Ortho.add(ortho2, "b")
    assert ortho1.id == ortho2.id

    ortho1 = Ortho.add(ortho1, "d")
    ortho2 = Ortho.add(ortho2, "d")
    assert ortho1.id == ortho2.id
  end
end
