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

  def fuzzy_equal?(%__MODULE__{impl: rows1}, %__MODULE__{} = m2, epsilon) do
    rows1
    |> Enum.with_index()
    |> Enum.reduce_while(true, fn
      {_row, _i}, false ->
        {:halt, false}

      {row, i}, true ->
        row_res =
          row
          |> Enum.with_index()
          |> Enum.reduce_while(true, fn
            {_el, _j}, false ->
              {:halt, false}

            {el, j}, true ->
              if el - get(m2, {i, j}) < epsilon do
                {:cont, true}
              else
                {:halt, false}
              end
          end)

        if row_res do
          {:cont, true}
        else
          {:halt, false}
        end
    end)
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

  def multiply(%__MODULE__{} = m, t) do
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

  def inverse(%__MODULE__{impl: rows} = m) do
    cofactor_matrix =
      rows
      |> Enum.with_index()
      |> Enum.map(fn {row, i} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {_el, j} ->
          cofactor(m, i, j)
        end)
      end)
      |> new()

    transposed_cofactor_matrix = transpose(cofactor_matrix)

    original_determinant = determinant(m)

    Enum.map(transposed_cofactor_matrix.impl, fn row ->
      Enum.map(row, fn el ->
        el / original_determinant
      end)
    end)
    |> new()
  end

  def translation(x, y, z) do
    identity().impl
    |> List.update_at(0, fn old ->
      List.update_at(old, 3, fn _ -> x end)
    end)
    |> List.update_at(1, fn old ->
      List.update_at(old, 3, fn _ -> y end)
    end)
    |> List.update_at(2, fn old ->
      List.update_at(old, 3, fn _ -> z end)
    end)
    |> new()
  end

  def scaling(x, y, z) do
    identity().impl
    |> List.update_at(0, fn old ->
      List.update_at(old, 0, fn _ -> x end)
    end)
    |> List.update_at(1, fn old ->
      List.update_at(old, 1, fn _ -> y end)
    end)
    |> List.update_at(2, fn old ->
      List.update_at(old, 2, fn _ -> z end)
    end)
    |> new()
  end

  def rotation_x(r) do
    new([
      [1, 0, 0, 0],
      [0, :math.cos(r), -1 * :math.sin(r), 0],
      [0, :math.sin(r), :math.cos(r), 0],
      [0, 0, 0, 1]
    ])
  end

  def rotation_y(r) do
    new([
      [:math.cos(r), 0, :math.sin(r), 0],
      [0, 1, 0, 0],
      [-1 * :math.sin(r), 0, :math.cos(r), 0],
      [0, 0, 0, 1]
    ])
  end

  def rotation_z(r) do
    new([
      [:math.cos(r), -1 * :math.sin(r), 0, 0],
      [:math.sin(r), :math.cos(r), 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    ])
  end

  def shearing(xy, xz, yx, yz, zx, zy) do
    new([
      [1, xy, xz, 0],
      [yx, 1, yz, 0],
      [zx, zy, 1, 0],
      [0, 0, 0, 1]
    ])
  end
end
