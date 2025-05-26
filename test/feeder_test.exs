defmodule FeederTest do
  use ExUnit.Case


  defp eventually(assertion, attempts \\ 20) do
    case assertion.() do
      :ok -> :ok
      {:error, _} = _err when attempts > 0 ->
        Process.sleep(10)
        eventually(assertion, attempts - 1)
      {:error, reason} -> flunk(reason)
    end
  end

  setup do
    {:ok, _pid} = start_supervised(Feeder)
    {:ok, _pid} = start_supervised(ResultsQueue)
    {:ok, _pid} = start_supervised(ResultsDatabase)
    {:ok, _pid} = start_supervised(WorkQueue)
    :ok
  end

  test "Feeder pops off of the results queue, writing to DB and the work queue" do
    o = Ortho.new()
    ResultsQueue.push({:ortho, o, 5})

    Feeder.poll()
    eventually fn ->
      case {ResultsDatabase.get_orthos(), WorkQueue.pop()} do
        {[^o], {:ok, _receipt, {:ortho, ^o, 5}}} -> :ok
        {[^o], _} -> {:error, "ortho not found in WorkQueue with correct version"}
        _ -> {:error, "ortho not found in ResultsDatabase"}
      end
    end
  end

  # assert that only new stuff gets pushed to the work queue
  # assert that it keeps going
end
