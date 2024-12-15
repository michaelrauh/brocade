defmodule Multiset do
  @moduledoc """
  A simple multiset implementation.

  ## Examples

      iex> Multiset.new() |> Multiset.to_list()
      []

      iex> Multiset.new() |> Multiset.add("a") |> Multiset.to_list()
      ["a"]

      iex> Multiset.new() |> Multiset.add("a") |> Multiset.add("a") |> Multiset.to_list()
      ["a", "a"]

      iex> ms1 = Multiset.new() |> Multiset.add("a") |> Multiset.add("b")
      ...> ms2 = Multiset.new() |> Multiset.add("b") |> Multiset.add("a")
      ...> Multiset.eq?(ms1, ms2)
      true

      iex> ms1 = Multiset.new() |> Multiset.add("a")
      ...> ms2 = Multiset.new() |> Multiset.add("b")
      ...> Multiset.eq?(ms1, ms2)
      false
  """
  defstruct underlying: Map.new()

  def new() do
    %Multiset{}
  end

  def to_list(%Multiset{underlying: u}) do
    Enum.flat_map(u, fn {e, c} -> List.duplicate(e, c) end)
  end

  def add(%Multiset{underlying: u} = multiset, element) do
    %Multiset{multiset | underlying: Map.update(u, element, 1, &(&1 + 1))}
  end

  def eq?(%Multiset{underlying: a}, %Multiset{underlying: b}) do
    a == b
  end
end
