defmodule Rayray.WorldTest do
  use ExUnit.Case, async: true
  alias Rayray.Intersection
  alias Rayray.Lights
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Ray
  alias Rayray.Sphere
  alias Rayray.Tuple
  alias Rayray.World

  test "Creating a world" do
    w = World.new()
    assert w.objects == []
    assert w.light == nil
  end

  test "The default world" do
    light = Lights.point_light(Tuple.point(-10, 10, -10), Tuple.color(1, 1, 1))

    material = Material.new()
    material = %{material | color: Tuple.color(0.8, 1.0, 0.6), diffuse: 0.7, specular: 0.2}
    s1 = Sphere.new()
    s1 = %{s1 | material: material}

    s2 = Sphere.new()
    s2 = %{s2 | transform: Matrix.scaling(0.5, 0.5, 0.5)}

    w = World.default()
    assert w.light == light
    assert World.contains?(w, s1)
    assert World.contains?(w, s2)
  end

  test "Intersect a world with a ray" do
    w = World.default()
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    xs = World.intersect_world(w, r)
    assert Enum.count(xs) == 4
    assert [%{t: 4.0}, %{t: 4.5}, %{t: 5.5}, %{t: 6.0}] = xs
  end

  test "Precomputing the state of an intersection" do
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    shape = Sphere.new()
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.t == i.t
    assert comps.object == i.object
    assert comps.point == Tuple.point(0, 0, -1)
    assert comps.eyev == Tuple.vector(0, 0, -1)
    assert comps.normalv == Tuple.vector(0, 0, -1)
  end

  test "The hit, when an intersection occurs on the outside" do
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    shape = Sphere.new()
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    refute comps.inside
  end

  test "The hit, when an intersection occurs on the inside" do
    r = Ray.new(Tuple.point(0, 0, 0), Tuple.vector(0, 0, 1))
    shape = Sphere.new()
    i = Intersection.new(1, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.point == Tuple.point(0, 0, 1)
    assert comps.eyev == Tuple.vector(0, 0, -1)
    assert comps.inside
    # inverted from (0,0,1)
    assert comps.normalv == Tuple.vector(0, 0, -1)
  end

  test "Shading an intersection" do
    w = World.default()
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    shape = w.objects |> Enum.at(0)
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    c = World.shade_hit(w, comps)
    assert Tuple.fuzzy_equal?(c, Tuple.color(0.38066, 0.47583, 0.2855), 0.0001)
  end

  test "Shading an intersection from the inside" do
    w = World.default()
    w = %{w | light: Lights.point_light(Tuple.point(0, 0.25, 0), Tuple.color(1, 1, 1))}
    r = Ray.new(Tuple.point(0, 0, 0), Tuple.vector(0, 0, 1))
    shape = w.objects |> Enum.at(1)
    i = Intersection.new(0.5, shape)
    comps = Intersection.prepare_computations(i, r)
    c = World.shade_hit(w, comps)
    assert Tuple.fuzzy_equal?(c, Tuple.color(0.90498, 0.90498, 0.90498), 0.0001)
  end

  test "the color when a ray misses" do
    w = World.default()
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 1, 0))
    c = World.color_at(w, r)
    assert c == Tuple.color(0, 0, 0)
  end

  test "the color when a ray hits" do
    w = World.default()
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    c = World.color_at(w, r)
    assert Tuple.fuzzy_equal?(c, Tuple.color(0.38066, 0.47583, 0.2855), 0.0001)
  end

  test "The color with an intersection behind the ray" do
    w = World.default()
    [outer, inner] = w.objects
    outer_material = outer.material
    outer_material = %{outer_material | ambient: 1}
    inner_material = inner.material
    inner_material = %{inner_material | ambient: 1}
    outer = %{outer | material: outer_material}
    inner = %{inner | material: inner_material}

    w = %{w | objects: [outer, inner]}

    r = Ray.new(Tuple.point(0, 0, 0.75), Tuple.vector(0, 0, -1))
    c = World.color_at(w, r)

    %{objects: [_, %{material: %{color: inner_material_color}}]} = w
    assert c == inner_material_color
  end

  test "There is no shadow when nothing is collinear with point and light" do
    w = World.default()
    p = Tuple.point(0, 10, 0)
    refute World.is_shadowed(w, p)
  end

  test "The shadow when an object is between the point and the light" do
    w = World.default()
    p = Tuple.point(10, -10, 10)
    assert World.is_shadowed(w, p)
  end

  test "There is no shadow when an object is behind the light" do
    w = World.default()
    p = Tuple.point(-20, 20, -20)
    refute World.is_shadowed(w, p)
  end

  test "There is no shadow when an objejct is behind the point" do
    w = World.default()
    p = Tuple.point(-2, 2, -2)
    refute World.is_shadowed(w, p)
  end

  test "shade_hit/2 is given an intersection in a shadow" do
    s1 = Sphere.new()
    s2 = Sphere.new()
    s2 = %{s2 | transform: Matrix.translation(0, 0, 10)}

    w = World.new()

    w = %{
      w
      | light: Lights.point_light(Tuple.point(0, 0, -10), Tuple.color(1, 1, 1)),
        objects: [s1, s2]
    }

    r = Ray.new(Tuple.point(0, 0, 5), Tuple.vector(0, 0, 1))

    i = Intersection.new(4, s2)
    comps = Intersection.prepare_computations(i, r)
    c = World.shade_hit(w, comps)
    assert c == Tuple.color(0.1, 0.1, 0.1)
  end
end
