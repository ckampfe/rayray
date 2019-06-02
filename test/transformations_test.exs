defmodule Rayray.TransformationsTest do
  use ExUnit.Case, async: true
  alias Rayray.Matrix
  alias Rayray.Transformations
  alias Rayray.Tuple

  test "The transformation matrix for the default orientation" do
    from = Tuple.point(0, 0, 0)
    to = Tuple.point(0, 0, -1)
    up = Tuple.vector(0, 1, 0)
    t = Transformations.view_transform(from, to, up)
    assert t == Matrix.identity()
  end

  test "A view transformation matrix looking in positive z direction" do
    from = Tuple.point(0, 0, 0)
    to = Tuple.point(0, 0, 1)
    up = Tuple.vector(0, 1, 0)
    t = Transformations.view_transform(from, to, up)
    assert t == Matrix.scaling(-1, 1, -1)
  end

  test "The view transformation moves the world" do
    from = Tuple.point(0, 0, 8)
    to = Tuple.point(0, 0, 0)
    up = Tuple.vector(0, 1, 0)
    t = Transformations.view_transform(from, to, up)
    assert t == Matrix.translation(0, 0, -8)
  end

  test "An arbitrary view transformation" do
    from = Tuple.point(1, 3, 2)
    to = Tuple.point(4, -2, 8)
    up = Tuple.vector(1, 1, 0)
    t = Transformations.view_transform(from, to, up)

    assert t ==
             Matrix.new([
               [-0.5070925528371099, 0.5070925528371099, 0.6761234037828132, -2.366431913239846],
               [0.7677159338596801, 0.6060915267313263, 0.12121830534626524, -2.8284271247461894],
               [-0.35856858280031806, 0.5976143046671968, -0.7171371656006361, 0.0],
               [0, 0, 0, 1]
             ])
  end
end
