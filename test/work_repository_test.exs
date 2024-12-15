defmodule WorkRepositoryTest do
  use ExUnit.Case, async: true
  alias Work
  alias WorkRepository

  test "start a new repository and check it is empty" do
    repo = WorkRepository.start()
    assert {:empty, ^repo} = WorkRepository.get_largest_and_smallest(repo)
  end

  test "add work and retrieve smallest and largest items" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
    repo = WorkRepository.add(repo, Work.new(2, ["baz"]))

    {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
    assert smallest == %Work{size: 1, contents: ["foo", "bar"]}
    assert largest == %Work{size: 2, contents: ["baz"]}
    assert repo.in_process == [{smallest, largest}]
  end

  test "add one work and retrieve the same as smallest and largest" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))

    {:same, single_work, repo} = WorkRepository.get_largest_and_smallest(repo)
    assert single_work == %Work{size: 1, contents: ["foo", "bar"]}
    assert repo.in_process == []
  end

  test "complete work and add additional item" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
    repo = WorkRepository.add(repo, Work.new(2, ["baz"]))

    {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
    repo = WorkRepository.complete(repo, smallest, largest, Work.new(3, ["quux"]))

    assert repo.in_process == []
    assert :gb_trees.to_list(repo.tree) == [{3, [%Work{size: 3, contents: ["quux"]}]}]
  end
end
