defmodule WorkServerTest do
  use ExUnit.Case, async: true

  alias WorkServer

  setup do
    {:ok, pid} = start_supervised(WorkServer)
    {:ok, pid: pid}
  end

  test "it can have work added to it", %{pid: pid} do
    assert is_pid(pid)
    :ok = WorkServer.add(pid, "some work")
  end
end
