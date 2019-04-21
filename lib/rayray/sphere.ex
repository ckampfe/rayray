defmodule Rayray.Sphere do
  alias Rayray.Tuple

  defstruct origin: nil, radius: 1

  def new() do
    %__MODULE__{origin: Tuple.point(0, 0, 0)}
  end
end

defimpl Rayray.Intersect, for: Rayray.Sphere do
  alias Rayray.Tuple

  def intersect(sphere, ray) do
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
      [t1, t2]
    end
  end
end
