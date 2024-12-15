defmodule WorkRepositoryServerTest do
  use ExUnit.Case, async: true
  alias Work
  alias WorkRepositoryServer

  test "add works and process with server" do
    if Process.whereis(WorkRepositoryServer) do
      WorkRepositoryServer.clear_and_stop()
    end

    {:ok, _pid} = WorkRepositoryServer.start_link(nil)

    WorkRepositoryServer.add(Work.new(1, ["first"]))
    WorkRepositoryServer.add(Work.new(2, ["second"]))

    {:ok, smallest, largest} = WorkRepositoryServer.get_largest_and_smallest()
    assert smallest == %Work{size: 1, contents: ["first"]}
    assert largest == %Work{size: 2, contents: ["second"]}

    WorkRepositoryServer.complete(smallest, largest, Work.new(3, ["third"]))
    WorkRepositoryServer.clear_and_stop()
  end
end
