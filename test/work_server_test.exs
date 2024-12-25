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
    {:ok, top, _version} = WorkServer.pop(pid)
    assert top == "two"
    {:ok, pid}
  end

  test "it will show empty if there is no work", %{pid: pid} do
    {status, top, version} = WorkServer.pop(pid)
    assert status == :error
    assert top == nil
    assert version == 0
    {:ok, pid}
  end

  test "it can push multiple though batches are reversed", %{pid: pid} do
    :ok = WorkServer.push(pid, "one")
    :ok = WorkServer.push(pid, ["two", "three"])
    {:ok, top, _version} = WorkServer.pop(pid)
    assert top == "two"
    {:ok, pid}
  end

  test "it can be notified of version updates and subsequent work will have a different version", %{pid: pid} do
    {:error, nil, version} = WorkServer.pop(pid)
    assert version == 0
    :ok = WorkServer.push(pid, "one")
    :ok = WorkServer.new_version(pid)
    :ok = WorkServer.push(pid, "two")
    {:ok, _top, version} = WorkServer.pop(pid)
    assert version == 1
    {:ok, _top, version} = WorkServer.pop(pid)
    assert version == 1
    {:ok, pid}
  end

  test "it can be stopped", %{pid: pid} do
    :ok = stop_supervised(WorkServer)
    assert Process.alive?(pid) == false
  end
end
