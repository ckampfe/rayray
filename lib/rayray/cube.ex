defmodule Rayray.Cube do
  alias Rayray.Material
  alias Rayray.Matrix

  defstruct transform: Matrix.identity(),
            material: Material.new()

  def new() do
    %__MODULE__{}
  end

  def check_axis(origin, direction) do
    tmin_numerator = -1 - origin
    tmax_numerator = 1 - origin

    {tmin, tmax} =
      if :erlang.abs(direction) >= 0.00001 do
        {
          tmin_numerator / direction,
          tmax_numerator / direction
        }
      else
        {
          # this whole thing is a hack because Erlang
          # doens't have infinity
          case tmin_numerator do
            0 ->
              0.0

            v when v < 0 ->
              :negative_infinity

            _ ->
              :infinity
          end,
          case tmax_numerator do
            0 ->
              0.0

            v when v < 0 ->
              :negative_infinity

            _ ->
              :infinity
          end
        }
      end

    # same here
    case {tmin, tmax} do
      {tmin, tmax} when tmin == :infinity and tmax == :negative_infinity ->
        {:negative_infinity, :infinity}

      {tmin, tmax} when tmin == :negative_infinity and tmax == :infinity ->
        {tmin, tmax}

      {tmin, tmax} when is_float(tmin) and is_float(tmax) and tmin > tmax ->
        {tmax, tmin}

      {tmin, tmax} ->
        {tmin, tmax}
    end
  end
end

defimpl Rayray.LocalIntersect, for: Rayray.Cube do
  alias Rayray.Cube
  alias Rayray.Intersection

  def local_intersect(cube, ray) do
    {xtmin, xtmax} = Cube.check_axis(ray.origin.x, ray.direction.x)
    {ytmin, ytmax} = Cube.check_axis(ray.origin.y, ray.direction.y)
    {ztmin, ztmax} = Cube.check_axis(ray.origin.z, ray.direction.z)

    # we should be using Enum.max/1,
    # but we have to account for infinity
    [tmin | _] =
      Enum.sort_by(
        [xtmin, ytmin, ztmin],
        fn v ->
          v
        end,
        fn
          :infinity, _b ->
            false

          :negative_infinity, _b ->
            true

          _a, :infinity ->
            true

          _a, :negative_infinity ->
            false

          a, b ->
            a <= b
        end
      )
      |> Enum.reverse()

    # we should be using Enum.min/1,
    # but we have to account for infinity
    [tmax | _] =
      Enum.sort_by(
        [xtmax, ytmax, ztmax],
        fn v ->
          v
        end,
        fn
          :infinity, _b ->
            false

          :negative_infinity, _b ->
            true

          _a, :infinity ->
            true

          _a, :negative_infinity ->
            false

          a, b ->
            a <= b
        end
      )

    # return [] if tmin > tmax
    # special cased for negative/positive infinity
    case {tmin, tmax} do
      {:negative_infinity, :negative_infinity} ->
        [Intersection.new(tmin, cube), Intersection.new(tmax, cube)]

      {:infinity, :infinity} ->
        [Intersection.new(tmin, cube), Intersection.new(tmax, cube)]

      {:infinity, _tmax} ->
        []

      {_tmin, :negative_infinity} ->
        []

      {tmin, tmax} when tmin > tmax ->
        []

      _ ->
        [Intersection.new(tmin, cube), Intersection.new(tmax, cube)]
    end
  end
end

defimpl Rayray.LocalNormal, for: Rayray.Cube do
  alias Rayray.Tuple

  def local_normal_at(_cube, point) do
    maxc = Enum.max([:erlang.abs(point.x), :erlang.abs(point.y), :erlang.abs(point.z)])

    cond do
      maxc == :erlang.abs(point.x) ->
        Tuple.vector(point.x, 0, 0)

      maxc == :erlang.abs(point.y) ->
        Tuple.vector(0, point.y, 0)

      maxc == :erlang.abs(point.z) ->
        Tuple.vector(0, 0, point.z)
    end
  end
end
