defmodule Rayray.TriangleTest do
  use ExUnit.Case, async: true
  alias Rayray.LocalIntersect
  alias Rayray.LocalNormal
  alias Rayray.Ray
  alias Rayray.Triangle
  alias Rayray.Tuple

  test "Constructing a triangle" do
    p1 = Tuple.point(0, 1, 0)
    p2 = Tuple.point(-1, 0, 0)
    p3 = Tuple.point(1, 0, 0)
    t = Triangle.new(p1, p2, p3)
    assert t.p1 == p1
    assert t.p2 == p2
    assert t.p3 == p3
    assert t.e1 == Tuple.vector(-1, -1, 0)
    assert t.e2 == Tuple.vector(1, -1, 0)
    assert t.normal == Tuple.vector(0, 0, -1)
  end

  test "Finding the normal on a triangle" do
    t = Triangle.new(Tuple.point(0, 1, 0), Tuple.point(-1, 0, 0), Tuple.point(1, 0, 0))
    n1 = LocalNormal.local_normal_at(t, Tuple.point(0, 0.5, 0))
    n2 = LocalNormal.local_normal_at(t, Tuple.point(-0.5, 0.75, 0))
    n3 = LocalNormal.local_normal_at(t, Tuple.point(0.5, 0.25, 0))
    assert n1 == t.normal
    assert n2 == t.normal
    assert n3 == t.normal
  end

  test "Intersecting a ray parallel to the triangle" do
    t = Triangle.new(Tuple.point(0, 1, 0), Tuple.point(-1, 0, 0), Tuple.point(1, 0, 0))
    r = Ray.new(Tuple.point(0, -1, -2), Tuple.vector(0, 1, 0))
    xs = LocalIntersect.local_intersect(t, r)
    assert Enum.empty?(xs)
  end

  test "A ray misses the p1-p3 edge" do
    t = Triangle.new(Tuple.point(0, 1, 0), Tuple.point(-1, 0, 0), Tuple.point(1, 0, 0))
    r = Ray.new(Tuple.point(1, 1, -2), Tuple.vector(0, 0, 1))
    xs = LocalIntersect.local_intersect(t, r)
    assert Enum.empty?(xs)
  end

  test "A ray misses the p1-p2 edge" do
    t = Triangle.new(Tuple.point(0, 1, 0), Tuple.point(-1, 0, 0), Tuple.point(1, 0, 0))
    r = Ray.new(Tuple.point(-1, 1, -2), Tuple.vector(0, 0, 1))
    xs = LocalIntersect.local_intersect(t, r)
    assert Enum.empty?(xs)
  end

  test "A ray misses the p2-p3 edge" do
    t = Triangle.new(Tuple.point(0, 1, 0), Tuple.point(-1, 0, 0), Tuple.point(1, 0, 0))
    r = Ray.new(Tuple.point(0, -1, -2), Tuple.vector(0, 0, 1))
    xs = LocalIntersect.local_intersect(t, r)
    assert Enum.empty?(xs)
  end

  test "A ray strikes a triangle" do
    t = Triangle.new(Tuple.point(0, 1, 0), Tuple.point(-1, 0, 0), Tuple.point(1, 0, 0))
    r = Ray.new(Tuple.point(0, 0.5, -2), Tuple.vector(0, 0, 1))
    [xs0] = xs = LocalIntersect.local_intersect(t, r)
    assert Enum.count(xs) == 1
    assert xs0.t == 2
  end
end
