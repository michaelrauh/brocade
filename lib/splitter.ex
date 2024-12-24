defmodule Splitter do
  @moduledoc """
  Splits a book into lines and splines.
  """

  defp split_sentences(input) do
    input
    |> String.split(~r/[?!;:.]+/)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&String.replace(&1, ",", ""))
    |> Enum.map(&String.split/1)
  end

  def splines(input) do
    split_sentences(input)
    |> Enum.reject(&(length(&1) <= 2))
  end

  def lines(input) do
    split_sentences(input)
    |> Enum.flat_map(&Enum.chunk_every(&1, 2, 1, :discard))
  end
end
