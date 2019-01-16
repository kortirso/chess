defmodule Chess.Move.EndMove do
  @moduledoc """
  Module for checking attacked squares
  """  

  alias Chess.{Figure, Game}

  defmacro __using__(_opts) do
    quote do
      defp end_move(game, parsed_move, squares, active) do
        case game.status do
          :playing -> check_attack(game, parsed_move, squares, active)
          _ -> {:ok, [:playing, nil]} # add here check for safety king
        end
      end

      defp check_attack(game, parsed_move, squares, active) do
        {opponent_king_square, opponent_king} = Enum.find(squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && String.first(color) != active end)
        active_figures = define_active_figures(squares, active)
        attackers = define_attackers(active_figures, opponent_king_square)

        case length(attackers) do
          # no attackers
          0 -> {:ok, [:playing, nil]}
          # 1 attacker
          1 -> check_for_one_attacker(game, parsed_move, opponent_king_square, opponent_king, active_figures, squares, active, attackers)
          # more than 1 attacker
          _ -> check_for_many_attackers(opponent_king_square, opponent_king, active_figures, squares, active)
        end
      end

      defp check_for_one_attacker(game, parsed_move, opponent_king_square, opponent_king, active_figures, squares, active, attackers) do
        {{attacker_square, _}, _} = Enum.at(attackers, 0)

        case king_escape_is_possible?(opponent_king_square, opponent_king, active_figures, squares, active) do
          # if king can avoid check by self
          true -> {:ok, [:check, active]}
          # try to avoid by using another figures
          false -> can_destroy_attackers?(game, parsed_move, opponent_king_square, squares, active, attacker_square)
        end
      end

      defp check_for_many_attackers(opponent_king_square, opponent_king, active_figures, squares, active) do
        case king_escape_is_possible?(opponent_king_square, opponent_king, active_figures, squares, active) do
          true -> {:ok, [:playing, nil]}
          false -> {:ok, [:completed, "mat"]}
        end
      end

      # try to destroy attacker
      defp can_destroy_attackers?(game, parsed_move, opponent_king_square, squares, active, attacker_square) do
        # check if some figure can destroy attacker
        case check_attackers(game, squares, active, attacker_square, parsed_move) do
          # if yes -> continue
          true -> {:ok, [:check, active]}
          # if no -> find blockers
          false -> can_block_attackers?(game, parsed_move, opponent_king_square, squares, active, attacker_square)
        end
      end

      # try to block attacker route
      defp can_block_attackers?(game, parsed_move, opponent_king_square, squares, active, attacker_square) do
        route = calc_route(String.split(Atom.to_string(attacker_square), "", trim: true), String.split(Atom.to_string(opponent_king_square), "", trim: true))
        distance = calc_distance(route)
        squares_for_block = define_squares_for_block(attacker_square, route, distance)

        # check if some figure can block attacker
        case check_defenders(game, squares, active, squares_for_block, parsed_move) do
          # if yes -> continue
          true -> {:ok, [:check, active]}
          # if no -> mat
          false -> {:ok, [:completed, "mat"]}
        end
      end

      defp check_attackers(game, squares, active, attacker_square, parsed_move) do
        find_defenders(squares, active, "attack", [attacker_square])
        |> Enum.map(fn {{square, figure}, can_attack_squares} ->
          {
            figure,
            square,
            can_attack_squares |> Enum.filter(fn x -> x == attacker_square end) |> Enum.at(0)
          }
        end)
        |> make_virtual_move(game, parsed_move)
      end

      defp check_defenders(game, squares, active, squares_for_block, parsed_move) do
        find_defenders(squares, active, "block", squares_for_block)
        |> Enum.map(fn {{square, figure}, can_attack_squares} ->
          {
            figure,
            square,
            can_attack_squares |> Enum.filter(fn x -> x in squares_for_block end) |> Enum.at(0)
          }
        end)
        |> make_virtual_move(game, parsed_move)
      end

      defp make_virtual_move(figures, game, [move_from, move_to]) do
        Enum.any?(figures, fn {_, from, to} ->
          {:ok, virtual_game} = Game.play(game, "#{move_from}-#{move_to}", :virtual)
          {:ok, virtual_game} = Game.play(virtual_game, "#{from}-#{to}")
          virtual_game.status == :playing
        end)
      end

      defp find_defenders(squares, active, type, need_attack_squares) do
        squares
        |> define_defense_figures(active, type)
        |> Enum.filter(fn {{_, %Figure{type: type}}, squares} ->
          type != "k" && Enum.any?(need_attack_squares, fn x -> x in squares end)
        end)
      end

      defp define_squares_for_block(attacker_square, route, distance) do
        attacker_square
        |> Atom.to_string()
        |> coordinates()
        |> calc_from_index()
        |> collect_squares_with_attack(calc_direction(route), distance, 1, [])
        |> Enum.map(fn x -> String.to_atom(x) end)
      end

      defp collect_squares_with_attack([move_from_x_index, move_from_y_index], [x_direction, y_direction], distance, step, acc) when distance > step do
        move_to_x_index = Kernel.trunc(move_from_x_index + step * x_direction)
        move_to_y_index = Kernel.trunc(move_from_y_index + step * y_direction)
        square = "#{Enum.at(@x_fields, move_to_x_index)}#{Enum.at(@y_fields, move_to_y_index)}"
        acc = [square | acc]
        collect_squares_with_attack([move_from_x_index, move_from_y_index], [x_direction, y_direction], distance, step + 1, acc)
      end

      defp collect_squares_with_attack(_, _, _, _, acc), do: acc

      defp king_escape_is_possible?(opponent_king_square, opponent_king, active_figures, squares, active) do
        attacked_squares = Enum.map(active_figures, fn {_, squares} -> squares end) |> List.flatten() |> Enum.uniq()
        possible_king_moves =
          check_attacked_squares(squares, {opponent_king_square, opponent_king}, "attack")
          |> List.flatten()
          |> Enum.filter(fn x ->
            if Keyword.has_key?(squares, x) do
              %Figure{color: color} = squares[x]
              String.first(color) == active
            else
              true
            end
          end)
          |> Enum.filter(fn x -> x not in attacked_squares end)

        length(possible_king_moves) > 0
      end

      defp define_active_figures(squares, active) do
        squares
        |> Enum.filter(fn {_, %Figure{color: color}} -> String.first(color) == active end)
        |> calc_attacked_squares(squares, "attack")
      end

      defp define_defense_figures(squares, active, type) do
        squares
        |> Enum.filter(fn {_, %Figure{color: color}} -> String.first(color) != active end)
        |> calc_attacked_squares(squares, type)
      end

      defp calc_attacked_squares(figures, squares, type) do
        Enum.map(figures, fn x ->
          {
            x,
            check_attacked_squares(squares, x, type) |> List.flatten()
          }
        end)
      end

      defp define_attackers(active_figures, opponent_king_square) do
        Enum.filter(active_figures, fn {_, squares} -> opponent_king_square in squares end)
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

      defp check_pion_moves(squares, square, color) do
        routes = if color == "w", do: @white_pions_moves, else: @black_pions_moves
        Enum.map(routes, fn route -> check_attacked_square(squares, square, route, 1, 1, []) end)
      end

      defp check_attacked_square(squares, [x_index, y_index], [x_route, y_route], current_step, limit, acc) when current_step <= limit do
        x_square_index = x_index + x_route * current_step
        y_square_index = y_index + y_route * current_step

        if x_square_index in @indexes && y_square_index in @indexes do
          square = :"#{Enum.at(@x_fields, x_square_index)}#{Enum.at(@y_fields, y_square_index)}"
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
