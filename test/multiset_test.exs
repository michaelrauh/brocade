defmodule MultisetTest do
  use ExUnit.Case, async: true
  alias Multiset

  test "create a new multiset and convert to list" do
    assert Multiset.new() |> Multiset.to_list() == []
  end

  test "add an element to a multiset" do
    assert Multiset.new() |> Multiset.add("a") |> Multiset.to_list() == ["a"]
  end

  test "add duplicate elements to a multiset" do
    result = Multiset.new() |> Multiset.add("a") |> Multiset.add("a") |> Multiset.to_list()
    assert result == ["a", "a"]
  end

  test "compare two equal multisets" do
    ms1 = Multiset.new() |> Multiset.add("a") |> Multiset.add("b")
    ms2 = Multiset.new() |> Multiset.add("b") |> Multiset.add("a")
    assert Multiset.eq?(ms1, ms2)
  end

  test "compare two unequal multisets" do
    ms1 = Multiset.new() |> Multiset.add("a")
    ms2 = Multiset.new() |> Multiset.add("b")
    refute Multiset.eq?(ms1, ms2)
  end
end
