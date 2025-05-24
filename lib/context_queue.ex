defmodule ContextQueue do
  @moduledoc """
  A simplified interface to the Queue service for the context queue.
  Always uses the channel named :context_queue.
  """

  @channel_name :context_queue

  def start_link(_opts \\ []) do
    Queue.create_channel(name: @channel_name)
    {:ok, self()}
  end

  def push(data), do: Queue.push(@channel_name, data)
  def pop(), do: Queue.pop(@channel_name)
  def ack(receipt), do: Queue.ack(receipt)
  def nack(receipt), do: Queue.nack(receipt)
end
