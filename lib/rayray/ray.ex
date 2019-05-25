defmodule Rayray.Ray do
  alias Rayray.Tuple
  alias Rayray.Matrix

  defstruct origin: nil, direction: nil

  def new(origin, direction) do
    %__MODULE__{origin: origin, direction: direction}
  end

  def position(%__MODULE__{origin: origin, direction: direction} = _ray, t) do
    Tuple.add(origin, Tuple.multiply(direction, t))
  end

  def transform(%__MODULE__{origin: origin, direction: direction} = _ray, m) do
    origin = Matrix.multiply(m, origin)
    direction = Matrix.multiply(m, direction)
    new(origin, direction)
  end
end
