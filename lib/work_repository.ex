defmodule WorkRepository do
  alias Work

  @moduledoc """
  A module to manage work items in a repository.

  Add work when desired, then call `get_largest_and_smallest/1` for processing.
  This can do one of three things:

  1. Return empty. This should only occur if the repository is empty.
  2. Return one item. The repository remains unaltered.
  3. Return the largest and smallest items. These are moved to in-process until marked complete.

  ## Examples

      iex> repo = WorkRepository.start()
      iex> repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
      iex> repo = WorkRepository.add(repo, Work.new(2, ["baz"]))
      iex> {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
      iex> smallest
      %Work{size: 1, contents: ["foo", "bar"]}
      iex> largest
      %Work{size: 2, contents: ["baz"]}
      iex> repo.in_process
      [{%Work{size: 1, contents: ["foo", "bar"]}, %Work{size: 2, contents: ["baz"]}}]
      iex> :gb_trees.to_list(repo.tree)
      []

      iex> repo = WorkRepository.start()
      iex> repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
      iex> {:same, single_work, repo} = WorkRepository.get_largest_and_smallest(repo)
      iex> single_work
      %Work{size: 1, contents: ["foo", "bar"]}
      iex> repo.in_process
      []
      iex> :gb_trees.to_list(repo.tree)
      [{1, [%Work{size: 1, contents: ["foo", "bar"]}]}]

      iex> repo = WorkRepository.start()
      iex> {:empty, repo} = WorkRepository.get_largest_and_smallest(repo)
      iex> repo.in_process
      []
      iex> :gb_trees.to_list(repo.tree)
      []

      iex> repo = WorkRepository.start()
      iex> repo = WorkRepository.add(repo, Work.new(1, ["foo", "bar"]))
      iex> repo = WorkRepository.add(repo, Work.new(2, ["baz"]))
      iex> {:ok, smallest, largest, repo} = WorkRepository.get_largest_and_smallest(repo)
      iex> repo = WorkRepository.complete(repo, smallest, largest, Work.new(3, ["quux"]))
      iex> repo.in_process
      []
      iex> :gb_trees.to_list(repo.tree)
      [{3, [%Work{size: 3, contents: ["quux"]}]}]
  """

  defstruct tree: :gb_trees.empty(), in_process: []

  @type t :: %WorkRepository{tree: :gb_trees.tree(), in_process: [Work | {Work, Work}]}

  def start(), do: %WorkRepository{}

  def add(%WorkRepository{tree: tree} = repo, %Work{size: size} = work) do
    id = System.unique_integer([:monotonic])
    key = {size, id}
    updated_tree = :gb_trees.insert(key, work, tree)
    %{repo | tree: updated_tree}
  end

  def get_largest_and_smallest(%WorkRepository{tree: tree} = repo) do
    case :gb_trees.size(tree) do
      0 ->
        {:empty, repo}

      1 ->
        {_key, work} = :gb_trees.smallest(tree)
        {:same, work, repo}

      _ ->
        {_smallest_key, smallest, tree1} = :gb_trees.take_smallest(tree)
        {_largest_key, largest, updated_tree} = :gb_trees.take_largest(tree1)

        repo = %WorkRepository{
          repo
          | tree: updated_tree,
            in_process: [{smallest, largest} | repo.in_process]
        }

        {:ok, smallest, largest, repo}
    end
  end

  def complete(repo, smallest, largest, additional) do
    repo
    |> add(additional)
    |> remove_in_process(smallest, largest)
  end

  defp remove_in_process(%WorkRepository{in_process: in_process} = repo, smaller, larger) do
    updated_in_process = Enum.reject(in_process, &(&1 == {smaller, larger}))
    %{repo | in_process: updated_in_process}
  end
end
