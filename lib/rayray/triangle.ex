defmodule Rayray.Triangle do
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Tuple

  defstruct [
    :p1,
    :p2,
    :p3,
    :e1,
    :e2,
    :normal,
    transform: Matrix.identity(),
    material: Material.new()
  ]

  def new(p1, p2, p3) do
    e1 = Tuple.subtract(p2, p1)
    e2 = Tuple.subtract(p3, p1)
    normal = Tuple.normalize(Tuple.cross(e2, e1))

    %__MODULE__{p1: p1, p2: p2, p3: p3, e1: e1, e2: e2, normal: normal}
  end
end

defimpl Rayray.LocalNormal, for: Rayray.Triangle do
  def local_normal_at(triangle, _ray) do
    triangle.normal
  end
end

defimpl Rayray.LocalIntersect, for: Rayray.Triangle do
  alias Rayray.Intersection
  alias Rayray.Tuple

  def local_intersect(triangle, ray) do
    dir_cross_e2 = Tuple.cross(ray.direction, triangle.e2)
    det = Tuple.dot(triangle.e1, dir_cross_e2)

    if :erlang.abs(det) < 0.00001 do
      []
    else
      f = 1.0 / det
      p1_to_origin = Tuple.subtract(ray.origin, triangle.p1)
      u = f * Tuple.dot(p1_to_origin, dir_cross_e2)

      if u < 0 || u > 1 do
        []
      else
        origin_cross_e1 = Tuple.cross(p1_to_origin, triangle.e1)
        v = f * Tuple.dot(ray.direction, origin_cross_e1)

        if v < 0 || u + v > 1 do
          []
        else
          t = f * Tuple.dot(triangle.e2, origin_cross_e1)
          [Intersection.new(t, triangle)]
        end
      end
    end
  end
end
