defmodule Rayray.MatrixTest do
  use ExUnit.Case
  alias Rayray.Matrix
  alias Rayray.Tuple

  test "constructing and inspecting a 4x4 matrix" do
    m =
      Matrix.new([[1, 2, 3, 4], [5.5, 6.5, 7.5, 8.5], [9, 10, 11, 12], [13.5, 14.5, 15.5, 16.5]])

    assert Matrix.get(m, {0, 0}) == 1
    assert Matrix.get(m, {0, 3}) == 4
    assert Matrix.get(m, {1, 0}) == 5.5
    assert Matrix.get(m, {1, 2}) == 7.5
    assert Matrix.get(m, {2, 2}) == 11
    assert Matrix.get(m, {3, 0}) == 13.5
    assert Matrix.get(m, {3, 2}) == 15.5
  end

  test "a 2x2 matrix ought to be representable" do
    m = Matrix.new([[-3, 5], [1, -2]])

    assert Matrix.get(m, {0, 0}) == -3
    assert Matrix.get(m, {0, 1}) == 5
    assert Matrix.get(m, {1, 0}) == 1
    assert Matrix.get(m, {1, 1}) == -2
  end

  test "a 3x3 matrix ought to be representable" do
    m = Matrix.new([[-3, 5, 0], [1, -2, -7], [0, 1, 1]])

    assert Matrix.get(m, {0, 0}) == -3
    assert Matrix.get(m, {1, 1}) == -2
    assert Matrix.get(m, {2, 2}) == 1
  end

  test "matrix equality with identical matrices" do
    m1 =
      Matrix.new([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 8, 7, 6],
        [5, 4, 3, 2]
      ])

    m2 =
      Matrix.new([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 8, 7, 6],
        [5, 4, 3, 2]
      ])

    assert Matrix.equal?(m1, m2)
  end

  test "matrix equality with different matrices" do
    m1 =
      Matrix.new([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 8, 7, 6],
        [5, 4, 3, 2]
      ])

    m2 =
      Matrix.new([
        [2, 3, 4, 5],
        [6, 7, 8, 9],
        [8, 7, 6, 5],
        [4, 3, 2, 1]
      ])

    refute Matrix.equal?(m1, m2)
  end

  test "multiplying two matrices" do
    m1 =
      Matrix.new([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 8, 7, 6],
        [5, 4, 3, 2]
      ])

    m2 =
      Matrix.new([
        [-2, 1, 2, 3],
        [3, 2, 1, -1],
        [4, 3, 6, 5],
        [1, 2, 7, 8]
      ])

    assert Matrix.multiply(m1, m2) ==
             Matrix.new([
               [20, 22, 50, 48],
               [44, 54, 114, 108],
               [40, 58, 110, 102],
               [16, 26, 46, 42]
             ])
  end

  test "a matrix multiplied by a tuple" do
    m = Matrix.new([[1, 2, 3, 4], [2, 4, 4, 2], [8, 6, 4, 1], [0, 0, 0, 1]])

    t = Tuple.tuple(1, 2, 3, 1)
    assert Matrix.multiply(m, t) == Tuple.tuple(18, 24, 33, 1)
  end
end
