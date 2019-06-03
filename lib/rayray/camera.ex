defmodule Rayray.Camera do
  alias Rayray.Canvas
  alias Rayray.Matrix
  alias Rayray.Ray
  alias Rayray.Tuple
  alias Rayray.World

  defstruct hsize: 0,
            vsize: 0,
            field_of_view: 0,
            transform: Matrix.identity(),
            half_width: 0,
            half_height: 0,
            pixel_size: 0

  def new(hsize, vsize, field_of_view) do
    half_view = :math.tan(field_of_view / 2)
    aspect = hsize / vsize

    {half_width, half_height} =
      if aspect >= 1 do
        {half_view, half_view / aspect}
      else
        {half_view * aspect, half_view}
      end

    pixel_size = half_width * 2 / hsize

    %__MODULE__{
      hsize: hsize,
      vsize: vsize,
      field_of_view: field_of_view,
      half_width: half_width,
      half_height: half_height,
      pixel_size: pixel_size
    }
  end

  def ray_for_pixel(camera, px, py) do
    x_offset = (px + 0.5) * camera.pixel_size
    y_offset = (py + 0.5) * camera.pixel_size
    world_x = camera.half_width - x_offset
    world_y = camera.half_height - y_offset

    pixel = Matrix.multiply(Matrix.inverse(camera.transform), Tuple.point(world_x, world_y, -1))
    origin = Matrix.multiply(Matrix.inverse(camera.transform), Tuple.point(0, 0, 0))
    direction = Tuple.normalize(Tuple.subtract(pixel, origin))

    Ray.new(origin, direction)
  end

  def render(camera, world) do
    image = Canvas.canvas(camera.hsize, camera.vsize)

    coords =
      for y <- 0..(camera.vsize - 1), x <- 0..(camera.hsize - 1) do
        {x, y}
      end

    coords
    |> Flow.from_enumerable()
    |> Flow.map(fn {x, y} ->
      ray = ray_for_pixel(camera, x, y)
      {x, y, World.color_at(world, ray)}
    end)
    |> Enum.reduce(
      image,
      fn {x, y, color}, c ->
        Canvas.write_pixel(c, x, y, color)
      end
    )
  end
end
