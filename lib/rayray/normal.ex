defprotocol Rayray.LocalNormal do
  @doc "Calculates the normal on an object, at a given point"
  def local_normal_at(obj, point)
end

defmodule Rayray.Normal do
  alias Rayray.Matrix
  alias Rayray.Tuple
  alias Rayray.LocalNormal

  def normal_at(obj, point) do
    local_point = Matrix.multiply(Matrix.inverse(obj.transform), point)
    local_normal = LocalNormal.local_normal_at(obj, local_point)

    world_normal =
      obj.transform
      |> Matrix.inverse()
      |> Matrix.transpose()
      |> Matrix.multiply(local_normal)

    world_normal = %{world_normal | w: 0}

    Tuple.normalize(world_normal)
  end
end
