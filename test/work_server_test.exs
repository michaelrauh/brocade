defmodule WorkServerTest do
  use ExUnit.Case, async: true

  alias WorkServer

  setup do
    {:ok, pid} = start_supervised(WorkServer)
    {:ok, pid: pid}
  end

  test "it can push and pop work", %{pid: pid} do
    :ok = WorkServer.push(pid, "one")
    :ok = WorkServer.push(pid, "two")
    {:ok, top} = WorkServer.pop(pid)
    assert top == "two"
    {:ok, pid}
  end

  test "it can push multiple though batches are reversed", %{pid: pid} do
    :ok = WorkServer.push(pid, "one")
    :ok = WorkServer.push(pid, ["two", "three"])
    {:ok, top} = WorkServer.pop(pid)
    assert top == "two"
    {:ok, pid}
  end
end
