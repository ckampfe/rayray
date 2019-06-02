defmodule Rayray.Intersection do
  alias Rayray.Normal
  alias Rayray.Ray
  alias Rayray.Tuple

  defstruct t: nil, object: nil

  def new(t, object) do
    %__MODULE__{t: t, object: object}
  end

  def aggregate(intersections) when is_list(intersections) do
    intersections
  end

  def hit(intersections) do
    intersections
    |> Enum.filter(fn i -> i.t >= 0 end)
    |> Enum.sort_by(fn %{t: t} -> t end)
    |> List.first()
  end

  def prepare_computations(%__MODULE__{t: t, object: object} = _intersection, ray) do
    point = Ray.position(ray, t)
    eyev = Tuple.multiply(ray.direction, -1)
    normalv = Normal.normal_at(object, point)

    {inside?, normalv} =
      if Tuple.dot(normalv, eyev) < 0 do
        {true, Tuple.negate(normalv)}
      else
        {false, normalv}
      end

    %{
      t: t,
      object: object,
      point: point,
      eyev: eyev,
      normalv: normalv,
      inside: inside?
    }
  end
end
