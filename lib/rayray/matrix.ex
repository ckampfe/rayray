defmodule Rayray.Matrix do
  alias Rayray.Tuple

  defstruct impl: []

  def new(rows) do
    %__MODULE__{impl: rows}
  end

  def identity() do
    %__MODULE__{impl: [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]}
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

  def transpose(%__MODULE__{impl: rows}) do
    Enum.map(0..3, fn i ->
      Enum.map(rows, fn row ->
        Enum.at(row, i)
      end)
    end)
    |> new()
  end

  def determinant(%__MODULE__{impl: [[a, b], [c, d]]}) do
    a * d - b * c
  end

  def determinant(%__MODULE__{impl: [row | _rest]} = m) do
    row
    |> Enum.with_index()
    |> Enum.reduce(0, fn {el, i}, acc ->
      el * cofactor(m, 0, i) + acc
    end)
  end

  def submatrix(%__MODULE__{impl: rows}, row, column) do
    rows
    |> List.delete_at(row)
    |> Enum.map(fn r ->
      List.delete_at(r, column)
    end)
    |> new()
  end

  def minor(%__MODULE__{} = m, row, column) do
    m
    |> submatrix(row, column)
    |> determinant()
  end

  def cofactor(m, row, column) do
    minor = minor(m, row, column)

    if rem(row + column, 2) == 0 do
      minor
    else
      -1 * minor
    end
  end

  def invertible?(m) do
    determinant(m) != 0
  end
end
