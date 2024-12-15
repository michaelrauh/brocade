defmodule WorkRepositoryTest do
  use ExUnit.Case, async: true
  alias Work
  alias WorkRepository

  test "New repositories are empty by default" do
    repo = WorkRepository.start()
    assert {:empty, ^repo} = WorkRepository.get_largest_and_smallest(repo)
  end

  test "retrieve smallest and largest can get the smallest and largest together and considers them in process" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
    repo = WorkRepository.add(repo, Work.new(2, ["baz"]))

    {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
    assert smallest == %Work{size: 1, contents: ["foo", "bar"]}
    assert largest == %Work{size: 2, contents: ["baz"]}
    assert repo.in_process == [{smallest, largest}]
    assert repo.tree == :gb_trees.empty()
  end

  test "adding two of the same size keeps them separate" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
    repo = WorkRepository.add(repo, Work.new(1, ["other", "bar"]))

    {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
    assert smallest == %Work{size: 1, contents: ["other", "bar"]}
    assert largest == %Work{size: 1, contents: ["foo", "bar"]}
    assert repo.in_process == [{smallest, largest}]
    assert repo.tree == :gb_trees.empty()
  end

  test "if only one is present get smallest and largest returns just the one and doesn't consider it in process" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))

    {:same, single_work, new_repo} = WorkRepository.get_largest_and_smallest(repo)
    assert single_work == %Work{size: 1, contents: ["foo", "bar"]}
    assert repo.in_process == []
    assert new_repo.tree == repo.tree
  end

  test "work can be completed by adding a result and giving the ingredients to make it back" do
    repo = WorkRepository.start()
    repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
    repo = WorkRepository.add(repo, Work.new(2, ["baz"]))

    {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
    repo = WorkRepository.complete(repo, smallest, largest, Work.new(3, ["quux"]))

    assert repo.in_process == []
    assert :gb_trees.to_list(repo.tree) == [{3, [%Work{size: 3, contents: ["quux"]}]}]
    assert repo.tree == {1, {3, [%Work{size: 3, contents: ["quux"]}], nil, nil}}
  end
end
