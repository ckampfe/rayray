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

defimpl Rayray.Normal, for: Rayray.Sphere do
  alias Rayray.Matrix
  alias Rayray.Tuple

  def normal_at(sphere, world_point) do
    object_point = Matrix.multiply(Matrix.inverse(sphere.transform), world_point)
    object_normal = Tuple.subtract(object_point, Tuple.point(0, 0, 0))

    world_normal =
      sphere.transform
      |> Matrix.inverse()
      |> Matrix.transpose()
      |> Matrix.multiply(object_normal)

    world_normal = %{world_normal | w: 0}

    Tuple.normalize(world_normal)
  end
end

defimpl Rayray.Intersect, for: Rayray.Sphere do
  alias Rayray.Intersection
  alias Rayray.Tuple
  alias Rayray.Matrix
  alias Rayray.Ray

  def intersect(sphere, ray) do
    ray = Ray.transform(ray, Matrix.inverse(sphere.transform))
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
