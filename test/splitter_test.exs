defmodule SplitterTest do
  use ExUnit.Case, async: true
  alias Splitter

  test "splines filter sentences with more than 2 words" do
    input =
      "This is a book? It is!! It has Capitals and Punctuation; don't worry: It will work. It even, will strip things."

    expected = [
      ["this", "is", "a", "book"],
      ["it", "has", "capitals", "and", "punctuation"],
      ["it", "will", "work"],
      ["it", "even", "will", "strip", "things"]
    ]

    assert Splitter.splines(input) == expected
  end

  test "lines return sliding windows of size 2" do
    input =
      "This is a book? It is!! It has Capitals and Punctuation; don't worry: It will work. It even, will strip things."

    expected = [
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

    assert Splitter.lines(input) == expected
  end
end
