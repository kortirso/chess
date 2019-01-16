defmodule Chess.Move do
  @moduledoc """
  Move module
  """

  @x_fields ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_fields ["1", "2", "3", "4", "5", "6", "7", "8"]

  @indexes [0, 1, 2, 3, 4, 5, 6, 7]

  @diagonals [[-1, -1], [-1, 1], [1, 1], [1, -1]]
  @linears [[-1, 0], [0, 1], [1, 0], [0, -1]]
  @knights [[-1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2]]
  @white_pions [[1, -1], [-1, -1]]
  @black_pions [[1, 1], [-1, 1]]
  @white_pions_moves [[0, -1], [0, -1]]
  @black_pions_moves [[0, 1], [0, 1]]

  alias Chess.{Game, Move, Position, Figure}
  use Move.{Parse, FigureRoute, Barriers, Destination, EndMove}

  @doc """
  Make new move in chess game

  ## Examples

      iex> Chess.Move.new(%Chess.Game{}, "e2-e4")
      {:ok, %Chess.Game{}}

      iex> Chess.Move.new(%Chess.Game{}, "e2-e5")
      {:error, ""}

  """

  def new(%Game{} = game, move, :virtual) when is_binary(move) do
    current_position = Position.new(game.current_fen)
    [move_from, move_to] = do_parse_move(move, current_position.active)
    figure = do_find_figure(game.squares[:"#{move_from}"], current_position.active)
    [_, distance] = calc_route_and_distance([move_from, move_to])
    [is_attack, is_castling, new_squares] = do_check_destination(game.squares, [move_from, move_to], game.squares[:"#{move_to}"], figure, current_position.en_passant, distance)

    {:ok,
      %Game{
        squares: new_squares,
        current_fen: Position.new(new_squares, current_position, figure, distance, move_to, is_attack, is_castling) |> Position.to_fen(),
        history: [],
        status: :check,
        check: current_position.active
      }
    }
  end

  def new(%Game{} = game, move, _) when is_binary(move) do
    current_position = Position.new(game.current_fen)

    case do_parse_move(move, current_position.active) do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      parsed_move -> find_figure(game, current_position, parsed_move)
    end
  end

  # checking source square for existed figure for move
  defp find_figure(game, current_position, [move_from, _] = parsed_move) do
    case do_find_figure(game.squares[:"#{move_from}"], current_position.active) do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      figure -> check_route_for_figure(game, current_position, parsed_move, figure)
    end
  end

  defp do_find_figure(nil, _), do: {:error, "Square does not have figure for move"}

  defp do_find_figure(%Figure{color: color} = figure, active_player) do
    if String.first(color) != active_player, do: {:error, "This is not move of #{color} player"}, else: figure
  end

  # calculates route and distance for figure's move
  defp check_route_for_figure(game, current_position, parsed_move, figure) do
    case calc_route_and_distance(parsed_move) do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      route_and_distance -> do_check_route_for_figure(game, current_position, parsed_move, figure, route_and_distance)
    end
  end

  defp calc_route_and_distance([move_from, move_to]) do
    # calculate route direction
    route = calc_route(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))
    # calculate distance of move
    distance = calc_distance(route)

    case distance do
      0 -> {:error, "You need to move figure somewhere"}
      _ -> [route, distance]
    end
  end

  defp calc_route([move_from_x, move_from_y], [move_to_x, move_to_y]) do
    [
      Enum.find_index(@x_fields, fn x -> x == move_to_x end) - Enum.find_index(@x_fields, fn x -> x == move_from_x end),
      Enum.find_index(@y_fields, fn y -> y == move_to_y end) - Enum.find_index(@y_fields, fn y -> y == move_from_y end)
    ]
  end

  defp calc_distance(route) do
    route
    |> Enum.map(fn x -> abs(x) end)
    |> Enum.max()
  end

  defp do_check_route_for_figure(game, current_position, [move_from, _] = parsed_move, figure, [route, _] = route_and_distance) do
    case check_figure_route(figure, route, String.split(move_from, "", trim: true), current_position.castling) do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      _ -> check_barriers_on_route(game, current_position, parsed_move, figure, route_and_distance)
    end
  end

  # check barriers on the figure's route
  # except knight's move and moves to distance in 1 square
  defp check_barriers_on_route(game, current_position, parsed_move, %Figure{type: type} = figure, [_, distance] = route_and_distance)
    when type == "n" or distance == 1,
    do: check_destination(game, current_position, parsed_move, figure, route_and_distance)

  defp check_barriers_on_route(game, current_position, [move_from, move_to] = parsed_move, figure, route_and_distance) do
    result = do_check_barriers_on_route(game.squares, move_from, route_and_distance)

    cond do
      # check rook for castling
      result == {:ok} && figure.type == "k" ->
        [rook_from, rook_route_and_distance] = define_rook_move_for_castling(move_to)
        check_barriers_on_route(game, current_position, [rook_from, nil], game.squares[:"#{rook_from}"],rook_route_and_distance)

      # continue
      result == {:ok} ->
        check_destination(game, current_position, parsed_move, figure, route_and_distance)

      # render error message
      true ->
        result
    end
  end

  defp define_rook_move_for_castling("g1"), do: ["h1", [[-2, 0], 2]]
  defp define_rook_move_for_castling("c1"), do: ["a1", [[3, 0], 3]]
  defp define_rook_move_for_castling("g8"), do: ["h8", [[-2, 0], 2]]
  defp define_rook_move_for_castling("c8"), do: ["a8", [[3, 0], 3]]
  defp define_rook_move_for_castling(_), do: ["", [[0, 0], 0]]

  # check destanation point
  defp check_destination(game, current_position, [_, move_to] = parsed_move, figure, [_, distance] = route_and_distance) do
    after_move_status = do_check_destination(game.squares, parsed_move, game.squares[:"#{move_to}"], figure, current_position.en_passant, distance)
    # after_move_status == [is_attack, is_castling, new_squares]

    case after_move_status do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      _ -> complete_move(game, current_position, parsed_move, figure, route_and_distance, after_move_status)
    end
  end

  # complete move
  defp complete_move(game, current_position, [move_from, move_to] = parsed_move, figure, [_, distance], [is_attack, is_castling, new_squares]) do
    case end_move(game, parsed_move, new_squares, current_position.active) do
      # valid move
      {:ok, [status, check]} ->
        {:ok,
          %Game{
            squares: new_squares,
            current_fen: Position.new(new_squares, current_position, figure, distance, move_to, is_attack, is_castling) |> Position.to_fen(),
            history: [%{fen: game.current_fen, move: "#{move_from}-#{move_to}"} | game.history],
            status: status,
            check: check
          }
        }

      # invalid moves for check status
      result ->
        result
    end
  end
end
