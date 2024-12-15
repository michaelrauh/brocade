defmodule WorkRepositoryServerTest do
  use ExUnit.Case, async: true
  alias Work
  alias WorkRepositoryServer

  test "add works and process with server" do
    {:ok, _pid} = WorkRepositoryServer.start_link(nil)

    WorkRepositoryServer.add(Work.new(1, ["foo", "bar"]))
    WorkRepositoryServer.add(Work.new(1, ["other", "bar"]))
    WorkRepositoryServer.add(Work.new(2, ["baz"]))

    {:ok, smallest, largest} = WorkRepositoryServer.get_largest_and_smallest()
    assert smallest == %Work{size: 1, contents: ["other", "bar"]}
    assert largest == %Work{size: 2, contents: ["baz"]}

    WorkRepositoryServer.complete(smallest, largest, Work.new(3, ["quux"]))
    # todo add check on complete
    assert true
  end
end
