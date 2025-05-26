defmodule ResultsDatabaseTest do
  use ExUnit.Case

  alias ResultsDatabase
  alias Ortho

  setup do
    {:ok, _pid} = start_supervised(ResultsDatabase)
    :ok
  end

  def ortho(id), do: %Ortho{id: id}

  test "insert_orthos returns only new orthos" do
    o1 = ortho("a")
    o2 = ortho("b")
    assert ResultsDatabase.insert_orthos([o1, o2]) == [o1, o2]
    assert ResultsDatabase.insert_orthos([o1, o2]) == []
    o3 = ortho("c")
    assert ResultsDatabase.insert_orthos([o2, o3]) == [o3]
  end

  test "insert_remediations and get_latest_version" do
    o1 = ortho("a")
    o2 = ortho("b")
    ResultsDatabase.insert_remediations([
      {o1, ["fix1"], 1},
      {o2, ["fix2"], 2}
    ])
    assert ResultsDatabase.get_latest_version() == 2
  end

  test "get_out_of_date returns up to 100 remediations with lower version" do
    o = ortho("x")
    rems = for v <- 1..150, do: {o, ["r#{v}"], v}
    ResultsDatabase.insert_remediations(rems)
    out = ResultsDatabase.get_out_of_date(101)
    assert length(out) == 100
    assert Enum.all?(out, fn {_, _, v} -> v < 101 end)
  end

  test "update_remediations overwrites version" do
    o = ortho("z")
    ResultsDatabase.insert_remediations([{o, ["old"], 1}])
    ResultsDatabase.update_remediations([{o, ["old"], 1}], 5)
    assert ResultsDatabase.get_latest_version() == 5
    out = ResultsDatabase.get_out_of_date(6)
    assert Enum.any?(out, fn {ortho2, _, v} -> ortho2.id == o.id and v == 5 end)
  end
end
