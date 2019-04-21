defmodule Rayray.RayTest do
  use ExUnit.Case
  alias Rayray.Ray
  alias Rayray.Sphere
  alias Rayray.Tuple
  alias Rayray.Intersect

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
    xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert Enum.at(xs, 0) == 4.0
    assert Enum.at(xs, 1) == 6.0
  end

  test "A ray intersects a sphere at a tangent" do
    r = Ray.new(Tuple.point(0, 1, -5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert Enum.at(xs, 0) == 5.0
    assert Enum.at(xs, 1) == 5.0
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
    xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert Enum.at(xs, 0) == -1.0
    assert Enum.at(xs, 1) == 1.0
  end

  test "A sphere is behind a ray" do
    r = Ray.new(Tuple.point(0, 0, 5), Tuple.vector(0, 0, 1))
    s = Sphere.new()
    xs = Intersect.intersect(s, r)
    assert Enum.count(xs) == 2
    assert Enum.at(xs, 0) == -6.0
    assert Enum.at(xs, 1) == -4.0
  end
end
