defmodule WorkerServerTest do
  use ExUnit.Case
  doctest WorkerServer

  setup do
    {:ok, _pid} = WorkerServer.start_link(:worker_server, :ok)
    :ok
  end

  test "it starts with context version -1" do
    assert -1 == WorkerServer.get_context_version()
  end


end
