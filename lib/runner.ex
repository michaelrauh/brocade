alias Ortho
alias Splitter

defmodule Runner do
  def run do
    {:ok, contents} = File.read("example.txt")

    lines = contents |> Splitter.lines()
    vocabulary = contents |> Splitter.vocabulary()
    q = :queue.new()

    context =
      Enum.map(lines, fn [left, right] ->
        Pair.new(left, right)
      end)
      |> MapSet.new()

    ortho = Ortho.new()
    q = :queue.in(ortho, q)
    process_queue(q, context, vocabulary)
  end

  defp process_queue(q, context, vocabulary) do
    IO.inspect(:queue.len(q))
    case :queue.out(q) do
      {:empty, _} ->
        :ok

      {{:value, item}, new_q} ->
        IO.inspect(item)

        new_items =
          Enum.map(vocabulary, fn word ->
            case Ortho.add(item, word, context) do
              {:ok, new_item} ->
                new_item

              {:error, _missing_pair} ->
                nil

              {:diag, _extra_word_in_shell} ->
                nil
            end
          end)
          |> Enum.reject(fn x -> x == nil end)
          |> Enum.dedup_by(fn x -> x.id end)

        new_q = Enum.reduce(new_items, new_q, fn x, acc -> :queue.in(x, acc) end)

        process_queue(new_q, context, vocabulary)
    end
  end
end
