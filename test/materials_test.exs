defmodule Rayray.MaterialsTest do
  use ExUnit.Case, async: true
  alias Rayray.Lights
  alias Rayray.Material
  alias Rayray.Tuple

  test "The default material" do
    m = Material.new()
    assert m.color == Tuple.color(1, 1, 1)
    assert m.ambient == 0.1
    assert m.diffuse == 0.9
    assert m.specular == 0.9
    assert m.shininess == 200.0
  end

  test "Lighting with the eye between the light and the surface" do
    m = Material.new()
    position = Tuple.point(0, 0, 0)
    eyev = Tuple.vector(0, 0, -1)
    normalv = Tuple.vector(0, 0, -1)
    light = Lights.point_light(Tuple.point(0, 0, -10), Tuple.color(1, 1, 1))
    result = Lights.lighting(m, light, position, eyev, normalv)
    assert result == Tuple.color(1.9, 1.9, 1.9)
  end

  test "Lighting with the eye between light and surface, eye offset 45 degrees" do
    m = Material.new()
    position = Tuple.point(0, 0, 0)
    eyev = Tuple.vector(0, :math.sqrt(2) / 2, -1 * :math.sqrt(2) / 2)
    normalv = Tuple.vector(0, 0, -1)
    light = Lights.point_light(Tuple.point(0, 0, -10), Tuple.color(1, 1, 1))
    result = Lights.lighting(m, light, position, eyev, normalv)
    assert result == Tuple.color(1.0, 1.0, 1.0)
  end

  test "Lighting with the eye opposite surface, light offset 45 degrees" do
    m = Material.new()
    position = Tuple.point(0, 0, 0)
    eyev = Tuple.vector(0, 0, -1)
    normalv = Tuple.vector(0, 0, -1)
    light = Lights.point_light(Tuple.point(0, 10, -10), Tuple.color(1, 1, 1))
    result = Lights.lighting(m, light, position, eyev, normalv)
    assert Tuple.fuzzy_equal?(result, Tuple.color(0.7364, 0.7364, 0.7364), 0.0001)
  end

  test "Lighting with eye in the path of the reflection vector" do
    m = Material.new()
    position = Tuple.point(0, 0, 0)
    eyev = Tuple.vector(0, -1 * :math.sqrt(2) / 2, -1 * :math.sqrt(2) / 2)
    normalv = Tuple.vector(0, 0, -1)
    light = Lights.point_light(Tuple.point(0, 10, -10), Tuple.color(1, 1, 1))
    result = Lights.lighting(m, light, position, eyev, normalv)
    assert Tuple.fuzzy_equal?(result, Tuple.color(1.6364, 1.6364, 1.6364), 0.0001)
  end

  test "Lighting with the light behind the surface" do
    m = Material.new()
    position = Tuple.point(0, 0, 0)
    eyev = Tuple.vector(0, 0, -1)
    normalv = Tuple.vector(0, 0, -1)
    light = Lights.point_light(Tuple.point(0, 0, 10), Tuple.color(1, 1, 1))
    result = Lights.lighting(m, light, position, eyev, normalv)
    assert result == Tuple.color(0.1, 0.1, 0.1)
  end
end
