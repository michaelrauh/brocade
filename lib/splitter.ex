defmodule Splitter do
  @moduledoc """
  Splits a book into lines and splines.

  ## Examples

      iex> Splitter.splines("This is a book? It is!! It has Capitals and Punctuation; don't worry: It will work. It even, will strip things.")
      [
        ["this", "is", "a", "book"],
        ["it", "has", "capitals", "and", "punctuation"],
        ["it", "will", "work"],
        ["it", "even", "will", "strip", "things"]
      ]

      iex> Splitter.lines("This is a book? It is!! It has Capitals and Punctuation; don't worry: It will work. It even, will strip things.")
      [
        ["this", "is"],
        ["is", "a"],
        ["a", "book"],
        ["it", "is"],
        ["it", "has"],
        ["has", "capitals"],
        ["capitals", "and"],
        ["and", "punctuation"],
        ["don't", "worry"],
        ["it", "will"],
        ["will", "work"],
        ["it", "even"],
        ["even", "will"],
        ["will", "strip"],
        ["strip", "things"]
      ]
  """

  # Private function to process input into raw splines
  defp split_sentences(input) do
    input
    |> String.split(~r/[?!;:.]+/)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&String.replace(&1, ",", ""))
    |> Enum.map(&String.split/1)
  end

  # Public function for filtered splines (sentences with more than 2 words)
  def splines(input) do
    split_sentences(input)
    |> Enum.reject(&(length(&1) <= 2))
  end

  # Public function for lines (sliding windows of size 2)
  def lines(input) do
    split_sentences(input)
    |> Enum.flat_map(&Enum.chunk_every(&1, 2, 1, :discard))
  end
end
