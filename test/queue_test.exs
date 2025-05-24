defmodule QueueTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = start_supervised(Queue)
    :ok
  end

  test "Queue GenServer starts and is alive" do
    assert Process.whereis(Queue)
    assert Process.alive?(Process.whereis(Queue))
  end

  test "it allows creating a channel with a name" do
    assert {:ok, channel} = Queue.create_channel(name: :my_channel)
    assert is_pid(channel)
    assert Process.whereis(:my_channel) == channel
  end

  test "it allows pushing data to a channel" do
    assert {:ok, channel} = Queue.create_channel(name: :my_channel)
    assert :ok = Queue.push(channel, "test_data")
  end

  test "it allows popping data from a channel and returns a receipt" do
    assert {:ok, channel} = Queue.create_channel(name: :my_channel)
    assert :ok = Queue.push(channel, "test_data")
    assert {:ok, _receipt, "test_data"} = Queue.pop(channel)
  end

  test "it allows acking on a receipt" do
    assert {:ok, channel} = Queue.create_channel(name: :my_channel)
    assert :ok = Queue.push(channel, "test_data")
    assert {:ok, receipt, "test_data"} = Queue.pop(channel)
    assert :ok = Queue.ack(receipt)
  end

  test "nacked data is requeued" do
    assert {:ok, channel} = Queue.create_channel(name: :my_channel)
    assert :ok = Queue.push(channel, "test_data")
    assert {:ok, receipt, "test_data"} = Queue.pop(channel)
    assert :ok = Queue.nack(receipt)
    assert {:ok, _receipt, "test_data"} = Queue.pop(channel)
  end
end
