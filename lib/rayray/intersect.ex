defprotocol Rayray.LocalIntersect do
  @doc "Calculates the intersects of the ray on the object"
  def local_intersect(object, ray)
end

defmodule Rayray.Intersect do
  alias Rayray.LocalIntersect
  alias Rayray.Matrix
  alias Rayray.Ray

  def intersect(obj, ray) do
    local_ray = Ray.transform(ray, Matrix.inverse(obj.transform))
    LocalIntersect.local_intersect(obj, local_ray)
  end
end
