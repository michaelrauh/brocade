defmodule ContextTest do
  use ExUnit.Case
  import Bitwise

  setup do
    start_supervised!(ContextQueue)
    start_supervised!(WorkQueue)
    start_supervised!(Context)
    start_supervised!(ContextDB)
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

  test "context and contextdb stay in sync after poll" do
    # Push initial state into ContextDB
    initial_vocab = %{"alpha" => 0}
    initial_bitmasks = %{["alpha"] => 0}
    ContextDB.set_all({initial_vocab, initial_bitmasks})

    # Push new vocab and subphrase into the queue
    :ok = ContextQueue.push({:vocab, "beta"})
    :ok = ContextQueue.push({:subphrase, ["alpha", "beta"]})
    Context.poll()

    eventually(fn ->
      # Check Context state
      bitmasks = Context.bitmasks()
      # Check ContextDB state
      {vocab_db, bitmasks_db} = ContextDB.get_all()

      # "beta" should be in vocab with position 1
      cond do
        Map.get(vocab_db, "beta") != 1 -> {:error, "beta not in vocab_db"}
        Map.get(bitmasks, ["alpha"]) != 2 -> {:error, "bitmask not updated in Context"}
        Map.get(bitmasks_db, ["alpha"]) != 2 -> {:error, "bitmask not updated in ContextDB"}
        true -> :ok
      end
    end)
  end

  test "get_context returns vocab, bitmasks, and correct version" do
    # Set up initial state
    vocab = %{"foo" => 0, "bar" => 1}
    bitmasks = %{["foo"] => 1, ["bar"] => 2, ["foo", "bar"] => 3}
    ContextDB.set_all({vocab, bitmasks})

    {got_vocab, got_bitmasks, version} = Context.get_context()

    assert got_vocab == vocab
    assert got_bitmasks == bitmasks
    assert version == map_size(vocab) + map_size(bitmasks)
  end

  test "poll adds a new ortho to the work queue when done" do
    # Set up initial state
    vocab = %{"foo" => 0, "bar" => 1}
    bitmasks = %{["foo"] => 1, ["bar"] => 2, ["foo", "bar"] => 3}
    ContextDB.set_all({vocab, bitmasks})

    Context.poll()
    o = Ortho.new()
    version = map_size(vocab) + map_size(bitmasks)
    eventually(fn ->
      case WorkQueue.pop() do
        {:ok, _, {^o, ^version}} -> :ok
        nil -> {:error, "ortho not in queue yet"}
        _ -> {:error, "unexpected item in queue"}
      end
    end)
  end
end
