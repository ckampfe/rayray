defmodule Rayray.LightsTest do
  use ExUnit.Case
  alias Rayray.Lights
  alias Rayray.Tuple

  test "A point light has a position and intensity" do
    intensity = Tuple.color(1, 1, 1)
    position = Tuple.point(0, 0, 0)
    light = Lights.point_light(position, intensity)
    assert light.position == position
    assert light.intensity == intensity
  end
end
