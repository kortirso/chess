defmodule Chess.Move do
  @moduledoc """
  Move module
  """

  @x_fields ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_fields ["1", "2", "3", "4", "5", "6", "7", "8"]

  alias Chess.{Figure}

  @doc """
  Makes new move
  """
  def new(squares, move) do
    try do
      [move_from, move_to] = parse_move(move)

      figure = find_figure(squares[:"#{move_from}"])

      check_route(figure, move_from, move_to)

      # check_route_for_figures
      # check_destination_point_for_figure(squares[move_to])

      {:ok, squares}
    rescue
      error -> {:error, error}
    end
  end

  defp parse_move(move) do
    String.split(move, "-")
  end

  defp find_figure(figure) when figure == nil do
    raise "Square does not have figure for move"
  end

  defp find_figure(figure) do
    figure
  end

  defp check_route(figure, move_from, move_to) do
    differ = difference(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))
    check_figure_route(figure, differ)
  end

  defp difference([move_from_x, move_from_y], [move_to_x, move_to_y]) do
    [
      Enum.find_index(@x_fields, fn x -> x == move_to_x end) - Enum.find_index(@x_fields, fn x -> x == move_from_x end),
      Enum.find_index(@y_fields, fn y -> y == move_to_y end) - Enum.find_index(@y_fields, fn y -> y == move_from_y end)
    ]
  end

  defp check_figure_route(%Figure{color: color, type: type}, [x_differ, y_differ]) when type == "p" and color == "white" do
    if x_differ > 0 || y_differ < 0 || y_differ > 2 do
      raise "Pion can not move like this"
    end
  end

  defp check_figure_route(%Figure{color: color, type: type}, [x_differ, y_differ]) when type == "p" and color == "black" do
    if x_differ > 0 || y_differ > 0 || y_differ < -2 do
      raise "Pion can not move like this"
    end
  end

  defp check_figure_route(%Figure{type: type}, [x_differ, y_differ]) when type == "r" do
    if x_differ != 0 && y_differ != 0 do
      raise "Rook can not move like this"
    end
  end

  defp check_figure_route(%Figure{type: type}, [x_differ, y_differ]) when type == "n" do
    if abs(x_differ) == 2 && abs(y_differ) != 1 || abs(x_differ) == 1 && abs(y_differ) != 2 do
      raise "Knight can not move like this"
    end
  end

  defp check_figure_route(%Figure{type: type}, [x_differ, y_differ]) when type == "b" do
    if abs(x_differ) != abs(y_differ) do
      raise "Bishop can not move like this"
    end
  end

  defp check_figure_route(%Figure{type: type}, [x_differ, y_differ]) when type == "q" do
    if x_differ != 0 && y_differ != 0 || abs(x_differ) != abs(y_differ) do
      raise "Queen can not move like this"
    end
  end

  defp check_figure_route(%Figure{type: type}, [x_differ, y_differ]) when type == "k" do
    if x_differ != 0 && y_differ != 0 || abs(x_differ) != abs(y_differ) do
      raise "King can not move like this"
    end
  end
end
