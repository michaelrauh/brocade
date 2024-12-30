defmodule ContextKeeperTest do
  use ExUnit.Case, async: false
  alias ContextKeeper

  setup do
    {:ok, _pid} = ContextKeeper.start_link(nil)
    :ok
  end

  test "it can take multiple values at once" do
    ContextKeeper.add_pairs([
      Pair.new("a", "b"),
      Pair.new("a", "b"),
      Pair.new("c", "d")
    ])

    assert ContextKeeper.get_pairs() == [Pair.new("a", "b"), Pair.new("c", "d")]
    ContextKeeper.stop()
  end

  test "it can take in vocabulary" do
    ContextKeeper.add_vocabulary([
      "a",
      "b",
      "b",
      "c"
    ])

    assert ContextKeeper.get_vocabulary() == ["b", "a", "c"]
    ContextKeeper.stop()
  end

  test "it can return which pairs were new when adding" do
    ContextKeeper.add_pairs([
      Pair.new("a", "b"),
      Pair.new("a", "b"),
      Pair.new("c", "d")
    ])

    assert ContextKeeper.add_pairs([
             Pair.new("a", "b"),
             Pair.new("c", "d"),
             Pair.new("e", "f")
           ]) == [Pair.new("e", "f")]

    ContextKeeper.stop()
  end

  test "it can take in orthos and not duplicate them by hash" do
    Counter.start()
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

    ContextKeeper.add_orthos([ortho1, ortho2])

    assert ContextKeeper.get_orthos() == [ortho1]

    ContextKeeper.stop()
    Counter.stop()
  end

  test "it gives back new orthos that are not duplicate by hash on add" do
    Counter.start()
    ortho1 = Ortho.new()
    ortho2 = Ortho.new()
    ortho1 = Ortho.add(ortho1, "a")
    ortho2 = Ortho.add(ortho2, "a")
    assert ortho1.id == ortho2.id

    ortho1 = Ortho.add(ortho1, "b")
    ortho2 = Ortho.add(ortho2, "c")
    assert ortho1.id != ortho2.id

    ContextKeeper.add_orthos([ortho1])

    assert ContextKeeper.add_orthos([ortho1, ortho2]) == [ortho2]

    ContextKeeper.stop()
    Counter.stop()
  end

  test "it gets orthos by id" do
    Counter.start()
    ortho1 = Ortho.new()
    ortho2 = Ortho.new()
    ortho1 = Ortho.add(ortho1, "a")
    ortho2 = Ortho.add(ortho2, "a")
    assert ortho1.id == ortho2.id

    ortho1 = Ortho.add(ortho1, "b")
    ortho2 = Ortho.add(ortho2, "c")
    assert ortho1.id != ortho2.id

    ContextKeeper.add_orthos([ortho1])

    assert ContextKeeper.get_orthos_by_id([ortho1.id]) == [ortho1]

    ContextKeeper.stop()
    Counter.stop()
  end

  test "it accepts remediations with duplicates by pair" do
    Counter.start()
    ortho = Ortho.new()
    ortho = Ortho.add(ortho, "a")

    ortho2 = Ortho.new()
    ortho2 = Ortho.add(ortho, "b")

    ContextKeeper.add_remediations([{ortho, Pair.new("a", "b")}, {ortho2, Pair.new("a", "b")}, {ortho, Pair.new("a", "b")}])

    assert ContextKeeper.get_remediations() == [{ortho.id, Pair.new("a", "b")}, {ortho2.id, Pair.new("a", "b")}]

    ContextKeeper.stop()
    Counter.stop()
  end

  test "it can get remediations matching keys including duplicates" do
    Counter.start()
    ortho = Ortho.new()
    ortho = Ortho.add(ortho, "a")

    ortho2 = Ortho.new()
    ortho2 = Ortho.add(ortho, "b")

    ortho3 = Ortho.new()
    ortho3 = Ortho.add(ortho, "c")

    ContextKeeper.add_remediations([{ortho, Pair.new("a", "b")}, {ortho2, Pair.new("a", "b")}, {ortho, Pair.new("a", "b")}, {ortho3, Pair.new("f", "g")}])

    assert ContextKeeper.get_relevant_remediations([Pair.new("a", "b")]) == [{ortho.id, Pair.new("a", "b")}, {ortho2.id, Pair.new("a", "b")}]

    ContextKeeper.stop()
    Counter.stop()
  end

  test "it can get remediations and handle nothing found" do
    Counter.start()

    assert ContextKeeper.get_relevant_remediations([]) == []

    ContextKeeper.stop()
    Counter.stop()
  end

  test "it can remove remediations" do
    Counter.start()
    ortho = Ortho.new()
    ortho = Ortho.add(ortho, "a")

    ContextKeeper.add_remediations([{ortho, Pair.new("a", "b")}])

    assert ContextKeeper.get_remediations() == [{ortho.id, Pair.new("a", "b")}]

    ContextKeeper.remove_remediations([Pair.new("a", "b")])

    assert ContextKeeper.get_remediations() == []

    ContextKeeper.stop()
    Counter.stop()
  end
end
