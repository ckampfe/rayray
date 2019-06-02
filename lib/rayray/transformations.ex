defmodule Rayray.Transformations do
  alias Rayray.Matrix
  alias Rayray.Tuple

  def view_transform(from, to, up) do
    forward = Tuple.subtract(to, from) |> Tuple.normalize()
    left = Tuple.cross(forward, Tuple.normalize(up))
    true_up = Tuple.cross(left, forward)

    orientation =
      Matrix.new([
        [left.x, left.y, left.z, 0],
        [true_up.x, true_up.y, true_up.z, 0],
        [-forward.x, -forward.y, -forward.z, 0],
        [0, 0, 0, 1]
      ])

    translation = Matrix.translation(-from.x, -from.y, -from.z)
    Matrix.multiply(orientation, translation)
  end
end
