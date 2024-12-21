defmodule Pair do
  defstruct first: nil, second: nil

  def new(first, second) do
    %Pair{first: first, second: second}
  end

  def first(%Pair{first: first}), do: first
  def second(%Pair{second: second}), do: second
end
