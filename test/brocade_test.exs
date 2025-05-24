defmodule BrocadeTest do
  use ExUnit.Case
  doctest Brocade

  test "greets the world" do
    assert Brocade.hello() == :world
  end
end
