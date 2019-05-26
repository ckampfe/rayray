defmodule Rayray.RayTest do
  use ExUnit.Case
  alias Rayray.Ray
  alias Rayray.Sphere
  alias Rayray.Tuple
  alias Rayray.Intersect
  alias Rayray.Intersection
  alias Rayray.Matrix

  test "Creating and querying a ray" do
    origin = Tuple.point(1, 2, 3)
    direction = Tuple.vector(4, 5, 6)
    r = Ray.new(origin, direction)
    assert r.origin == origin
    assert r.direction == direction
  end

  test "Computing a point from a distance" do
    r = Ray.new(Tuple.point(2, 3, 4), Tuple.vector(1, 0, 0))
    assert Ray.position(r, 0) == Tuple.point(2, 3, 4)
    assert Ray.position(r, 1) == Tuple.point(3, 3, 4)
    assert Ray.position(r, -1) == Tuple.point(1, 3, 4)
    assert Ray.position(r, 2.5) == Tuple.point(4.5, 3, 4)
  end

  test "A ray intersects a sphere at two points" do
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    [xs0, xs1] = xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert xs0.t == 4.0
    assert xs1.t == 6.0
  end

  test "A ray intersects a sphere at a tangent" do
    r = Ray.new(Tuple.point(0, 1, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    [xs0, xs1] = xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert xs0.t == 5.0
    assert xs1.t == 5.0
  end

  test "A ray misses a sphere" do
    r = Ray.new(Tuple.point(0, 2, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 0
  end

  test "A ray originates inside a sphere" do
    r = Ray.new(Tuple.point(0, 0, 0), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    [xs0, xs1] = xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert xs0.t == -1.0
    assert xs1.t == 1.0
  end

  test "A sphere is behind a ray" do
    r = Ray.new(Tuple.point(0, 0, 5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    [xs0, xs1] = xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert xs0.t == -6.0
    assert xs1.t == -4.0
  end

  test "An intersection encapsulates t and object" do
    s = Sphere.new()
    i = Intersection.new(3.5, s)
    assert i.t == 3.5
    assert i.object == s
  end

  test "aggregating intersections" do
    s = Sphere.new()
    i1 = Intersection.new(1, s)
    i2 = Intersection.new(2, s)
    [xs1, xs2] = Intersection.aggregate([i1, i2])
    assert [xs1.t, xs2.t] == [1, 2]
  end

  test "Intersect sets the object on the intersection" do
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    [xs0, xs1] = xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert xs0.object == s
    assert xs1.object == s
  end

  test "The hit, when all intersections have positive t" do
    s = Sphere.new()
    i1 = Intersection.new(1, s)
    i2 = Intersection.new(2, s)
    xs = Intersection.aggregate([i2, i1])
    i = Intersection.hit(xs)
    assert i == i1
  end

  test "The hit, when some intersections have negative t" do
    s = Sphere.new()
    i1 = Intersection.new(-1, s)
    i2 = Intersection.new(1, s)
    xs = Intersection.aggregate([i2, i1])
    i = Intersection.hit(xs)
    assert i == i2
  end

  test "The hit, when all intersections have negative t" do
    s = Sphere.new()
    i1 = Intersection.new(-2, s)
    i2 = Intersection.new(-1, s)
    xs = Intersection.aggregate([i2, i1])
    i = Intersection.hit(xs)
    assert i == nil
  end

  test "The hit is always the lowest nonnegative intersection" do
    s = Sphere.new()
    i1 = Intersection.new(5, s)
    i2 = Intersection.new(7, s)
    i3 = Intersection.new(-3, s)
    i4 = Intersection.new(2, s)
    xs = Intersection.aggregate([i1, i2, i3, i4])
    i = Intersection.hit(xs)
    assert i == i4
  end

  test "Translating a ray" do
    r = Ray.new(Tuple.point(1, 2, 3), Tuple.vector(0, 1, 0))
    m = Matrix.translation(3, 4, 5)
    r2 = Ray.transform(r, m)
    assert r2.origin == Tuple.point(4, 6, 8)
    assert r2.direction == Tuple.vector(0, 1, 0)
  end

  test "Scaling a ray" do
    r = Ray.new(Tuple.point(1, 2, 3), Tuple.vector(0, 1, 0))
    m = Matrix.scaling(2, 3, 4)
    r2 = Ray.transform(r, m)
    assert r2.origin == Tuple.point(2, 6, 12)
    assert r2.direction == Tuple.vector(0, 3, 0)
  end

  test "A sphere's default transformation" do
    s = Sphere.new()
    assert s.transform == Matrix.identity()
  end

  test "Changing a sphere's transformation" do
    s = Sphere.new()
    t = Matrix.translation(2, 3, 4)
    s = %{s | transform: t}
    assert s.transform == t
  end

  test "Intersecting a scaled sphere with a ray" do
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    s = %{s | transform: Matrix.scaling(2, 2, 2)}
    xs = Intersect.intersect(s, r)
    # assert Enum.count(xs) == 2
    assert [%{t: 3.0}, %{t: 7.0}] = xs
  end

  test "Intersecting a translated sphere with a ray" do
    r = Ray.new(Tuple.point(0, 0, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    s = %{s | transform: Matrix.translation(5, 0, 0)}
    xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 0
  end
end
