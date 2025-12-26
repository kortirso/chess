defmodule Chess.Move.EndMove do
  @moduledoc """
  Module for checking attacked squares
  """

  alias Chess.{Figure, Game, Position}

  defmacro __using__(_opts) do
    quote do
      defp do_end_move(move, game, current_position) do
        case game.status do
          :completed -> {:error, "The game is over"}
          _ -> check_avoiding(move, game, current_position)
        end
      end

      defp check_avoiding(move, game, current_position) do
        {
          king_square,
          _
        } = Enum.find(move.squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && color == current_position.active end)
        active_figures = define_active_figures(move.squares, opponent(current_position.active))
        attackers = define_attackers(active_figures, king_square)

        case length(attackers) do
          0 -> check_attack(move, game, current_position)
          _ -> {:error, "This move is invalid, king is under attack"}
        end
      end

      defp check_attack(move, game, current_position) do
        {
          opponent_king_square,
          opponent_king
        } = Enum.find(move.squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && color != current_position.active end)
        active_figures = define_active_figures(move.squares, current_position.active)
        attackers = define_attackers(active_figures, opponent_king_square)

        case length(attackers) do
          0 -> {:ok, [:playing, nil]}
          1 -> check_for_one_attacker(move, game, current_position, opponent_king_square, opponent_king, active_figures, attackers)
          _ -> check_for_many_attackers(opponent_king_square, opponent_king, active_figures, move.squares, current_position)
        end
      end

      defp check_for_one_attacker(move, game, current_position, opponent_king_square, opponent_king, active_figures, attackers) do
        {{attacker_square, _}, _} = Enum.at(attackers, 0)

        case king_escape_is_possible?(opponent_king_square, opponent_king, active_figures, move.squares, current_position) do
          # if king can avoid check by self
          true -> {:ok, [:check, current_position.active]}
          # try to avoid by using another figures
          false -> can_destroy_attacker?(move, game, current_position, opponent_king_square, attacker_square)
        end
      end

      defp check_for_many_attackers(opponent_king_square, opponent_king, active_figures, squares, current_position) do
        case king_escape_is_possible?(opponent_king_square, opponent_king, active_figures, squares, current_position) do
          true -> {:ok, [:playing, nil]}
          false -> {:ok, [:completed, current_position.active]}
        end
      end

      # try to destroy attacker
      defp can_destroy_attacker?(move, game, current_position, opponent_king_square, attacker_square) do
        # check if some figure can destroy attacker
        case check_attackers(move, game, current_position, attacker_square) do
          # if yes -> continue
          true -> {:ok, [:check, current_position.active]}
          # if no -> find blockers
          false -> can_block_attackers?(move, game, current_position, opponent_king_square, attacker_square)
        end
      end

      # try to block attacker route
      defp can_block_attackers?(move, game, current_position, opponent_king_square, attacker_square) do
        route = calc_route(Atom.to_string(attacker_square), Atom.to_string(opponent_king_square))
        distance = calc_distance(route)
        squares_for_block = define_squares_for_block(attacker_square, route, distance)

        # check if some figure can block attacker
        case check_defenders(move, game, current_position, squares_for_block) do
          # if yes -> continue
          true -> {:ok, [:check, current_position.active]}
          # if no -> mat
          false -> {:ok, [:completed, current_position.active]}
        end
      end

      defp check_attackers(move, game, current_position, attacker_square) do
        find_defenders(move.squares, current_position.active, "attack", [attacker_square])
        |> Stream.map(fn {{square, figure}, can_attack_squares} ->
          {
            figure,
            square,
            can_attack_squares |> Stream.filter(fn x -> x == attacker_square end) |> Enum.at(0)
          }
        end)
        |> make_virtual_move(move, game, current_position)
      end

      defp check_defenders(move, game, current_position, squares_for_block) do
        find_defenders(move.squares, current_position.active, "block", squares_for_block)
        |> Stream.map(fn {{square, figure}, can_attack_squares} ->
          {
            figure,
            square,
            can_attack_squares |> Stream.filter(fn x -> x in squares_for_block end) |> Enum.at(0)
          }
        end)
        |> make_virtual_move(move, game, current_position)
      end

      defp make_virtual_move(figures, move, game, current_position) do
        Enum.any?(figures, fn {_, from, to} ->
          case %Game{
                 squares: move.squares,
                 current_fen: Position.new(move, current_position) |> Position.to_fen(),
                 history: [],
                 status: :check,
                 check: current_position.active
               }
               |> Game.play("#{from}-#{to}") do
            {:ok, virtual_game} -> virtual_game.status == :playing
            {:error, _reason} -> false
          end
        end)
      end

      defp find_defenders(squares, active, type, need_attack_squares) do
        squares
        |> define_defense_figures(active, type)
        |> Stream.filter(fn {{_, %Figure{type: type}}, squares} ->
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
        square = "#{Enum.at(Chess.x_fields, move_to_x_index)}#{Enum.at(Chess.y_fields, move_to_y_index)}"
        acc = [square | acc]
        collect_squares_with_attack([move_from_x_index, move_from_y_index], [x_direction, y_direction], distance, step + 1, acc)
      end

      defp collect_squares_with_attack(_, _, _, _, acc), do: acc

      defp king_escape_is_possible?(opponent_king_square, opponent_king, active_figures, squares, current_position) do
        attacked_squares = Enum.map(active_figures, fn {_, squares} -> squares end) |> List.flatten() |> Enum.uniq()
        possible_king_moves =
          check_attacked_squares(squares, {opponent_king_square, opponent_king}, "attack")
          |> List.flatten()
          |> Stream.filter(fn x ->
            if Keyword.has_key?(squares, x) do
              %Figure{color: color} = squares[x]
              color == current_position.active
            else
              true
            end
          end)
          |> Enum.filter(fn x -> x not in attacked_squares end)

        length(possible_king_moves) > 0
      end

      defp define_defense_figures(squares, active, type) do
        squares
        |> Stream.filter(fn {_, %Figure{color: color}} -> color != active end)
        |> calc_attacked_squares(squares, type)
      end
    end
  end
end
