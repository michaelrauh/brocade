defmodule Context do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.merge([name: __MODULE__], opts))
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end
end
