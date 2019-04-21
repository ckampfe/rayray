defmodule Rayray.Clock do
  alias Rayray.Canvas
  alias Rayray.Tuple
  alias Rayray.Matrix

  def clock() do
    white = Tuple.color(255, 255, 255)
    canvas = Canvas.canvas(200, 200)

    middle = Matrix.translation(100, 100, 0)
    twelve = Matrix.translation(0, -75, 0) |> Matrix.multiply(Tuple.point(0, -1, 0))

    pi_seq = Stream.iterate(0, fn prev -> prev + :math.pi() / 6 end) |> Enum.take(12)

    numbers =
      Enum.map(pi_seq, fn radians ->
        middle
        |> Matrix.multiply(Matrix.rotation_z(radians))
        |> Matrix.multiply(twelve)
      end)

    c =
      Enum.reduce(numbers, canvas, fn number, canvas ->
        Canvas.write_pixel(canvas, trunc(number[:x]), trunc(number[:y]), white)
      end)

    out = Canvas.canvas_to_ppm(c)
    File.write("clock.ppm", out)
  end
end
