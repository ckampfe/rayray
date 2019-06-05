defmodule Rayray.Renderings.Cube do
  alias Rayray.Camera
  alias Rayray.Canvas
  alias Rayray.Lights
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Plane
  alias Rayray.Cube
  alias Rayray.Transformations
  alias Rayray.Tuple
  alias Rayray.World

  def do_it() do
    floor = Plane.new()
    floor_material = Material.new()
    floor_material = %{floor_material | color: Tuple.color(1, 0.9, 0.9), specular: 0}
    floor = %{floor | material: floor_material}

    middle = Cube.new()
    middle_material = Material.new()

    middle_material = %{
      middle_material
      | color: Tuple.color(0.1, 1, 0.5),
        diffuse: 0.7,
        specular: 0.3
    }

    middle = %{middle | transform: Matrix.translation(-0.5, 1, 0.5), material: middle_material}

    # right
    right = Cube.new()
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
    left = Cube.new()
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
        objects: [floor, middle, right, left]
    }

    camera = Camera.new(1200, 1200, :math.pi() / 3)

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

    File.write!("cube_1200x1200.ppm", ppm)
  end
end
