defmodule ContextKeeperTest do
  use ExUnit.Case, async: false
  alias ContextKeeper

  setup do
    ContextKeeper.start()
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

  test "it can return which words were new when adding" do
    ContextKeeper.add_vocabulary([
      "a",
      "b",
      "b",
      "c"
    ])

    assert ContextKeeper.add_vocabulary([
             "a",
             "b",
             "c",
             "d"
           ]) == ["d"]

    ContextKeeper.stop()
  end

  test "it can take a list of remediations and return remediations that are impacted by context" do
    ContextKeeper.add_pairs([
      Pair.new("a", "b"),
      Pair.new("a", "c"),
      Pair.new("c", "d"),
      Pair.new("c", "e"),
      Pair.new("e", "f")
    ])

    res =
      ContextKeeper.get_relevant_context_for_remediations([Pair.new("c", "d"), Pair.new("g", "h")])

    assert res == [Pair.new("c", "d")]
    ContextKeeper.stop()
  end

  test "it can take in orthos and not duplicate them by hash" do
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

    ContextKeeper.add_orthos([ortho1, ortho2])

    assert ContextKeeper.get_orthos() == [ortho1]

    ContextKeeper.stop()
  end

  test "it gives back new orthos that are not duplicate by hash on add" do
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

    ContextKeeper.add_orthos([ortho1])

    assert ContextKeeper.add_orthos([ortho1, ortho2]) == [ortho2]

    ContextKeeper.stop()
  end

  test "it accepts near misses mapped to the effected orthos" do
    context = MapSet.new()
    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {status, remediation} = Ortho.add(ortho, "b", context)
    assert status == :error
    assert remediation == Pair.new("a", "b")

    ContextKeeper.add_remediations([{ortho, remediation}])

    assert ContextKeeper.get_remediations() == [{ortho, remediation}]

    ContextKeeper.stop()
  end

  test "it can remove remediations" do
    context = MapSet.new()
    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {status, remediation} = Ortho.add(ortho, "b", context)
    assert status == :error
    assert remediation == Pair.new("a", "b")

    ContextKeeper.add_remediations([{ortho, remediation}])

    assert ContextKeeper.get_remediations() == [{ortho, remediation}]

    ContextKeeper.remove_remediations([remediation])

    assert ContextKeeper.get_remediations() == []

    ContextKeeper.stop()
  end
end
