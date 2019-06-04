defmodule Rayray.Sphere do
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Tuple

  defstruct origin: Tuple.point(0, 0, 0),
            radius: 1,
            transform: Matrix.identity(),
            material: Material.new()

  def new() do
    %__MODULE__{}
  end
end

defimpl Rayray.LocalNormal, for: Rayray.Sphere do
  alias Rayray.Tuple

  def local_normal_at(_sphere, local_point) do
    local_point
  end
end

defimpl Rayray.LocalIntersect, for: Rayray.Sphere do
  alias Rayray.Intersection
  alias Rayray.Tuple

  def local_intersect(sphere, ray) do
    sphere_to_ray = Tuple.subtract(ray.origin, sphere.origin)
    a = Tuple.dot(ray.direction, ray.direction)
    b = 2 * Tuple.dot(ray.direction, sphere_to_ray)
    c = Tuple.dot(sphere_to_ray, sphere_to_ray) - 1

    disciminant = :math.pow(b, 2) - 4 * a * c

    if disciminant < 0 do
      []
    else
      t1 = (-b - :math.sqrt(disciminant)) / (2 * a)
      t2 = (-b + :math.sqrt(disciminant)) / (2 * a)
      Enum.map([t1, t2], fn t -> Intersection.new(t, sphere) end)
    end
  end
end
