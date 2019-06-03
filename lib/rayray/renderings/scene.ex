defmodule Rayray.Renderings.Scene do
  alias Rayray.Camera
  alias Rayray.Canvas
  alias Rayray.Lights
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Sphere
  alias Rayray.Transformations
  alias Rayray.Tuple
  alias Rayray.World

  def do_it() do
    # floor
    floor = Sphere.new()
    material = Material.new()
    material = %{material | color: Tuple.color(1, 0.9, 0.9), specular: 0}
    floor = %{floor | transform: Matrix.scaling(10, 0.01, 10), material: material}

    # left wall
    left_wall = Sphere.new()

    left_wall_transform =
      Matrix.translation(0, 0, 5)
      |> Matrix.multiply(Matrix.rotation_y(-1 * :math.pi() / 4))
      |> Matrix.multiply(Matrix.rotation_z(:math.pi() / 2))
      |> Matrix.multiply(Matrix.scaling(10, 0.01, 10))

    left_wall_material = floor.material
    left_wall = %{left_wall | transform: left_wall_transform, material: left_wall_material}

    # right wall
    right_wall = Sphere.new()

    right_wall_transform =
      Matrix.translation(0, 0, 5)
      |> Matrix.multiply(Matrix.rotation_y(:math.pi() / 4))
      |> Matrix.multiply(Matrix.rotation_z(:math.pi() / 2))
      |> Matrix.multiply(Matrix.scaling(10, 0.01, 10))

    right_wall_material = floor.material
    right_wall = %{right_wall | transform: right_wall_transform, material: right_wall_material}

    # middle
    middle = Sphere.new()
    middle_material = Material.new()

    middle_material = %{
      middle_material
      | color: Tuple.color(0.1, 1, 0.5),
        diffuse: 0.7,
        specular: 0.3
    }

    middle = %{middle | transform: Matrix.translation(-0.5, 1, 0.5), material: middle_material}

    # right
    right = Sphere.new()
    right_material = Material.new()

    right_material = %{
      right_material
      | color: Tuple.color(0.5, 1, 0.1),
        diffuse: 0.7,
        specular: 0.3
    }

    right = %{
      right
      | transform:
          Matrix.multiply(Matrix.translation(1.5, 0.5, -0.5), Matrix.scaling(0.5, 0.5, 0.5)),
        material: right_material
    }

    # left
    left = Sphere.new()
    left_material = Material.new()

    left_material = %{
      left_material
      | color: Tuple.color(1, 0.8, 0.1),
        diffuse: 0.7,
        specular: 0.3
    }

    left = %{
      left
      | transform:
          Matrix.multiply(Matrix.translation(-1.5, 0.33, -0.75), Matrix.scaling(0.33, 0.33, 0.33)),
        material: left_material
    }

    world = World.new()

    world = %{
      world
      | light: Lights.point_light(Tuple.point(-10, 10, -10), Tuple.color(1, 1, 1)),
        objects: [floor, left_wall, right_wall, middle, right, left]
    }

    camera = Camera.new(1000, 500, :math.pi() / 3)

    camera = %{
      camera
      | transform:
          Transformations.view_transform(
            Tuple.point(0, 1.5, -5),
            Tuple.point(0, 1, 0),
            Tuple.vector(0, 1, 0)
          )
    }

    IO.puts("started rendering")

    canvas = Camera.render(camera, world)

    IO.puts("done rendering")

    ppm = Canvas.canvas_to_ppm(canvas)

    IO.puts("Done ppm")

    File.write!("scene_shadowed_big.ppm", ppm)
  end
end
