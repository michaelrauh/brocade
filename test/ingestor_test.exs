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

    # The below is getting put out. It looks like there is an issue of padding coordinates somewhere.
    # %Ortho{
    #   grid: %{[0, 0, 0] => "b", [0, 0, 1] => "f", [0, 1, 0] => "c", [1, 1] => "g"},
    #   shape: [2, 2, 2],
    #   position: [1, 0, 0],
    #   shell: 1,
    #   id: "16895d6fa101958bc255a650759bf9f9e2eda42ec2eaf074126a9f789a8e67d1"
    # },
    # %Ortho{
    #   grid: %{[0, 0, 0] => "c", [0, 0, 1] => "d", [0, 1, 0] => "g", [1, 1] => "h"},
    #   shape: [2, 2, 2],
    #   position: [1, 0, 0],
    #   shell: 1,
    #   id: "bd2033d031791986b7cd209da3afbac2067f0e9bc973e24130886b7654daf0a0"
    # },
    # %Ortho{
    #   grid: %{[0, 0, 0] => "a", [0, 0, 1] => "e", [0, 1, 0] => "b", [1, 1] => "f"},
    #   shape: [2, 2, 2],
    #   position: [1, 0, 0],
    #   shell: 1,
    #   id: "8bef204925e9f3239d533b08feae02d6799f2f3d68c138a0a26231865a998c93"
    # },
  end
end
