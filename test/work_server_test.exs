defmodule WorkServerTest do
  use ExUnit.Case, async: false

  alias WorkServer

  setup do
    {:ok, _pid} = start_supervised(WorkServer)
    :ok
  end

  test "it can push and pop work" do
    :ok = WorkServer.push("one")
    :ok = WorkServer.push("two")
    {:ok, top, _version} = WorkServer.pop()
    assert top == "two"
  end

  test "it will show empty if there is no work" do
    {status, top, version} = WorkServer.pop()
    assert status == :empty
    assert top == nil
    assert version == 0
  end

  test "it can push multiple though batches are reversed" do
    :ok = WorkServer.push("one")
    :ok = WorkServer.push(["two", "three"])
    {:ok, top, _version} = WorkServer.pop()
    assert top == "two"
  end

  test "it can be notified of version updates and subsequent work will have a different version" do
    {:empty, nil, version} = WorkServer.pop()
    assert version == 0
    :ok = WorkServer.push("one")
    :ok = WorkServer.new_version()
    :ok = WorkServer.push("two")
    {:ok, _top, version} = WorkServer.pop()
    assert version == 1
    {:ok, _top, version} = WorkServer.pop()
    assert version == 1
  end
end
