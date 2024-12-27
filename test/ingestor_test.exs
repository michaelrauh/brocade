defmodule IngestorTest do
  use ExUnit.Case, async: false

  alias Ingestor

  setup do
    {:ok, _pid} = start_supervised(WorkerServer)
    {:ok, _pid} = start_supervised(WorkServer)
    {:ok, _pid} = start_supervised(ContextKeeper)
    {:ok, _pid} = start_supervised(Ingestor)

    WorkerServer.subscribe()
    :ok
  end

  test "it can find results" do
    context =
      MapSet.new([
        Pair.new("a", "b"),
        Pair.new("c", "d"),
        Pair.new("a", "c"),
        Pair.new("b", "d"),
        Pair.new("a", "e")
      ])

    ortho = Ortho.new()
    {:ok, ortho} = Ortho.add(ortho, "a", context)
    {:ok, ortho} = Ortho.add(ortho, "b", context)
    {:ok, ortho} = Ortho.add(ortho, "c", context)
    {:ok, ortho} = Ortho.add(ortho, "d", context)
    :ok = Ingestor.ingest("a b. c d. a c. b d.")
    WorkerServer.process()
    assert_receive :worker_server_done
    assert ortho in ContextKeeper.get_orthos()
  end
end
