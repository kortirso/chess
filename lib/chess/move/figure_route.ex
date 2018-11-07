defmodule Chess.Move.FigureRoute do
  @moduledoc """
  Module for checking figures routes
  """
  defmacro __using__(_opts) do
    quote do
      alias Chess.{Figure}

      defp check_figure_route(%Figure{color: color, type: type}, [x_route, y_route]) when type == "p" and color == "white" do
        if x_route > 0 || y_route < 0 || y_route > 2 do
          raise "Pion can not move like this"
        end
      end

      defp check_figure_route(%Figure{color: color, type: type}, [x_route, y_route]) when type == "p" and color == "black" do
        if x_route > 0 || y_route > 0 || y_route < -2 do
          raise "Pion can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route) when type == "r" do
        if not_linear_move(route) do
          raise "Rook can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, [x_route, y_route]) when type == "n" do
        if abs(x_route) == 2 && abs(y_route) != 1 || abs(x_route) == 1 && abs(y_route) != 2 do
          raise "Knight can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route) when type == "b" do
        if not_diagonal_move(route) do
          raise "Bishop can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, route) when type == "q" do
        if not_diagonal_move(route) && not_linear_move(route) do
          raise "Queen can not move like this"
        end
      end

      defp check_figure_route(%Figure{type: type}, [x_route, y_route]) when type == "k" do
        if abs(x_route) != 1 && abs(y_route) != 1 do
          raise "King can not move like this"
        end
      end

      defp not_linear_move([x_route, y_route]) do
        x_route != 0 && y_route != 0
      end

      defp not_diagonal_move([x_route, y_route]) do
        abs(x_route) != abs(y_route)
      end
    end
  end
end
