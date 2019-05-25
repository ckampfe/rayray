defmodule Rayray.Intersection do
  defstruct t: nil, object: nil

  def new(t, object) do
    %__MODULE__{t: t, object: object}
  end

  def aggregate(intersections) when is_list(intersections) do
    intersections
  end

  def hit(intersections) do
    intersections
    |> Enum.filter(fn i -> i.t >= 0 end)
    |> Enum.sort()
    |> List.first()
  end
end
