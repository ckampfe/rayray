defmodule Rayray.CubeTest do
  use ExUnit.Case, async: true
  alias Rayray.Cube
  alias Rayray.LocalIntersect
  alias Rayray.LocalNormal
  alias Rayray.Ray
  alias Rayray.Tuple

  test "A ray intersects a cube" do
    examples = [
      {:pos_x, Tuple.point(5, 0.5, 0), Tuple.vector(-1, 0, 0), 4, 6},
      {:neg_x, Tuple.point(-5, 0.5, 0), Tuple.vector(1, 0, 0), 4, 6},
      {:pos_y, Tuple.point(0.5, 5, 0), Tuple.vector(0, -1, 0), 4, 6},
      {:neg_y, Tuple.point(0.5, -5, 0), Tuple.vector(0, 1, 0), 4, 6},
      {:pos_z, Tuple.point(0.5, 0, 5), Tuple.vector(0, 0, -1), 4, 6},
      {:neg_z, Tuple.point(0.5, 0, -5), Tuple.vector(0, 0, 1), 4, 6},
      {:inside, Tuple.point(0, 0.5, 0), Tuple.vector(0, 0, 1), -1, 1}
    ]

    c = Cube.new()

    for {_which, origin, direction, t1, t2} <- examples do
      r = Ray.new(origin, direction)
      [xs0, xs1] = xs = LocalIntersect.local_intersect(c, r)
      assert Enum.count(xs) == 2
      assert xs0.t == t1
      assert xs1.t == t2
    end
  end

  test "A ray misses a cube" do
    examples = [
      {Tuple.point(-2, 0, 0), Tuple.vector(0.2673, 0.5345, 0.8018)},
      {Tuple.point(0, -2, 0), Tuple.vector(0.8018, 0.2673, 0.5345)},
      {Tuple.point(0, 0, -2), Tuple.vector(0.5345, 0.8018, 0.2673)},
      {Tuple.point(2, 0, 2), Tuple.vector(0, 0, -1)},
      {Tuple.point(0, 2, 2), Tuple.vector(0, -1, 0)},
      {Tuple.point(2, 2, 0), Tuple.vector(-1, 0, 0)}
    ]

    c = Cube.new()

    for {origin, direction} <- examples do
      r = Ray.new(origin, direction)
      xs = LocalIntersect.local_intersect(c, r)
      assert Enum.count(xs) == 0
    end
  end

  test "The normal on the surface of a cube" do
    examples = [
      {Tuple.point(1, 0.5, -0.8), Tuple.vector(1, 0, 0)},
      {Tuple.point(-1, -0.2, 0.9), Tuple.vector(-1, 0, 0)},
      {Tuple.point(-0.4, 1, -0.1), Tuple.vector(0, 1, 0)},
      {Tuple.point(0.3, -1, -0.7), Tuple.vector(0, -1, 0)},
      {Tuple.point(-0.6, 0.3, 1), Tuple.vector(0, 0, 1)},
      {Tuple.point(0.4, 0.4, -1), Tuple.vector(0, 0, -1)},
      {Tuple.point(1, 1, 1), Tuple.vector(1, 0, 0)},
      {Tuple.point(-1, -1, -1), Tuple.vector(-1, 0, 0)}
    ]

    c = Cube.new()

    for {point, normal} <- examples do
      p = point
      n = LocalNormal.local_normal_at(c, p)
      assert n == normal
    end
  end
end
