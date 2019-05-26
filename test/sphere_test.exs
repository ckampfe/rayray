defmodule Rayray.SphereTest do
  use ExUnit.Case
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Normal
  alias Rayray.Sphere
  alias Rayray.Tuple

  test "The normal on a sphere at a point on the x axis" do
    s = Sphere.new()
    n = Normal.normal_at(s, Tuple.point(1, 0, 0))
    assert n == Tuple.vector(1, 0, 0)
  end

  test "The normal on a sphere at a point on the y axis" do
    s = Sphere.new()
    n = Normal.normal_at(s, Tuple.point(0, 1, 0))
    assert n == Tuple.vector(0, 1, 0)
  end

  test "The normal on a sphere at a point on the z axis" do
    s = Sphere.new()
    n = Normal.normal_at(s, Tuple.point(0, 0, 1))
    assert n == Tuple.vector(0, 0, 1)
  end

  test "The normal on a sphere at a nonaxial point" do
    sqrt_3_over_3 = :math.sqrt(3) / 3
    s = Sphere.new()
    n = Normal.normal_at(s, Tuple.point(sqrt_3_over_3, sqrt_3_over_3, sqrt_3_over_3))
    assert n == Tuple.vector(sqrt_3_over_3, sqrt_3_over_3, sqrt_3_over_3)
  end

  test "The normal is a normalized vector" do
    sqrt_3_over_3 = :math.sqrt(3) / 3
    s = Sphere.new()
    n = Normal.normal_at(s, Tuple.point(sqrt_3_over_3, sqrt_3_over_3, sqrt_3_over_3))
    assert n == Tuple.normalize(n)
  end

  test "Computing the normal on a translated sphere" do
    s = Sphere.new()
    s = %{s | transform: Matrix.translation(0, 1, 0)}
    n = Normal.normal_at(s, Tuple.point(0.0, 1.70711, -0.70711))
    assert Tuple.fuzzy_equal?(n, Tuple.vector(0.0, 0.70711, -0.70711), 0.001)
  end

  test "Computing the normal on a transformed sphere" do
    s = Sphere.new()
    m = Matrix.multiply(Matrix.scaling(1, 0.5, 1), Matrix.rotation_z(:math.pi() / 5))
    s = %{s | transform: m}
    n = Normal.normal_at(s, Tuple.point(0.0, :math.sqrt(2) / 2, -1 * :math.sqrt(2) / 2))
    assert Tuple.fuzzy_equal?(n, Tuple.vector(0.0, 0.97014, -0.24254), 0.001)
  end

  test "A sphere has a default material" do
    s = Sphere.new()
    m = s.material
    assert m == Material.new()
  end

  test "A sphere may be assigned a material" do
    s = Sphere.new()
    m = Material.new()
    m = %{m | ambient: 1}
    s = %{s | material: m}
    assert s.material == m
  end
end
