defmodule Rayray.CanvasTest do
  use ExUnit.Case, async: true
  alias Rayray.Canvas
  alias Rayray.Tuple

  test "creating a canvas" do
    c = Canvas.canvas(10, 20)
    assert Canvas.width(c) == 10
    assert Canvas.height(c) == 20
  end

  test "writing pixels to a canvas" do
    c = Canvas.canvas(10, 20)
    red = Tuple.color(1, 0, 0)
    c = Canvas.write_pixel(c, 2, 3, red)
    assert Canvas.pixel_at(c, 2, 3) == red
  end

  test "constructing the ppm header" do
    c = Canvas.canvas(5, 3)
    ppm = Canvas.canvas_to_ppm(c)

    assert (ppm |> String.split("\n") |> Enum.take(3) |> Enum.join("\n")) <> "\n" == """
           P3
           5 3
           255
           """
  end

  test "constructing the ppm pixel data" do
    c = Canvas.canvas(5, 3)
    c1 = Tuple.color(1.5, 0, 0)
    c2 = Tuple.color(0, 0.5, 0)
    c3 = Tuple.color(-0.5, 0, 1)

    c = Canvas.write_pixel(c, 0, 0, c1)
    c = Canvas.write_pixel(c, 2, 1, c2)
    c = Canvas.write_pixel(c, 4, 2, c3)
    ppm = Canvas.canvas_to_ppm(c)

    data_lines =
      ppm
      |> String.split("\n")
      |> Enum.drop(3)
      |> Enum.take(3)
      |> Enum.join("\n")

    assert data_lines <> "\n" == """
           255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
           0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
           0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
           """
  end

  test "splitting long lines in ppm files" do
    c = Canvas.canvas(10, 2)

    c =
      Enum.reduce(c, %{}, fn {x, row}, acc ->
        Map.put(
          acc,
          x,
          Enum.reduce(row, acc, fn {y, _col}, acc2 ->
            Map.put(acc2, y, Tuple.color(1, 0.8, 0.6))
          end)
        )
      end)

    ppm = Canvas.canvas_to_ppm(c)
    ppm = String.split(ppm, "\n") |> Enum.drop(3) |> Enum.take(4) |> Enum.join("\n")

    assert ppm <> "\n" == """
           255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
           153 255 204 153 255 204 153 255 204 153 255 204 153
           255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
           153 255 204 153 255 204 153 255 204 153 255 204 153
           """
  end

  test "ppm files are terminated by a newline character" do
    c = Canvas.canvas(5, 3)
    ppm = Canvas.canvas_to_ppm(c)
    assert String.last(ppm) == "\n"
  end
end
