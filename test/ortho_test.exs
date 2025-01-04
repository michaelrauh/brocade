defmodule OrthoTest do
  use ExUnit.Case, async: true

  alias Ortho

  test "an ortho may be queried for its requirements" do
    Counter.start()
    ortho = Ortho.new()
    {forbidden, required} = Ortho.get_requirements(ortho)
    assert forbidden == MapSet.new()
    assert required == []
    Counter.stop()
  end

  test "an ortho may have forbidden diagonals and required pair prefixes" do
    Counter.start()
    ortho = Ortho.new()
    [ortho] = Ortho.add(ortho, "a")
    [ortho] = Ortho.add(ortho, "b")

    {forbidden, required} = Ortho.get_requirements(ortho)
    assert forbidden == MapSet.new(["b"])
    assert required == ["a"]
    Counter.stop()
  end

  test "an ortho may add again" do
    # a b | e
    # c d |

    Counter.start()
    ortho = Ortho.new()
    [ortho] = Ortho.add(ortho, "a")
    [ortho] = Ortho.add(ortho, "b")
    [ortho] = Ortho.add(ortho, "c")
    [ortho| _others] = Ortho.add(ortho, "d")
    _ortho = Ortho.add(ortho, "e")
    Counter.stop()
  end

  test "orthos built in different orders may share ids" do
    Counter.start()
    ortho1 = Ortho.new()
    ortho2 = Ortho.new()
    [ortho1] = Ortho.add(ortho1, "a")
    [ortho2] = Ortho.add(ortho2, "a")
    assert ortho1.id == ortho2.id

    [ortho1] = Ortho.add(ortho1, "b")
    [ortho2] = Ortho.add(ortho2, "c")
    assert ortho1.id != ortho2.id

    [ortho1] = Ortho.add(ortho1, "c")
    [ortho2] = Ortho.add(ortho2, "b")
    assert ortho1.id == ortho2.id

    [ortho1 | _] = Ortho.add(ortho1, "d")
    [ortho2 | _] = Ortho.add(ortho2, "d")
    assert ortho1.id == ortho2.id
    Counter.stop()
  end
end
