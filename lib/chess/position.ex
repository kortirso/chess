defmodule Chess.Position do
  @moduledoc """
  Position module
  """

  @x_fields ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_fields [8, 7, 6, 5, 4, 3, 2, 1]

  alias Chess.{Figure}

  @doc """
  Start position on the board in FEN-notation
  """
  def new() do
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  end

  @doc """
  Calculate FEN-notation for current board
  """
  def new(squares, _current_fen) do
    Enum.map(@y_fields, fn y ->
      check_line(@x_fields, squares, y, "", 0)
    end)
    |> Enum.join("/")
  end

  defp check_line(_fields, _squares, _y_line, _acc, spaces) when spaces == 8 do
    "8"
  end

  defp check_line(fields, _squares, _y_line, acc, _spaces) when fields == [] do
    acc
  end

  defp check_line([head | tail], squares, y_line, acc, spaces) do
    result = check_figure(squares[:"#{head}#{y_line}"])
    cond do
      result == 1 && tail == [] ->
        acc <> "#{spaces + 1}"
      result == 1 ->
        check_line(tail, squares, y_line, acc, spaces + 1)
      spaces != 0 ->
        check_line(tail, squares, y_line, acc <> "#{spaces}#{result}", 0)
      true ->
        check_line(tail, squares, y_line, acc <> result, 0)
    end
  end  

  defp check_figure(figure) when figure == nil do
    1
  end

  defp check_figure(%Figure{color: color, type: type}) do
    case color do
      "white" ->
        String.first(type)
        |> String.capitalize
      "black" -> String.first(type)
    end
  end
end
