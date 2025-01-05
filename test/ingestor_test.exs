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

  # test "it can find results" do
  #   Counter.start()
  #   ortho = Ortho.new()
  #   [ortho] = Ortho.add(ortho, "a")
  #   [ortho] = Ortho.add(ortho, "b")
  #   [ortho] = Ortho.add(ortho, "c")
  #   [ortho | _] = Ortho.add(ortho, "d")
  #   :ok = Ingestor.ingest("a b. c d. a c. b d.")
  #   WorkerServer.process()
  #   assert_receive :worker_server_done
  #   assert ortho in ContextKeeper.get_orthos()
  #   Counter.stop()
  # end

  # todo fix
  test "it can find over results" do
    Counter.start()
    :ok = Ingestor.ingest("a b c d. e f g h. a e. b f. c g. d h.")
    WorkerServer.process()
    assert_receive :worker_server_done
    # it should have a non-square shape reflecting the input
    IO.inspect(ContextKeeper.get_orthos())
    Counter.stop()
  end
end
