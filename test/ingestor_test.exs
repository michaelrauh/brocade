defmodule IngestorTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = start_supervised(ContextQueue)
    {:ok, _pid} = start_supervised(Ingestor)
    :ok
  end

  test "Ingestor GenServer starts and is alive" do
    assert Process.whereis(Ingestor)
    assert Process.alive?(Process.whereis(Ingestor))
  end

  test "it recieves corpora, splits it, and pushes results to the context queue" do
    assert :accepted = Ingestor.push("heres a test")
    assert {:ok, _receipt, {:vocab, "heres"}} = ContextQueue.pop()
    assert {:ok, _receipt, {:vocab, "a"}} = ContextQueue.pop()
    assert {:ok, _receipt, {:vocab, "test"}} = ContextQueue.pop()
    assert {:ok, _receipt, {:phrase, ["heres", "a", "test"]}} = ContextQueue.pop()
    assert {:ok, _receipt, {:phrase, ["heres", "a"]}} = ContextQueue.pop()
    assert {:ok, _receipt, {:phrase, ["a", "test"]}} = ContextQueue.pop()
  end
end
