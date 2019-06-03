defmodule Rayray.World do
  alias Rayray.Intersect
  alias Rayray.Intersection
  alias Rayray.Lights
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Ray
  alias Rayray.Sphere
  alias Rayray.Tuple

  defstruct objects: [], light: nil

  def new() do
    %__MODULE__{}
  end

  def default() do
    light = Lights.point_light(Tuple.point(-10, 10, -10), Tuple.color(1, 1, 1))
    material = Material.new()
    material = %{material | color: Tuple.color(0.8, 1.0, 0.6), diffuse: 0.7, specular: 0.2}
    s1 = Sphere.new()
    s1 = %{s1 | material: material}
    s2 = Sphere.new()
    s2 = %{s2 | transform: Matrix.scaling(0.5, 0.5, 0.5)}

    %__MODULE__{
      objects: [s1, s2],
      light: light
    }
  end

  def contains?(%__MODULE__{objects: objects}, object) do
    :lists.member(object, objects)
  end

  def intersect_world(world, ray) do
    world.objects
    |> Enum.flat_map(fn object ->
      Intersect.intersect(object, ray)
    end)
    |> Enum.sort_by(fn %{t: t} ->
      t
    end)
  end

  def shade_hit(world, comps) do
    Lights.lighting(
      comps.object.material,
      world.light,
      comps.over_point,
      comps.eyev,
      comps.normalv,
      is_shadowed(world, comps.over_point)
    )
  end

  def color_at(world, ray) do
    intersections = intersect_world(world, ray)
    intersection = Intersection.hit(intersections)

    if is_nil(intersection) do
      Tuple.color(0, 0, 0)
    else
      comps = Intersection.prepare_computations(intersection, ray)
      shade_hit(world, comps)
    end
  end

  def is_shadowed(world, point) do
    v = Tuple.subtract(world.light.position, point)
    distance = Tuple.magnitude(v)
    direction = Tuple.normalize(v)
    ray = Ray.new(point, direction)
    intersections = intersect_world(world, ray)
    hit = Intersection.hit(intersections)

    hit && hit.t < distance
  end
end
