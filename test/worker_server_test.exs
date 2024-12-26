defmodule WorkerServerTest do
  use ExUnit.Case, async: false

  alias WorkerServer

  setup do
    {:ok, _pid} = start_supervised(WorkerServer)
    {:ok, _pid} = start_supervised(WorkServer)
    :ok
  end

  test "it can report on version" do
    {:ok, version} = WorkerServer.get_context_version()
    assert version == -1
  end

  test "it pops work when processing and updates context version" do
    {:ok, version} = WorkerServer.get_context_version()
    assert version == -1
    :ok = WorkerServer.process()
    {:ok, version} = WorkerServer.get_context_version()
    assert version == 0
  end
end
