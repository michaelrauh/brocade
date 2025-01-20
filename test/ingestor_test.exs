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
    Counter.start()
    ortho = Ortho.new()
    [ortho] = Ortho.add(ortho, "a")
    [ortho] = Ortho.add(ortho, "b")
    [ortho] = Ortho.add(ortho, "c")
    [ortho | _] = Ortho.add(ortho, "d")
    :ok = Ingestor.ingest("a b. c d. a c. b d.")
    WorkerServer.process()
    assert_receive :worker_server_done
    assert ortho in ContextKeeper.get_orthos()
    Counter.stop()
  end

  # todo fix
  test "it can find over results" do
    Counter.start()
    :ok = Ingestor.ingest("a b c. d e f. a d. b e. c f.")
    WorkerServer.process()
    assert_receive :worker_server_done
    expected_ortho = %Ortho{
      grid: %{
        [0, 0] => "a",
        [0, 1] => "d",
        [1, 0] => "b",
        [1, 1] => "e",
        [2, 0] => "c",
        [2, 1] => "f"
      },
      shape: [4, 2],
      position: [3, 0],
      shell: 3,
      id: "f6471772a0cf3a4e6eaf1582c0d77a07f04bb8f07516f125edb134ac450c9105"
    }
    assert Enum.member?(ContextKeeper.get_orthos(), expected_ortho)
    Counter.stop()
  end
end
