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

  test "multiplying a matrix by the identity matrix" do
    m =
      Matrix.new([
        [0, 1, 2, 4],
        [1, 2, 4, 8],
        [2, 4, 8, 16],
        [4, 8, 16, 32]
      ])

    assert Matrix.equal?(Matrix.multiply(m, Matrix.identity()), m)
  end

  test "multiplying the identity matrix by a tuple" do
    t = Tuple.tuple(1, 2, 3, 4)
    assert Matrix.multiply(Matrix.identity(), t) == t
  end

  test "transposing a matrix" do
    m =
      Matrix.new([
        [0, 9, 3, 0],
        [9, 8, 0, 8],
        [1, 8, 5, 3],
        [0, 0, 5, 8]
      ])

    transposed =
      Matrix.new([
        [0, 9, 1, 0],
        [9, 8, 8, 0],
        [3, 0, 5, 5],
        [0, 8, 3, 8]
      ])

    assert Matrix.equal?(Matrix.transpose(m), transposed)
  end

  test "transposing the identity matrix" do
    assert Matrix.equal?(Matrix.transpose(Matrix.identity()), Matrix.identity())
  end

  test "calculating the determinant of a 2x2 matrix" do
    m = Matrix.new([[1, 5], [-3, 2]])
    assert Matrix.determinant(m) == 17
  end

  test "a submatrix of a 3x3 matrix is a 2x2 matrix" do
    m = Matrix.new([[1, 5, 0], [-3, 2, 7], [0, 6, -3]])
    sub = Matrix.new([[-3, 2], [0, 6]])
    assert Matrix.equal?(Matrix.submatrix(m, 0, 2), sub)
  end

  test "a submatrix of a 4x4 matrix is a 3x3 matrix" do
    m =
      Matrix.new([
        [-6, 1, 1, 6],
        [-8, 5, 8, 6],
        [-1, 0, 8, 2],
        [-7, 1, -1, 1]
      ])

    sub = Matrix.submatrix(m, 2, 1)

    test_m = Matrix.new([[-6, 1, 6], [-8, 8, 6], [-7, -1, 1]])

    assert Matrix.equal?(sub, test_m)
  end

  test "calculating a minor of a 3x3 matrix" do
    m = Matrix.new([[3, 5, 0], [2, -1, -7], [6, -1, 5]])
    b = Matrix.submatrix(m, 1, 0)
    assert Matrix.determinant(b) == 25
    assert Matrix.minor(m, 1, 0) == 25
  end

  test "calculating a cofactor of a 3x3 matrix" do
    m = Matrix.new([[3, 5, 0], [2, -1, -7], [6, -1, 5]])

    assert Matrix.minor(m, 0, 0) == -12
    assert Matrix.cofactor(m, 0, 0) == -12
    assert Matrix.minor(m, 1, 0) == 25
    assert Matrix.cofactor(m, 1, 0) == -25
  end

  test "calculating the determinant of a 3x3 matrix" do
    m = Matrix.new([[1, 2, 6], [-5, 8, -4], [2, 6, 4]])
    assert Matrix.cofactor(m, 0, 0) == 56
    assert Matrix.cofactor(m, 0, 1) == 12
    assert Matrix.cofactor(m, 0, 2) == -46
    assert Matrix.determinant(m) == -196
  end

  test "calculating the determinant of a 4x4 matrix" do
    m = Matrix.new([[-2, -8, 3, 5], [-3, 1, 7, 3], [1, 2, -9, 6], [-6, 7, 7, -9]])
    assert Matrix.cofactor(m, 0, 0) == 690
    assert Matrix.cofactor(m, 0, 1) == 447
    assert Matrix.cofactor(m, 0, 2) == 210
    assert Matrix.cofactor(m, 0, 3) == 51
    assert Matrix.determinant(m) == -4071
  end
end
