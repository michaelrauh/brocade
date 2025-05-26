defmodule WorkQueueTest do
  use ExUnit.Case, async: false

  setup do
    # Ensure a clean environment for each test
    start_supervised!(Queue)
    start_supervised!(WorkQueue)
    :ok
  end

  test "push and pop work correctly" do
    # Push an item
    assert :ok = WorkQueue.push("test item")

    # Pop should return the item with a receipt
    assert {:ok, receipt, "test item"} = WorkQueue.pop()
    assert is_map(receipt)
    assert is_pid(receipt.channel)
    assert is_integer(receipt.id)

    # Queue should be empty now
    assert nil == WorkQueue.pop()
  end

  test "ack removes item from pending" do
    # Push and pop an item
    WorkQueue.push("test item")
    {:ok, receipt, _} = WorkQueue.pop()

    # Ack the receipt
    assert :ok = WorkQueue.ack(receipt)

    # Queue should still be empty (item was acknowledged)
    assert nil == WorkQueue.pop()
  end

  test "nack puts item back in queue" do
    # Push and pop an item
    WorkQueue.push("test item")
    {:ok, receipt, _} = WorkQueue.pop()

    # Nack the receipt
    assert :ok = WorkQueue.nack(receipt)

    # Item should be back in the queue
    assert {:ok, _receipt, "test item"} = WorkQueue.pop()
  end

  test "multiple push and pop operations maintain order" do
    # Push multiple items
    WorkQueue.push("item 1")
    WorkQueue.push("item 2")
    WorkQueue.push("item 3")

    # Pop them in the same order
    assert {:ok, _, "item 1"} = WorkQueue.pop()
    assert {:ok, _, "item 2"} = WorkQueue.pop()
    assert {:ok, _, "item 3"} = WorkQueue.pop()
    assert nil == WorkQueue.pop()
  end

  test "ack and nack require valid receipts" do
    # Push and pop an item
    WorkQueue.push("test item")
    {:ok, receipt, _} = WorkQueue.pop()

    # Ack the receipt
    assert :ok = WorkQueue.ack(receipt)

    # Acking again should not cause errors
    assert :ok = WorkQueue.ack(receipt)

    # Nacking an already acked item should be a no-op
    assert :ok = WorkQueue.nack(receipt)

    # Queue should still be empty (no nil was added)
    assert nil == WorkQueue.pop()
  end
end
