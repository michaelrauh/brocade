defmodule ContextTest do
  use ExUnit.Case
  import Bitwise

  setup do
    start_supervised!(ContextQueue)
    start_supervised!(WorkQueue)
    start_supervised!(Context)
    :ok
  end

  defp eventually(assertion, attempts \\ 20) do
    case assertion.() do
      :ok -> :ok
      {:error, _} = _err when attempts > 0 ->
        Process.sleep(10)
        eventually(assertion, attempts - 1)
      {:error, reason} -> flunk(reason)
    end
  end

  test "when adding a vocab word, it sets the mapping to the empty bitmask (0)" do
    :ok = ContextQueue.push({:vocab, "one"})
    Context.poll()

    eventually(fn ->
      bitmasks = Context.bitmasks()
      if Map.get(bitmasks, ["one"]) == 0, do: :ok, else: {:error, "bitmask not set"}
    end)
  end

  test "it runs until the queue is empty" do
    :ok = ContextQueue.push({:vocab, "one"})
    :ok = ContextQueue.push({:vocab, "two"})
    Context.poll()

    eventually(fn ->
      bitmasks = Context.bitmasks()
      cond do
        Map.get(bitmasks, ["one"]) != 0 -> {:error, "bitmask for 'one' not set"}
        Map.get(bitmasks, ["two"]) != 0 -> {:error, "bitmask for 'two' not set"}
        true -> :ok
      end
    end)
  end

  test "when adding a phrase it updates the mapping" do
    :ok = ContextQueue.push({:vocab, "one"})
    :ok = ContextQueue.push({:vocab, "two"})
    :ok = ContextQueue.push({:subphrase, ["one", "two"]})
    Context.poll()

    mask = 0
    mask = Bitwise.bor(mask, 1 <<< 1)

    eventually(fn ->
      bitmasks = Context.bitmasks()
      if Map.get(bitmasks, ["one"]) == mask, do: :ok, else: {:error, "bitmask not set"}
    end)
  end

  test "long phrases map heads to tails" do
    :ok = ContextQueue.push({:vocab, "one"})   # 0
    :ok = ContextQueue.push({:vocab, "two"})   # 1
    :ok = ContextQueue.push({:vocab, "three"}) # 2
    :ok = ContextQueue.push({:subphrase, ["one", "two", "three"]})
    Context.poll()

    mask = 0
    mask = Bitwise.bor(mask, 1 <<< 2)

    eventually(fn ->
      bitmasks = Context.bitmasks()
      if Map.get(bitmasks, ["one", "two"]) == mask, do: :ok, else: {:error, "mask not set"}
    end)
  end

  test "subphrases of length greater than two allow for finding masks on long prefixes" do
    :ok = ContextQueue.push({:vocab, "one"})   # 0
    :ok = ContextQueue.push({:vocab, "two"})   # 1
    :ok = ContextQueue.push({:vocab, "three"}) # 2
    :ok = ContextQueue.push({:vocab, "four"})  # 3
    :ok = ContextQueue.push({:subphrase, ["one", "two", "three"]}) # 2
    :ok = ContextQueue.push({:subphrase, ["one", "two", "four"]})  # 3
    :ok = ContextQueue.push({:subphrase, ["one", "two"]})

    Context.poll()

    mask = 0
    mask = Bitwise.bor(mask, 1 <<< 2)
    mask = Bitwise.bor(mask, 1 <<< 3)

    eventually(fn ->
      bitmasks = Context.bitmasks()
      if Map.get(bitmasks, ["one", "two"]) == mask, do: :ok, else: {:error, "mask not set"}
    end)
  end

  # TODO when it is done polling it posts a seed value
  # TODO when asked for context it returns the bitmasks and version number
  # TODO add persistence
end
