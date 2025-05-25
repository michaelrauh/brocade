defmodule SplitterTest do
  use ExUnit.Case, async: false
  alias Splitter

  test "phrases returns all subphrases of size greater than one" do
    input =
      "This is a book? It is!! It has Capitals and Punctuation; don't worry: It will work. It even, will strip things."

    expected = [
      ["this", "is", "a", "book"],
      ["it", "has", "capitals", "and", "punctuation"],
      ["it", "will", "work"],
      ["it", "even", "will", "strip", "things"],
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

    assert Enum.sort(Splitter.phrases(input)) == Enum.sort(expected)
  end

  test "vocabulary returns all unique words" do
    input =
      "This is a book? It is!! It has Capitals and Punctuation; don't worry: It will work. It even, will strip things."

    expected = [
      "this", "is", "a", "book", "it", "has", "capitals", "and", "punctuation",
      "don't", "worry", "will", "work", "even", "strip", "things"
    ] |> Enum.sort()

    assert Enum.sort(Splitter.vocabulary(input)) == expected
  end
end
