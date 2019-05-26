defmodule Rayray.RenderSphereShaded do
  alias Rayray.Canvas
  alias Rayray.Intersect
  alias Rayray.Intersection
  alias Rayray.Lights
  alias Rayray.Material
  # alias Rayray.Matrix
  alias Rayray.Normal
  alias Rayray.Ray
  alias Rayray.Sphere
  alias Rayray.Tuple

  def do_it(ray_origin \\ Tuple.point(0, 0, -5), wall_z \\ 10, wall_size \\ 7.0) do
    canvas_pixels = 100
    pixel_size = wall_size / canvas_pixels
    half = wall_size / 2

    canvas = Canvas.canvas(canvas_pixels, canvas_pixels)
    # color = Tuple.color(1, 0, 0)
    shape = Sphere.new()
    material = Material.new()
    material = %{material | color: Tuple.color(1, 0.2, 1)}
    shape = %{shape | material: material}
    # transform = Matrix.multiply(Matrix.shearing(1, 0, 0, 0, 0, 0), Matrix.scaling(0.5, 1, 1))
    # shape = %{shape | transform: transform}

    light_position = Tuple.point(-10, 10, -10)
    light_color = Tuple.color(1, 1, 1)
    light = Lights.point_light(light_position, light_color)

    ppm =
      Enum.reduce(0..(canvas_pixels - 1), canvas, fn y, cacc ->
        world_y = half - pixel_size * y

        Enum.reduce(0..(canvas_pixels - 1), cacc, fn x, cacc2 ->
          world_x = -half + pixel_size * x
          position = Tuple.point(world_x, world_y, wall_z)
          ray = Ray.new(ray_origin, Tuple.normalize(Tuple.subtract(position, ray_origin)))
          xs = Intersect.intersect(shape, ray)

          if Intersection.hit(xs) do
            hit = Intersection.hit(xs)
            point = Ray.position(ray, hit.t)
            normal = Normal.normal_at(hit.object, point)
            eye = Tuple.multiply(ray.direction, -1)
            color = Lights.lighting(hit.object.material, light, point, eye, normal)
            Canvas.write_pixel(cacc2, x, y, color)
          else
            cacc2
          end
        end)
      end)
      |> Canvas.canvas_to_ppm()

    File.write!("sphere.ppm", ppm)
  end
end
