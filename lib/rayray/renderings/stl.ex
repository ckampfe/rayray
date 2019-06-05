defmodule Rayray.Renderings.Stl do
  alias Rayray.Camera
  alias Rayray.Canvas
  alias Rayray.Lights
  alias Rayray.Material
  alias Rayray.Matrix
  alias Rayray.Plane
  alias Rayray.Transformations
  alias Rayray.Tuple
  alias Rayray.World

  def do_it() do
    floor = Plane.new()
    floor_material = Material.new()
    floor_material = %{floor_material | color: Tuple.color(1, 0.9, 0.9), specular: 0}
    floor = %{floor | material: floor_material}

    world = World.new()

    triangle_material = Material.new()

    triangle_material = %{
      triangle_material
      | color: Tuple.color(0.0196, 0.65, 0.874),
        diffuse: 0.7,
        specular: 0.3
    }

    mesh = Rayray.Xtl.parse("/Users/clark/Downloads/Moon_binary.stl")

    triangle_transform =
      Matrix.rotation_z(:math.pi() / 2)
      |> Matrix.multiply(Matrix.rotation_x(-1 * :math.pi() / 3))
      |> Matrix.multiply(Matrix.scaling(2, 2, 2))

    triangles =
      mesh.triangles
      |> Enum.map(fn triangle ->
        %{triangle | material: triangle_material, transform: triangle_transform}
      end)

    # triangles |> Enum.take(5) |> IO.inspect()

    # t = Rayray.Triangle.new(Tuple.point(1, 0, 1), Tuple.point(0, 1, 0), Tuple.point(1, 1, 0))
    # %{t | material: triangle_material}
    # triangles = [t]

    world = %{
      world
      | light: Lights.point_light(Tuple.point(-10, 10, -10), Tuple.color(1, 1, 1)),
        objects: triangles ++ [floor]
    }

    camera = Camera.new(600, 600, :math.pi() / 2)

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

    File.write!("mesh_400x400.ppm", ppm)
  end
end

defmodule Rayray.Xtl do
  alias Rayray.Triangle
  alias Rayray.Tuple

  def parse(file) do
    # parse_string(File.read!(file))
    {:ok, stl} =
      File.open(file, [:read, :raw], fn handle ->
        str = IO.binread(handle, :all)
        parse_string(str)
        # IO.binstream(handle, 2048) |> Enum.map(fn x -> String.length(x) end)
      end)

    stl
  end

  def parse_string(str) when is_binary(str) do
    {headers, rest} = parse_headers(str)
    triangles = parse_triangles(rest)
    Map.put(headers, :triangles, triangles)
  end

  def parse_headers(<<
        _header::bytes-size(80),
        number_of_triangles::unsigned-little-integer-size(32),
        rest::binary()
      >>) do
    {%{number_of_triangles: number_of_triangles}, rest}
  end

  def parse_triangles(rest) do
    do_parse_triangles(rest, [])
  end

  def do_parse_triangles(
        <<
          _nx::little-float-size(32),
          _ny::little-float-size(32),
          _nz::little-float-size(32),
          v1x::little-float-size(32),
          v1y::little-float-size(32),
          v1z::little-float-size(32),
          v2x::little-float-size(32),
          v2y::little-float-size(32),
          v2z::little-float-size(32),
          v3x::little-float-size(32),
          v3y::little-float-size(32),
          v3z::little-float-size(32),
          _abc::bytes-size(2),
          rest::binary()
        >>,
        triangles
      ) do
    do_parse_triangles(
      rest,
      [
        Triangle.new(
          Tuple.point(v1x, v1y, v1z),
          Tuple.point(v2x, v2y, v2z),
          Tuple.point(v3x, v3y, v3z)
        )
        | triangles
        # %{
        #   normal: %{x: nx, y: ny, z: nz},
        #   v1: %{x: v1x, y: v1y, z: v1z},
        #   v2: %{x: v2x, y: v2y, z: v2z},
        #   v3: %{x: v3x, y: v3y, z: v3z}
        # }
      ]
    )
  end

  def do_parse_triangles(_rest, triangles) do
    triangles
  end
end
