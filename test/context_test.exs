defmodule ContextTest do
  use ExUnit.Case

  setup do
    {:ok, _pid} = start_supervised(Context)
    :ok
  end

  test "Context GenServer starts and is alive" do
    assert Process.whereis(Context)
    assert Process.alive?(Process.whereis(Context))
  end
end
