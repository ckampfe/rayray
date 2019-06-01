defmodule Rayray.Canvas do
  alias Rayray.Tuple

  def canvas(w, h) do
    black = Tuple.color(0, 0, 0)

    Enum.reduce(0..(w - 1), %{}, fn x, acc ->
      Map.put(
        acc,
        x,
        Enum.reduce(0..(h - 1), acc, fn y, acc2 ->
          Map.put(acc2, y, black)
        end)
      )
    end)
  end

  def width(c) do
    Enum.count(c)
  end

  def height(c) do
    c
    |> Enum.take(1)
    |> List.first()
    |> (fn {_k, v} -> Enum.count(v) end).()
  end

  def write_pixel(canvas, x, y, pixel) do
    Kernel.put_in(canvas, [x, y], pixel)
  end

  def pixel_at(canvas, x, y) do
    %{^x => %{^y => color}} = canvas
    color
  end

  def canvas_to_ppm(canvas) do
    width = width(canvas)
    height = height(canvas)

    chunk_fun = fn item, acc ->
      item_plus_acc =
        if acc == "" do
          item
        else
          acc <> " " <> item
        end

      if String.length(item_plus_acc) >= 70 do
        {:cont, acc <> "\n", item}
      else
        {:cont, item_plus_acc}
      end
    end

    after_fun = fn
      "" ->
        {:cont, ""}

      acc ->
        {:cont, acc <> "\n", ""}
    end

    x_indexes = 0..(width - 1)
    y_indexes = 0..(height - 1)

    pixels =
      y_indexes
      |> Flow.from_enumerable()
      |> Flow.map(fn y ->
        pixel_row =
          Enum.flat_map(x_indexes, fn x ->
            %{^x => %{^y => %{red: red, green: green, blue: blue}}} = canvas

            r = red |> clamp() |> scale()
            g = green |> clamp() |> scale()
            b = blue |> clamp() |> scale()

            ["#{r}", "#{g}", "#{b}"]
          end)

        Enum.chunk_while(pixel_row, "", chunk_fun, after_fun)
      end)
      |> Enum.to_list()

    """
    P3
    #{width} #{height}
    255
    #{pixels}
    """
  end

  defp clamp(color_channel) when color_channel > 1 do
    1
  end

  defp clamp(color_channel) when color_channel < 0 do
    0
  end

  defp clamp(color_channel), do: color_channel

  defp scale(color_channel) do
    (color_channel * 255) |> ceil()
  end
end
