defmodule Rayray.Tuple do
  def point(x, y, z) do
    tuple(x, y, z, 1.0)
  end

  def vector(x, y, z) do
    tuple(x, y, z, 0.0)
  end

  def color(r, g, b) do
    %{red: r, green: g, blue: b}
  end

  def tuple(x, y, z, w) do
    %{x: x, y: y, z: z, w: w}
  end

  def add(%{red: r1, green: g1, blue: b1}, %{red: r2, green: g2, blue: b2}) do
    %{red: r1 + r2, green: g1 + g2, blue: b1 + b2}
  end

  def add(t1, t2) do
    %{x: t1[:x] + t2[:x], y: t1[:y] + t2[:y], z: t1[:z] + t2[:z], w: t1[:w] + t2[:w]}
  end

  def subtract(%{red: r1, green: g1, blue: b1}, %{red: r2, green: g2, blue: b2}) do
    %{red: r1 - r2, green: g1 - g2, blue: b1 - b2}
  end

  def subtract(t1, t2) do
    %{x: t1[:x] - t2[:x], y: t1[:y] - t2[:y], z: t1[:z] - t2[:z], w: t1[:w] - t2[:w]}
  end

  def negate(%{x: x, y: y, z: z, w: w}) do
    %{x: -x, y: -y, z: -z, w: -w}
  end

  def multiply(%{red: r1, green: g1, blue: b1}, %{red: r2, green: g2, blue: b2}) do
    %{red: r1 * r2, green: g1 * g2, blue: b1 * b2}
  end

  def multiply(%{red: r1, green: g1, blue: b1}, s) do
    %{red: r1 * s, green: g1 * s, blue: b1 * s}
  end

  def multiply(%{x: x, y: y, z: z, w: w}, s) do
    %{x: x * s, y: y * s, z: z * s, w: w * s}
  end

  def divide(%{x: x, y: y, z: z, w: w}, s) do
    %{x: x / s, y: y / s, z: z / s, w: w / s}
  end

  def magnitude(%{x: x, y: y, z: z, w: w}) do
    :math.sqrt(x * x + y * y + z * z + w * w)
  end

  def normalize(%{x: x, y: y, z: z, w: w} = v) do
    tuple(
      x / magnitude(v),
      y / magnitude(v),
      z / magnitude(v),
      w / magnitude(v)
    )
  end

  def dot(a, b) do
    a[:x] * b[:x] + a[:y] * b[:y] + a[:z] * b[:z] + a[:w] * b[:w]
  end

  def cross(a, b) do
    vector(
      a[:y] * b[:z] - a[:z] * b[:y],
      a[:z] * b[:x] - a[:x] * b[:z],
      a[:x] * b[:y] - a[:y] * b[:x]
    )
  end
end
