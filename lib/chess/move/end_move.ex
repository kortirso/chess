defmodule Chess.Move.EndMove do
  @moduledoc """
  Module for checking attacked squares
  """  

  alias Chess.{Figure}

  defmacro __using__(_opts) do
    quote do
      defp end_move(squares, active, status) do
        {active_king_square, _active_king} = Enum.find(squares, fn {_square, %Figure{color: color, type: type}} -> type == "k" && String.first(color) == active end)
        opponent_figures = Enum.filter(squares, fn {_square, %Figure{color: color}} -> String.first(color) != active end)

        {opponent_king_square, _opponent_king} = Enum.find(squares, fn {_square, %Figure{color: color, type: type}} -> type == "k" && String.first(color) != active end)
        active_figures = Enum.filter(squares, fn {_square, %Figure{color: color}} -> String.first(color) == active end)

        # обычное состояние игры
        # проверка шаха (сохраняются атакующая фигура и путь атаки)
        # шах - если король находится на битом поле
        # выход из под шаха 1 - ход короля
        # выход из под шаха 2 - перекрыть путь угрозе (нет, если 2 угрозы, атакующий вплотную, или конь)
        # выход из под шаха 3 - взять атакующую фигуру (нет, если 2 угрозы)
        # проверка мата (невозможность ответного хода), если шах

        squares_under_active_attack = define_squares_under_active_attack(squares, active_figures)

        if opponent_king_square in squares_under_active_attack do
          [:check, active]
        else
          [:playing, nil]
        end

        # в начале хода был шах
        # проверка выхода из шаха
        # проверка шаха
        # проверка мата (невозможность ответного хода), если шах
      end

      defp define_squares_under_active_attack(squares, active_figures) do
        Enum.map(active_figures, fn x ->
          check_attacked_squares(squares, x)
        end)
        |> List.flatten
        |> Enum.uniq
      end

      defp check_attacked_squares(squares, {square, %Figure{type: type}}) when type in ["k", "q"] do
        check_diagonal_moves(squares, convert_to_indexes(square), type) ++ check_linear_moves(squares, convert_to_indexes(square), type)
      end

      defp check_attacked_squares(squares, {square, %Figure{type: type}}) when type == "b" do
        check_diagonal_moves(squares, convert_to_indexes(square), "b")
      end

      defp check_attacked_squares(squares, {square, %Figure{type: type}}) when type == "r" do
        check_linear_moves(squares, convert_to_indexes(square), "b")
      end

      defp check_attacked_squares(squares, {square, %Figure{type: type}}) when type == "n" do
        check_knight_moves(squares, convert_to_indexes(square), "n")
      end

      defp check_attacked_squares(squares, {square, %Figure{color: color, type: type}}) when type == "p" do
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

      defp check_diagonal_moves(squares, square, type) do
        limit = if type == "k", do: 1, else: 7
        Enum.map(@diagonals, fn route ->
          check_attacked_square(squares, square, route, 1, limit, [])
        end)
      end

      defp check_linear_moves(squares, square, type) do
        limit = if type == "k", do: 1, else: 7
        Enum.map(@linears, fn route ->
          check_attacked_square(squares, square, route, 1, limit, [])
        end)
      end

      defp check_knight_moves(squares, square, "n") do
        Enum.map(@knights, fn route ->
          check_attacked_square(squares, square, route, 1, 1, [])
        end)
      end

      defp check_pion_attack_moves(squares, square, color) do
        routes = if color == "w", do: @white_pions, else: @black_pions
        Enum.map(routes, fn route ->
          check_attacked_square(squares, square, route, 1, 1, [])
        end)
      end

      defp check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step, limit, acc) when current_step <= limit do
        x_square_index = x_index + x_route * current_step
        y_square_index = y_index + y_route * current_step
        if x_square_index in @indexes && y_square_index in @indexes do
          square = :"#{Enum.at(@x_fields, x_square_index)}#{Enum.at(@y_fields, y_square_index)}"
          acc = Enum.concat(acc, [square])
          if Keyword.has_key?(squares, square) do
            check_attacked_square(squares, [x_index, y_index], [x_route, y_route], limit + 1, limit, acc)
          else
            check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step + 1, limit, acc)
          end
        else
          check_attacked_square(squares, [x_index, y_index], [x_route, y_route], limit + 1, limit, acc)
        end
      end

      defp check_attacked_square(_squares, _square, _route, current_step, limit, acc) when current_step > limit do
        acc
      end
    end
  end
end
