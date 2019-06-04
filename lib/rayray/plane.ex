defmodule Rayray.Plane do
  alias Rayray.Material
  alias Rayray.Matrix

  defstruct transform: Matrix.identity(),
            material: Material.new()

  def new() do
    %__MODULE__{}
  end
end

defimpl Rayray.LocalNormal, for: Rayray.Plane do
  alias Rayray.Tuple

  def local_normal_at(_plane, _point) do
    Tuple.vector(0, 1, 0)
  end
end

defimpl Rayray.LocalIntersect, for: Rayray.Plane do
  alias Rayray.Intersection

  def local_intersect(plane, ray) do
    if :erlang.abs(ray.direction.y) < 0.00001 do
      []
    else
      t = -ray.origin.y / ray.direction.y
      [Intersection.new(t, plane)]
    end
  end
end
