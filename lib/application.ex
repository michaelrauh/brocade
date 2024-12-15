defmodule Brocade.Application do
  use Application

  def main(_args) do
    IO.puts("Hello world")
  end

  @impl true
  def start(_type, _args) do
    IO.puts("Starting Brocade Application")

    children = [
      {Ingestor, []}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
