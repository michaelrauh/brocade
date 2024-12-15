defmodule Work do
  defstruct size: 0, contents: []

  def new(size, contents), do: %Work{size: size, contents: contents}
end
