defmodule ContextQueueTest do
  use ExUnit.Case, async: false

  setup do
    # Ensure a clean environment for each test
    start_supervised!(Queue)
    start_supervised!(ContextQueue)
    :ok
  end

  test "push and pop work correctly" do
    # Push an item
    assert :ok = ContextQueue.push("test item")

    # Pop should return the item with a receipt
    assert {:ok, receipt, "test item"} = ContextQueue.pop()
    assert is_map(receipt)
    assert is_pid(receipt.channel)
    assert is_integer(receipt.id)

    # Queue should be empty now
    assert nil == ContextQueue.pop()
  end

  test "ack removes item from pending" do
    # Push and pop an item
    ContextQueue.push("test item")
    {:ok, receipt, _} = ContextQueue.pop()

    # Ack the receipt
    assert :ok = ContextQueue.ack(receipt)

    # Queue should still be empty (item was acknowledged)
    assert nil == ContextQueue.pop()
  end

  test "nack puts item back in queue" do
    # Push and pop an item
    ContextQueue.push("test item")
    {:ok, receipt, _} = ContextQueue.pop()

    # Nack the receipt
    assert :ok = ContextQueue.nack(receipt)

    # Item should be back in the queue
    assert {:ok, _receipt, "test item"} = ContextQueue.pop()
  end

  test "multiple push and pop operations maintain order" do
    # Push multiple items
    ContextQueue.push("item 1")
    ContextQueue.push("item 2")
    ContextQueue.push("item 3")

    # Pop them in the same order
    assert {:ok, _, "item 1"} = ContextQueue.pop()
    assert {:ok, _, "item 2"} = ContextQueue.pop()
    assert {:ok, _, "item 3"} = ContextQueue.pop()
    assert nil == ContextQueue.pop()
  end

  test "ack and nack require valid receipts" do
    # Push and pop an item
    ContextQueue.push("test item")
    {:ok, receipt, _} = ContextQueue.pop()

    # Ack the receipt
    assert :ok = ContextQueue.ack(receipt)

    # Acking again should not cause errors
    assert :ok = ContextQueue.ack(receipt)

    # Nacking an already acked item should be a no-op
    assert :ok = ContextQueue.nack(receipt)

    # Queue should still be empty (no nil was added)
    assert nil == ContextQueue.pop()
  end
end
