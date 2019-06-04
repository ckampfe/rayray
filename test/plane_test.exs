defmodule Rayray.PlaneTest do
  use ExUnit.Case, async: true
  alias Rayray.LocalIntersect
  alias Rayray.LocalNormal
  alias Rayray.Plane
  alias Rayray.Ray
  alias Rayray.Tuple

  test "The normal of a plane is constant everywhere" do
    p = Plane.new()
    n1 = LocalNormal.local_normal_at(p, Tuple.point(0, 0, 0))
    n2 = LocalNormal.local_normal_at(p, Tuple.point(10, 0, -10))
    n3 = LocalNormal.local_normal_at(p, Tuple.point(-5, 0, 150))
    assert n1 == Tuple.vector(0, 1, 0)
    assert n2 == Tuple.vector(0, 1, 0)
    assert n3 == Tuple.vector(0, 1, 0)
  end

  test "Intersect with a ray parallel to the plane" do
    p = Plane.new()
    r = Ray.new(Tuple.point(0, 10, 0), Tuple.vector(0, 0, 1))
    xs = LocalIntersect.local_intersect(p, r)
    assert Enum.empty?(xs)
  end

  test "Intersect with a coplanar ray" do
    p = Plane.new()
    r = Ray.new(Tuple.point(0, 0, 0), Tuple.vector(0, 0, 1))
    xs = LocalIntersect.local_intersect(p, r)
    assert Enum.empty?(xs)
  end

  test "A ray intersecting a plane from above" do
    p = Plane.new()
    r = Ray.new(Tuple.point(0, 1, 0), Tuple.vector(0, -1, 0))
    [xs0] = xs = LocalIntersect.local_intersect(p, r)
    assert Enum.count(xs) == 1
    assert xs0.t == 1
    assert xs0.object == p
  end

  test "A ray intersecting a plane from below" do
    p = Plane.new()
    r = Ray.new(Tuple.point(0, -1, 0), Tuple.vector(0, 1, 0))
    [xs0] = xs = LocalIntersect.local_intersect(p, r)
    assert Enum.count(xs) == 1
    assert xs0.t == 1
    assert xs0.object == p
  end
end
