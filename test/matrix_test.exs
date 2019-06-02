defmodule Rayray.MatrixTest do
  use ExUnit.Case, async: true
  alias Rayray.Matrix
  alias Rayray.Tuple

  @epsilon 0.0001
  @pi_over_2 :math.pi() / 2

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

  test "testing an invertible matrix for invertibility" do
    m = Matrix.new([[6, 4, 4, 4], [5, 5, 7, 6], [4, -9, 3, -7], [9, 1, 7, -6]])
    assert Matrix.determinant(m) == -2120
    assert Matrix.invertible?(m)
  end

  test "testing a noninvertible matrix for invertibility" do
    m = Matrix.new([[-4, 2, -2, -3], [9, 6, 2, 6], [0, -5, 1, -5], [0, 0, 0, 0]])
    assert Matrix.determinant(m) == 0
    refute Matrix.invertible?(m)
  end

  test "calculating the inverse of a matrix" do
    m = Matrix.new([[-5, 2, 6, -8], [1, -5, 1, 8], [7, 7, -6, -7], [1, -3, 7, 4]])
    b = Matrix.inverse(m)
    assert Matrix.determinant(m) == 532
    assert Matrix.cofactor(m, 2, 3) == -160
    assert Matrix.get(b, {3, 2}) == -160 / 532
    assert Matrix.cofactor(m, 3, 2) == 105
    assert Matrix.get(b, {2, 3}) == 105 / 532

    assert Matrix.fuzzy_equal?(
             b,
             Matrix.new([
               [0.21805, 0.45113, 0.24060, -0.04511],
               [-0.80827, -1.45677, -0.44361, 0.52068],
               [-0.07895, -0.22368, -0.05263, 0.19737],
               [-0.52256, -0.81391, -0.30075, 0.30639]
             ]),
             @epsilon
           )
  end

  test "calculating the inverse of another matrix" do
    m = Matrix.new([[8, -5, 9, 2], [7, 5, 6, 1], [-6, 0, 9, 6], [-3, 0, -9, -4]])
    b = Matrix.inverse(m)

    assert Matrix.fuzzy_equal?(
             b,
             Matrix.new([
               [-0.15385, -0.15385, -0.28205, -0.53846],
               [-0.07692, 0.12308, 0.02564, 0.03077],
               [0.35897, 0.35897, 0.43590, 0.92308],
               [-0.69231, -0.69231, -0.76923, -1.92308]
             ]),
             @epsilon
           )
  end

  test "calculating the inverse of a third matrix" do
    m = Matrix.new([[9, 3, 0, 9], [-5, -2, -6, -3], [-4, 9, 6, 4], [-7, 6, 6, 2]])
    b = Matrix.inverse(m)

    assert Matrix.fuzzy_equal?(
             b,
             Matrix.new([
               [-0.04074, -0.07778, 0.14444, -0.22222],
               [-0.07778, 0.03333, 0.36667, -0.33333],
               [-0.02901, -0.14630, -0.10926, 0.12963],
               [0.17778, 0.06667, -0.26667, 0.33333]
             ]),
             @epsilon
           )
  end

  test "multiplying a product by its inverse" do
    a = Matrix.new([[3, -9, 7, 3], [3, -8, 2, -9], [-4, 4, 4, 1], [-6, 5, -1, 1]])
    b = Matrix.new([[8, 2, 2, 2], [3, -1, 7, 0], [7, 0, 5, 4], [6, -2, 0, 5]])

    c = Matrix.multiply(a, b)
    assert Matrix.fuzzy_equal?(Matrix.multiply(c, Matrix.inverse(b)), a, @epsilon)
  end

  test "multiplying by a translation matrix" do
    transform = Matrix.translation(5, -3, 2)
    p = Tuple.point(-3, 4, 5)

    assert Matrix.multiply(transform, p) == Tuple.point(2, 1, 7)
  end

  test "multiplying by the inverse of a translation matrix" do
    transform = Matrix.translation(5, -3, 2)
    inverse = Matrix.inverse(transform)
    p = Tuple.point(-3, 4, 5)

    assert Matrix.multiply(inverse, p) == Tuple.point(-8, 7, 3)
  end

  test "translation does not affect vectors" do
    transform = Matrix.translation(5, -3, 2)
    v = Tuple.vector(-3, 4, 5)

    assert Matrix.multiply(transform, v) == v
  end

  test "A scaling matrix applied to a point" do
    transform = Matrix.scaling(2, 3, 4)
    p = Tuple.point(-4, 6, 8)
    assert Matrix.multiply(transform, p) == Tuple.point(-8, 18, 32)
  end

  test "A scaling matrix applied to a vector" do
    transform = Matrix.scaling(2, 3, 4)
    v = Tuple.vector(-4, 6, 8)
    assert Matrix.multiply(transform, v) == Tuple.vector(-8, 18, 32)
  end

  test "Multiplying by the inverse of a scaling matrix" do
    transform = Matrix.scaling(2, 3, 4)
    inv = Matrix.inverse(transform)
    v = Tuple.vector(-4, 6, 8)
    assert Matrix.multiply(inv, v) == Tuple.vector(-2, 2, 2)
  end

  test "Reflection is scaling by a negative value" do
    transform = Matrix.scaling(-1, 1, 1)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(-2, 3, 4)
  end

  test "Rotating a point around the x axis" do
    p = Tuple.point(0.0, 1.0, 0.0)
    half_quarter = Matrix.rotation_x(:math.pi() / 4)
    full_quarter = Matrix.rotation_x(:math.pi() / 2)

    hqm = Matrix.multiply(half_quarter, p)
    t1 = Tuple.point(0.0, :math.sqrt(2) / 2, :math.sqrt(2) / 2)
    assert hqm.w - t1.w < @epsilon
    assert hqm.x - t1.x < @epsilon
    assert hqm.y - t1.y < @epsilon
    assert hqm.z - t1.z < @epsilon

    fqm = Matrix.multiply(full_quarter, p)
    t2 = Tuple.point(0.0, 0.0, 1.0)

    assert fqm.w - t2.w < @epsilon
    assert fqm.x - t2.x < @epsilon
    assert fqm.y - t2.y < @epsilon
    assert fqm.z - t2.z < @epsilon
  end

  test "The inverse of an x-rotation rotates in the opposite direction" do
    p = Tuple.point(0.0, 1.0, 0.0)
    half_quarter = Matrix.rotation_x(:math.pi() / 4)
    inv = Matrix.inverse(half_quarter)
    m = Matrix.multiply(inv, p)
    t = Tuple.point(0.0, :math.sqrt(2) / 2, -1 * :math.sqrt(2) / 2)

    assert m.w - t.w < @epsilon
    assert m.x - t.x < @epsilon
    assert m.y - t.y < @epsilon
    assert m.z - t.z < @epsilon
  end

  test "Rotating a point aorund the y axis" do
    p = Tuple.point(0, 0, 1)
    half_quarter = Matrix.rotation_y(:math.pi() / 4)
    full_quarter = Matrix.rotation_y(:math.pi() / 2)

    hqm = Matrix.multiply(half_quarter, p)
    p1 = Tuple.point(:math.sqrt(2) / 2, 0, :math.sqrt(2) / 2)
    assert hqm.w - p1.w < @epsilon
    assert hqm.x - p1.x < @epsilon
    assert hqm.y - p1.y < @epsilon
    assert hqm.z - p1.z < @epsilon

    fqm = Matrix.multiply(full_quarter, p)
    p2 = Tuple.point(1, 0, 0)
    assert fqm.w - p2.w < @epsilon
    assert fqm.x - p2.x < @epsilon
    assert fqm.y - p2.y < @epsilon
    assert fqm.z - p2.z < @epsilon
  end

  test "Rotating a point around the z axis" do
    p = Tuple.point(0, 1, 0)
    half_quarter = Matrix.rotation_z(:math.pi() / 4)
    full_quarter = Matrix.rotation_z(:math.pi() / 2)

    hqm = Matrix.multiply(half_quarter, p)
    p1 = Tuple.point(-1 * :math.sqrt(2) / 2, :math.sqrt(2) / 2, 0)
    assert hqm.w - p1.w < @epsilon
    assert hqm.x - p1.x < @epsilon
    assert hqm.y - p1.y < @epsilon
    assert hqm.z - p1.z < @epsilon

    fqm = Matrix.multiply(full_quarter, p)
    p2 = Tuple.point(-1, 0, 0)
    assert fqm.w - p2.w < @epsilon
    assert fqm.x - p2.x < @epsilon
    assert fqm.y - p2.y < @epsilon
    assert fqm.z - p2.z < @epsilon
  end

  test "A shearing transformation moves x in proportion to y" do
    transform = Matrix.shearing(1, 0, 0, 0, 0, 0)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(5, 3, 4)
  end

  test "A shearing transformation moves x in proportion to z" do
    transform = Matrix.shearing(0, 1, 0, 0, 0, 0)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(6, 3, 4)
  end

  test "A shearing transformation moves y in proportion to x" do
    transform = Matrix.shearing(0, 0, 1, 0, 0, 0)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(2, 5, 4)
  end

  test "A shearing transformation moves y in proportion to z" do
    transform = Matrix.shearing(0, 0, 0, 1, 0, 0)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(2, 7, 4)
  end

  test "A shearing transformation moves z in proportion to x" do
    transform = Matrix.shearing(0, 0, 0, 0, 1, 0)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(2, 3, 6)
  end

  test "A shearing transformation moves z in proportion to y" do
    transform = Matrix.shearing(0, 0, 0, 0, 0, 1)
    p = Tuple.point(2, 3, 4)
    assert Matrix.multiply(transform, p) == Tuple.point(2, 3, 7)
  end

  test "Individual transformations are applied in a sequence" do
    p = Tuple.point(1, 0, 1)
    a = Matrix.rotation_x(@pi_over_2)
    b = Matrix.scaling(5, 5, 5)
    c = Matrix.translation(10, 5, 7)

    # rotation first
    p2 = Matrix.multiply(a, p)
    assert Tuple.fuzzy_equal?(p2, Tuple.point(1, -1, 0), @epsilon)

    # scaling
    p3 = Matrix.multiply(b, p2)
    assert Tuple.fuzzy_equal?(p3, Tuple.point(5, -5, 0), @epsilon)

    # translation
    p4 = Matrix.multiply(c, p3)
    assert Tuple.fuzzy_equal?(p4, Tuple.point(15, 0, 7), @epsilon)
  end
end
