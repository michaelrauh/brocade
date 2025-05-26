defmodule ResultsQueueTest do
  use ExUnit.Case, async: false

  setup do
    # Ensure a clean environment for each test
    start_supervised!(Queue)
    start_supervised!(ResultsQueue)
    :ok
  end

  test "push and pop work correctly" do
    # Push an item
    assert :ok = ResultsQueue.push("test item")

    # Pop should return the item with a receipt
    assert {:ok, receipt, "test item"} = ResultsQueue.pop()
    assert is_map(receipt)
    assert is_pid(receipt.channel)
    assert is_integer(receipt.id)

    # Queue should be empty now
    assert nil == ResultsQueue.pop()
  end

  test "ack removes item from pending" do
    # Push and pop an item
    ResultsQueue.push("test item")
    {:ok, receipt, _} = ResultsQueue.pop()

    # Ack the receipt
    assert :ok = ResultsQueue.ack(receipt)

    # Queue should still be empty (item was acknowledged)
    assert nil == ResultsQueue.pop()
  end

  test "nack puts item back in queue" do
    # Push and pop an item
    ResultsQueue.push("test item")
    {:ok, receipt, _} = ResultsQueue.pop()

    # Nack the receipt
    assert :ok = ResultsQueue.nack(receipt)

    # Item should be back in the queue
    assert {:ok, _receipt, "test item"} = ResultsQueue.pop()
  end

  test "multiple push and pop operations maintain order" do
    # Push multiple items
    ResultsQueue.push("item 1")
    ResultsQueue.push("item 2")
    ResultsQueue.push("item 3")

    # Pop them in the same order
    assert {:ok, _, "item 1"} = ResultsQueue.pop()
    assert {:ok, _, "item 2"} = ResultsQueue.pop()
    assert {:ok, _, "item 3"} = ResultsQueue.pop()
    assert nil == ResultsQueue.pop()
  end

  test "ack and nack require valid receipts" do
    # Push and pop an item
    ResultsQueue.push("test item")
    {:ok, receipt, _} = ResultsQueue.pop()

    # Ack the receipt
    assert :ok = ResultsQueue.ack(receipt)

    # Acking again should not cause errors
    assert :ok = ResultsQueue.ack(receipt)

    # Nacking an already acked item should be a no-op
    assert :ok = ResultsQueue.nack(receipt)

    # Queue should still be empty (no nil was added)
    assert nil == ResultsQueue.pop()
  end
end
