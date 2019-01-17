defmodule Chess.Move.FigureRoute do
  @moduledoc """
  Module for checking figures routes
  """

  alias Chess.Figure

  defmacro __using__(_opts) do
    quote do
      defp do_check_figure_route(%Figure{color: color, type: "p"}, route, [_, move_from_y], _) do
        unless pion_move?(route, move_from_y, color), do: {:error, "Pion can not move like this"}
      end

      defp do_check_figure_route(%Figure{type: "r"}, route, _, _) do
        unless linear_move?(route), do: {:error, "Rook can not move like this"}
      end

      defp do_check_figure_route(%Figure{type: "n"}, route, _, _) do
        unless knight_move?(route), do: {:error, "Knight can not move like this"}
      end

      defp do_check_figure_route(%Figure{type: "b"}, route, _, _) do
        unless diagonal_move?(route), do: {:error, "Bishop can not move like this"}
      end

      defp do_check_figure_route(%Figure{type: "q"}, route, _, _) do
        unless diagonal_move?(route) || linear_move?(route), do: {:error, "Queen can not move like this"}
      end

      defp do_check_figure_route(%Figure{color: color, type: "k"}, route, _, castling) do
        unless king_move?(route, castling, color), do: {:error, "King can not move like this"}
      end

      defp pion_move?([x_route, y_route], move_from_y, "white") do
        abs(x_route) == 1 && y_route == 1 || x_route == 0 && (y_route == 1 || y_route == 2 && move_from_y == start_line_for_pion("white"))
      end

      defp pion_move?([x_route, y_route], move_from_y, _) do
        abs(x_route) == 1 && y_route == -1 || x_route == 0 && (y_route == -1 || y_route == -2 && move_from_y == start_line_for_pion("black"))
      end

      defp start_line_for_pion("white"), do: "2"
      defp start_line_for_pion(_), do: "7"

      defp linear_move?([x_route, y_route]), do: x_route == 0 || y_route == 0

      defp diagonal_move?([x_route, y_route]), do: abs(x_route) == abs(y_route)

      defp knight_move?([x_route, y_route]), do: abs(x_route) == 2 && abs(y_route) == 1 || abs(x_route) == 1 && abs(y_route) == 2

      defp king_move?([x_route, y_route], castling, color) do
        possible = [-1, 0, 1]
        x_route in possible && y_route in possible || x_route in [-2, 2] && y_route == 0 && String.contains?(castling, possible_castling(x_route, color))
      end

      defp possible_castling(x_route, color) do
        way_of_castling(x_route)
        |> side_of_castling(color)
      end

      defp way_of_castling(2), do: "k"
      defp way_of_castling(_), do: "q"

      defp side_of_castling(side, "white"), do: String.capitalize(side)
      defp side_of_castling(side, _), do: side
    end
  end
end
