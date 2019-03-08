defmodule Rayray.Matrix do
  alias Rayray.Tuple

  defstruct impl: []

  def new(rows) do
    %__MODULE__{impl: rows}
  end

  def get(%__MODULE__{impl: impl}, {row, col}) do
    impl
    |> Enum.at(row)
    |> Enum.at(col)
  end

  def equal?(m1, m2) do
    m1.impl == m2.impl
  end

  def multiply(%__MODULE__{} = m1, %__MODULE__{} = m2) do
    empty = [[], [], [], []]

    for row <- 0..3,
        col <- 0..3 do
      val =
        get(m1, {row, 0}) * get(m2, {0, col}) +
          get(m1, {row, 1}) * get(m2, {1, col}) +
          get(m1, {row, 2}) * get(m2, {2, col}) +
          get(m1, {row, 3}) * get(m2, {3, col})

      {row, col, val}
    end
    |> Enum.reduce(empty, fn {row, col, val}, acc ->
      List.update_at(acc, row, fn oldrow ->
        List.insert_at(oldrow, col, val)
      end)
    end)
    |> new()
  end

  def multiply(m, t) do
    new_t =
      Enum.reduce(m.impl, [], fn row, acc ->
        row_as_tuple = apply(Tuple, :tuple, row)
        dot_product = Tuple.dot(row_as_tuple, t)
        [dot_product | acc]
      end)
      |> Enum.reverse()

    apply(Tuple, :tuple, new_t)
  end
end
