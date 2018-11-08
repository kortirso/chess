defmodule Chess.Move.FigureRoute do
  @moduledoc """
  Module for checking figures routes
  """

  defmacro __using__(_opts) do
    quote do
      alias Chess.{Figure}

      defp check_figure_route(%Figure{color: color, type: type}, route, [_move_from_x, move_from_y]) when type == "p" do
        unless pion_move(route, move_from_y, color) do
          raise "Pion can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route, _move_from) when type == "r" do
        unless linear_move(route) do
          raise "Rook can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route, _move_from) when type == "n" do
        unless knight_move(route) do
          raise "Knight can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route, _move_from) when type == "b" do
        unless diagonal_move(route) do
          raise "Bishop can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route, _move_from) when type == "q" do
        unless diagonal_move(route) || linear_move(route) do
          raise "Queen can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, [x_route, y_route], _move_from) when type == "k" do
        possible = [-1, 0, 1]
        unless x_route in possible && y_route in possible do
          raise "King can not move like this"
        end
      end

      defp pion_move([x_route, y_route], move_from_y, color) do
        color_koef = if color == "white", do: 1, else: -1
        abs(x_route) == 1 && y_route == 1 * color_koef || x_route == 0 && (y_route == 1 * color_koef || y_route == 2 * color_koef && move_from_y == start_line_for_pion(color))
      end

      defp start_line_for_pion(color) do
        if color == "white", do: "2", else: "7"
      end

      defp linear_move([x_route, y_route]) do
        x_route == 0 || y_route == 0
      end

      defp diagonal_move([x_route, y_route]) do
        abs(x_route) == abs(y_route)
      end

      defp knight_move([x_route, y_route]) do
        abs(x_route) == 2 && abs(y_route) == 1 || abs(x_route) == 1 && abs(y_route) == 2
      end
    end
  end
end
