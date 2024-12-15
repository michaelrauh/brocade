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
    updated_tree =
      case :gb_trees.lookup(size, tree) do
        {:value, works} ->
          if work in works do
            tree
          else
            :gb_trees.update(size, [work | works], tree)
          end

        :none ->
          :gb_trees.insert(size, [work], tree)
      end

    %{repo | tree: updated_tree}
  end

  def get_largest_and_smallest(%WorkRepository{tree: tree} = repo) do
    case :gb_trees.size(tree) do
      0 ->
        {:empty, repo}

      _ ->
        case extract_one_object(tree) do
          {:one, work} ->
            {:same, work, repo}

          :multiple ->
            tree
            |> take_and_update_smallest(repo)
            |> take_and_update_largest()
            |> handle_multiple_results()
        end
    end
  end

  defp extract_one_object(tree) do
    case :gb_trees.to_list(tree) do
      [{_key, [work]}] ->
        {:one, work}

      _ ->
        :multiple
    end
  end

  defp take_and_update_smallest(tree, repo) do
    {_key, [smallest | _rest], updated_tree} =
      case :gb_trees.take_smallest(tree) do
        {key, [smallest], new_tree} ->
          {key, [smallest], new_tree}

        {key, [smallest | rest], new_tree} ->
          if rest == [] do
            {key, [smallest | rest], :gb_trees.delete(key, new_tree)}
          else
            {key, [smallest | rest], :gb_trees.insert(key, rest, new_tree)}
          end
      end

    {smallest, %WorkRepository{repo | tree: updated_tree}}
  end

  defp take_and_update_largest({smallest, %WorkRepository{tree: tree} = repo}) do
    {_key, [largest | _remaining], updated_tree} =
      case :gb_trees.take_largest(tree) do
        {key, [largest], new_tree} ->
          {key, [largest], new_tree}

        {key, [largest | rest], new_tree} ->
          {key, [largest | rest], :gb_trees.update(key, rest, new_tree)}
      end

    {smallest, largest, %WorkRepository{repo | tree: updated_tree}}
  end

  defp handle_multiple_results({smallest, largest, repo}) do
    repo = %WorkRepository{repo | in_process: [{smallest, largest} | repo.in_process]}
    {:ok, smallest, largest, repo}
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
