defmodule WorkerServerTest do
  use ExUnit.Case, async: false

  alias WorkerServer

  setup do
    {:ok, _pid} = start_supervised(WorkerServer)
    {:ok, _pid} = start_supervised(WorkServer)
    {:ok, _pid} = start_supervised(ContextKeeper)
    WorkerServer.subscribe()
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
    assert_receive :worker_server_done
    {:ok, version} = WorkerServer.get_context_version()
    assert version == 0
  end

  test "it checks for version and pulls new context if version is out of date" do
    ContextKeeper.add_pairs([{"a", "b"}])
    ContextKeeper.add_vocabulary(["a", "b"])
    :ok = WorkerServer.process()
    assert_receive :worker_server_done
    {:ok, pairs} = WorkerServer.get_pairs()
    {:ok, vocabulary} = WorkerServer.get_vocabulary()
    assert pairs == MapSet.new([{"a", "b"}])
    assert vocabulary == ["b", "a"]
  end

  test "searches for results and writes new ones back to context and the workserver" do
    Counter.start()
    ortho = Ortho.new()
    ortho = Ortho.add(ortho, "a")
    ortho = Ortho.add(ortho, "b")

    WorkServer.push(Ortho.new())
    ContextKeeper.add_pairs([{"a", "b"}])
    ContextKeeper.add_vocabulary(["a", "b"])
    :ok = WorkerServer.process()
    assert_receive :worker_server_done
    assert ortho in ContextKeeper.get_orthos()
    Counter.stop()
  end

  test "writes remediations to the context keeper" do
    Counter.start()
    WorkServer.push(Ortho.new())
    ContextKeeper.add_vocabulary(["a", "b"])
    :ok = WorkerServer.process()
    assert_receive :worker_server_done
    remediations = ContextKeeper.get_remediations()
    assert Enum.any?(remediations, fn {_ortho, pair} -> pair == {"a", "b"} end)
    Counter.stop()
  end
end
