defmodule WorkerServerTest do
  use ExUnit.Case, async: true

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
end
