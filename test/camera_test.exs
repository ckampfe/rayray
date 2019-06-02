defmodule Rayray.CameraTest do
  use ExUnit.Case, async: true
  alias Rayray.Camera
  alias Rayray.Canvas
  alias Rayray.Matrix
  alias Rayray.Transformations
  alias Rayray.Tuple
  alias Rayray.World

  test "Constructing a camera" do
    hsize = 160
    vsize = 120
    field_of_view = :math.pi() / 2
    c = Camera.new(hsize, vsize, field_of_view)
    assert c.hsize == 160
    assert c.vsize == 120
    assert c.field_of_view == :math.pi() / 2
    assert c.transform == Matrix.identity()
  end

  test "The pixel size for a horizontal canvas" do
    c = Camera.new(200, 125, :math.pi() / 2)
    assert :erlang.abs(c.pixel_size - 0.01) < 0.0001
  end

  test "The pixel size for a vertical canvas" do
    c = Camera.new(125, 200, :math.pi() / 2)
    assert :erlang.abs(c.pixel_size - 0.01) < 0.0001
  end

  test "Constructing a ray through the center of the canvas" do
    c = Camera.new(201, 101, :math.pi() / 2)
    r = Camera.ray_for_pixel(c, 100, 50)
    assert r.origin == Tuple.point(0, 0, 0)
    Tuple.fuzzy_equal?(r.direction, Tuple.vector(0, 0, -1), 0.0001)
  end

  test "Constructing a ray through a corner of the canvas" do
    c = Camera.new(201, 101, :math.pi() / 2)
    r = Camera.ray_for_pixel(c, 0, 0)
    assert r.origin == Tuple.point(0, 0, 0)
    assert Tuple.fuzzy_equal?(r.direction, Tuple.vector(0.66519, 0.33259, -0.66851), 0.0001)
  end

  test "Constructing a ray when the camera is transformed" do
    c = Camera.new(201, 101, :math.pi() / 2)

    c = %{
      c
      | transform:
          Matrix.multiply(Matrix.rotation_y(:math.pi() / 4), Matrix.translation(0, -2, 5))
    }

    r = Camera.ray_for_pixel(c, 100, 50)
    assert r.origin == Tuple.point(0, 2, -5)

    assert Tuple.fuzzy_equal?(
             r.direction,
             Tuple.vector(:math.sqrt(2) / 2, 0, -:math.sqrt(2) / 2),
             0.0001
           )
  end

  test "Rendering a world with a camera" do
    w = World.default()
    c = Camera.new(11, 11, :math.pi() / 2)
    from = Tuple.point(0, 0, -5)
    to = Tuple.point(0, 0, 0)
    up = Tuple.vector(0, 1, 0)
    c = %{c | transform: Transformations.view_transform(from, to, up)}
    image = Camera.render(c, w)

    assert Tuple.fuzzy_equal?(
             Canvas.pixel_at(image, 5, 5),
             Tuple.color(0.38066, 0.47583, 0.2855),
             0.0001
           )
  end
end
