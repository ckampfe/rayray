defmodule Rayray.TupleTest do
  use ExUnit.Case
  alias Rayray.Tuple

  test "tuple with w=1.0 is a point" do
    t = Tuple.tuple(4.3, -4.2, 3.1, 1.0)
    assert %{x: 4.3, y: -4.2, z: 3.1, w: 1.0} = t
  end

  test "tuple with w=0 is a vector" do
    t = Tuple.tuple(4.3, -4.2, 3.1, 0.0)
    assert %{x: 4.3, y: -4.2, z: 3.1, w: 0.0} = t
  end

  test "point creates a tuple with w=1" do
    t = Tuple.point(4.3, -4.2, 3.1)
    assert %{x: 4.3, y: -4.2, z: 3.1, w: 1.0} = t
  end

  test "vector creates a tuple with w=0" do
    t = Tuple.vector(4.3, -4.2, 3.1)
    assert %{x: 4.3, y: -4.2, z: 3.1, w: 0.0} = t
  end

  test "adds tuples" do
    t1 = Tuple.tuple(3, -2, 5, 1)
    t2 = Tuple.tuple(-2, 3, 1, 0)
    assert Tuple.add(t1, t2) == %{x: 1, y: 1, z: 6, w: 1}
  end

  test "subtracts two points" do
    p1 = Tuple.point(3, 2, 1)
    p2 = Tuple.point(5, 6, 7)
    assert Tuple.subtract(p1, p2) == %{x: -2, y: -4, z: -6, w: 0.0}
  end

  test "subtracting a vector from a point" do
    p = Tuple.point(3, 2, 1)
    v = Tuple.vector(5, 6, 7)
    assert Tuple.subtract(p, v) == %{x: -2, y: -4, z: -6, w: 1.0}
  end

  test "subtracting two vectors" do
    v1 = Tuple.vector(3, 2, 1)
    v2 = Tuple.vector(5, 6, 7)
    assert Tuple.subtract(v1, v2) == %{x: -2, y: -4, z: -6, w: 0.0}
  end

  test "subtracting a vector from the zero vector" do
    zero = Tuple.vector(0, 0, 0)
    v = Tuple.vector(1, -2, 3)
    assert Tuple.subtract(zero, v) == %{x: -1, y: 2, z: -3, w: 0.0}
  end

  test "negating a tuple" do
    a = Tuple.tuple(1, -2, 3, -4)
    assert Tuple.negate(a) == Tuple.tuple(-1, 2, -3, 4)
  end

  test "multiplying a tuple by a scalar" do
    a = Tuple.tuple(1, -2, 3, -4)
    assert Tuple.multiply(a, 3.5) == Tuple.tuple(3.5, -7, 10.5, -14)
  end

  test "multiplying a tupel by a fraction" do
    a = Tuple.tuple(1, -2, 3, -4)
    assert Tuple.multiply(a, 0.5) == Tuple.tuple(0.5, -1, 1.5, -2)
  end

  test "dividing a tuple by a scalar" do
    a = Tuple.tuple(1, -2, 3, -4)
    assert Tuple.divide(a, 2) == Tuple.tuple(0.5, -1, 1.5, -2)
  end

  test "computing the magnitude of vector(1, 0, 0)" do
    v = Tuple.vector(1, 0, 0)
    assert Tuple.magnitude(v) == 1
  end

  test "computing the magnitude of vector(0, 1, 0)" do
    v = Tuple.vector(0, 1, 0)
    assert Tuple.magnitude(v) == 1
  end

  test "computing the magnitude of vector(0, 0, 1)" do
    v = Tuple.vector(0, 0, 1)
    assert Tuple.magnitude(v) == 1
  end

  test "computing the magnitude of vector(1, 2, 3)" do
    v = Tuple.vector(1, 2, 3)
    assert Tuple.magnitude(v) == :math.sqrt(14)
  end

  test "computing the magnitude of vector(-1, -2, -3)" do
    v = Tuple.vector(-1, -2, -3)
    assert Tuple.magnitude(v) == :math.sqrt(14)
  end

  test "normalizing vector(4, 0, 0) gives (1, 0, 0)" do
    v = Tuple.vector(4, 0, 0)
    assert Tuple.normalize(v) == Tuple.vector(1, 0, 0)
  end

  test "normalizing vector(1, 2, 3)" do
    v = Tuple.vector(1, 2, 3)

    assert Tuple.normalize(v) ==
             Tuple.vector(1 / :math.sqrt(14), 2 / :math.sqrt(14), 3 / :math.sqrt(14))
  end

  test "the magnitude of a normalized vector" do
    v = Tuple.vector(1, 2, 3)
    norm = Tuple.normalize(v)
    assert Tuple.magnitude(norm) == 1
  end

  test "the dot product of two tuples" do
    a = Tuple.vector(1, 2, 3)
    b = Tuple.vector(2, 3, 4)
    assert Tuple.dot(a, b) == 20
  end

  test "the cross product of two vectors" do
    a = Tuple.vector(1, 2, 3)
    b = Tuple.vector(2, 3, 4)
    assert Tuple.cross(a, b) == Tuple.vector(-1, 2, -1)
    assert Tuple.cross(b, a) == Tuple.vector(1, -2, 1)
  end
end
