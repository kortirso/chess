defmodule Chess.Utils do
  @moduledoc """
  """

  alias Chess.{Figure}

  defmacro __using__(_opts) do
    quote do
      defp coordinates(move_from), do: String.split(move_from, "", trim: true)

      defp opponent("w"), do: "b"
      defp opponent(_), do: "w"

      defp define_active_figures(squares, active) do
        squares
        |> Enum.filter(fn {_, %Figure{color: color}} -> color == active end)
        |> calc_attacked_squares(squares, "attack")
      end

      defp calc_attacked_squares(figures, squares, type) do
        Enum.map(figures, fn x ->
          {
            x,
            check_attacked_squares(squares, x, type) |> List.flatten()
          }
        end)
      end

      defp define_attackers(active_figures, king_square) do
        Enum.filter(active_figures, fn {_, squares} -> king_square in squares end)
      end

      defp check_attacked_squares(squares, {square, %Figure{type: type}}, _) when type in ["k", "q"] do
        check_diagonal_moves(squares, convert_to_indexes(square), type) ++ check_linear_moves(squares, convert_to_indexes(square), type)
      end

      defp check_attacked_squares(squares, {square, %Figure{type: "b"}}, _) do
        check_diagonal_moves(squares, convert_to_indexes(square), "b")
      end

      defp check_attacked_squares(squares, {square, %Figure{type: "r"}}, _) do
        check_linear_moves(squares, convert_to_indexes(square), "r")
      end

      defp check_attacked_squares(squares, {square, %Figure{type: "n"}}, _) do
        check_knight_moves(squares, convert_to_indexes(square))
      end

      defp check_attacked_squares(squares, {square, %Figure{color: color, type: "p"}}, "attack") do
        check_pion_attack_moves(squares, convert_to_indexes(square), color)
      end

      defp check_attacked_squares(squares, {square, %Figure{color: color, type: "p"}}, "block") do
        check_pion_moves(squares, convert_to_indexes(square), color)
      end

      defp convert_to_indexes(square) do
        square = Atom.to_string(square)
        x_square_index = String.first(square)
        y_square_index = String.last(square)

        [
          Enum.find_index(Chess.x_fields, fn x -> x == x_square_index end),
          Enum.find_index(Chess.y_fields, fn x -> x == y_square_index end)
        ]
      end

      defp check_diagonal_moves(squares, square, "k") do
        Enum.map(Chess.diagonals, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_diagonal_moves(squares, square, _) do
        Enum.map(Chess.diagonals, fn route -> check_attacked_square(squares, square, route, 1, 7, []) end)
      end

      defp check_linear_moves(squares, square, "k") do
        Enum.map(Chess.linears, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_linear_moves(squares, square, _) do
        Enum.map(Chess.linears, fn route -> check_attacked_square(squares, square, route, 1, 7, []) end)
      end

      defp check_knight_moves(squares, square) do
        Enum.map(Chess.knights, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_pion_attack_moves(squares, square, color) do
        routes = if color == "w", do: Chess.white_pions, else: Chess.black_pions
        Enum.map(routes, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_pion_moves(squares, square, color) do
        routes = if color == "w", do: Chess.white_pions_moves, else: Chess.black_pions_moves
        Enum.map(routes, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step, limit, acc) when current_step <= limit do
        x_square_index = x_index + x_route * current_step
        y_square_index = y_index + y_route * current_step

        if x_square_index in Chess.indexes && y_square_index in Chess.indexes do
          square = :"#{Enum.at(Chess.x_fields, x_square_index)}#{Enum.at(Chess.y_fields, y_square_index)}"
          acc = [square | acc]
          # check barriers on the route
          if Keyword.has_key?(squares, square) do
            %Figure{type: type} = squares[square]
            case type do
              # calculate attacked squares behind king
              "k" -> check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step + 1, limit, acc)
              # stop calculating attacked squares
              _ -> check_attacked_square(squares, [x_index, y_index], [x_route, y_route], limit + 1, limit, acc)
            end
          else
            # add empty field to attacked squares
            check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step + 1, limit, acc)
          end
        else
          # stop calculating attacked squares
          check_attacked_square(squares, [x_index, y_index], [x_route, y_route], limit + 1, limit, acc)
        end
      end

      defp check_attacked_square(_, _, _, current_step, limit, acc) when current_step > limit, do: acc
    end
  end
end
