defmodule Rayray.Material do
  alias Rayray.Tuple

  defstruct color: Tuple.color(1, 1, 1),
            ambient: 0.1,
            diffuse: 0.9,
            specular: 0.9,
            shininess: 200.0

  def new() do
    %__MODULE__{}
  end
end
