defmodule Chess.Move.EndMove do
  @moduledoc """
  Module for checking attacked squares
  """  

  alias Chess.Figure

  defmacro __using__(_opts) do
    quote do
      defp end_move(squares, active, status) do
        case status do
          :playing -> check_attack(squares, active)
          _ -> 2
        end
      end

      defp check_attack(squares, active) do
        {opponent_king_square, _} = Enum.find(squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && String.first(color) != active end)
        active_figures = Enum.filter(squares, fn {_, %Figure{color: color}} -> String.first(color) == active end)
        attackers = define_squares_under_attack(squares, active_figures, opponent_king_square)

        IO.inspect attackers

        if length(attackers) > 0 do
          {:ok, [:check, active]}
        else
          {:ok, [:playing, nil]}
        end
      end

      defp define_squares_under_attack(squares, active_figures, opponent_king_square) do
        active_figures
        |> calc_attacked_squares(squares)
        |> Enum.filter(fn {_, squares} -> opponent_king_square in squares end)
      end

      defp calc_attacked_squares(figures, squares) do
        Enum.map(figures, fn x ->
          {
            x,
            check_attacked_squares(squares, x) |> List.flatten()
          }
        end)
      end

      defp check_attacked_squares(squares, {square, %Figure{type: type}}) when type in ["k", "q"] do
        check_diagonal_moves(squares, convert_to_indexes(square), type) ++ check_linear_moves(squares, convert_to_indexes(square), type)
      end

      defp check_attacked_squares(squares, {square, %Figure{type: "b"}}) do
        check_diagonal_moves(squares, convert_to_indexes(square), "b")
      end

      defp check_attacked_squares(squares, {square, %Figure{type: "r"}}) do
        check_linear_moves(squares, convert_to_indexes(square), "r")
      end

      defp check_attacked_squares(squares, {square, %Figure{type: "n"}}) do
        check_knight_moves(squares, convert_to_indexes(square))
      end

      defp check_attacked_squares(squares, {square, %Figure{color: color, type: "p"}}) do
        check_pion_attack_moves(squares, convert_to_indexes(square), color)
      end

      defp convert_to_indexes(square) do
        square = Atom.to_string(square)
        x_square_index = String.first(square)
        y_square_index = String.last(square)

        [
          Enum.find_index(@x_fields, fn x -> x == x_square_index end),
          Enum.find_index(@y_fields, fn x -> x == y_square_index end)
        ]
      end

      defp check_diagonal_moves(squares, square, "k") do
        Enum.map(@diagonals, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_diagonal_moves(squares, square, _) do
        Enum.map(@diagonals, fn route -> check_attacked_square(squares, square, route, 1, 7, []) end)
      end

      defp check_linear_moves(squares, square, "k") do
        Enum.map(@linears, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_linear_moves(squares, square, _) do
        Enum.map(@linears, fn route -> check_attacked_square(squares, square, route, 1, 7, []) end)
      end

      defp check_knight_moves(squares, square) do
        Enum.map(@knights, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_pion_attack_moves(squares, square, color) do
        routes = if color == "w", do: @white_pions, else: @black_pions
        Enum.map(routes, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step, limit, acc) when current_step <= limit do
        x_square_index = x_index + x_route * current_step
        y_square_index = y_index + y_route * current_step

        if x_square_index in @indexes && y_square_index in @indexes do
          square = :"#{Enum.at(@x_fields, x_square_index)}#{Enum.at(@y_fields, y_square_index)}"
          acc = [square | acc]
          if Keyword.has_key?(squares, square) do
            check_attacked_square(squares, [x_index, y_index], [x_route, y_route], limit + 1, limit, acc)
          else
            check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step + 1, limit, acc)
          end
        else
          check_attacked_square(squares, [x_index, y_index], [x_route, y_route], limit + 1, limit, acc)
        end
      end

      defp check_attacked_square(_, _, _, current_step, limit, acc) when current_step > limit, do: acc
    end
  end
end
