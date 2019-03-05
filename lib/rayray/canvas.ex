defmodule Rayray.Canvas do
  alias Rayray.Tuple

  def canvas(w, h) do
    black = Tuple.color(0, 0, 0)

    Enum.map(0..(h - 1), fn _i ->
      Enum.map(0..(w - 1), fn _j ->
        black
      end)
    end)
  end

  def width(c) do
    Enum.count(List.first(c))
  end

  def height(c) do
    Enum.count(c)
  end

  def write_pixel(canvas, x, y, pixel) do
    List.update_at(canvas, y, fn column ->
      List.update_at(column, x, fn _row -> pixel end)
    end)
  end

  def pixel_at(canvas, x, y) do
    canvas
    |> Enum.at(y)
    |> Enum.at(x)
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

    pixels =
      canvas
      |> Enum.map(fn row ->
        pixel_row =
          Enum.flat_map(row, fn color ->
            r = color[:red] |> clamp() |> scale()
            g = color[:green] |> clamp() |> scale()
            b = color[:blue] |> clamp() |> scale()

            ["#{r}", "#{g}", "#{b}"]
          end)

        Enum.chunk_while(pixel_row, "", chunk_fun, after_fun)
      end)

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
