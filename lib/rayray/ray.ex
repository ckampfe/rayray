defmodule Rayray.Ray do
  alias Rayray.Tuple

  defstruct origin: nil, direction: nil

  def new(origin, direction) do
    %__MODULE__{origin: origin, direction: direction}
  end

  def position(%__MODULE__{origin: origin, direction: direction} = _ray, t) do
    Tuple.add(origin, Tuple.multiply(direction, t))
  end
end
