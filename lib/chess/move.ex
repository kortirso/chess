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
  @white_pions [[1, 1], [-1, 1]]
  @black_pions [[1, -1], [-1, -1]]

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

  def new(%Game{} = game, move) when is_binary(move) do
    current_position = Position.new(game.current_fen)

    case do_parse_move(move, current_position.active) do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      parsed_move -> find_figure(game, current_position, parsed_move)
    end
  end

  # checking source square for existed figure for move
  defp find_figure(game, current_position, [move_from, move_to] = parsed_move) do
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
    do: 1

  defp check_barriers_on_route(game, current_position, [move_from, move_to] = parsed_move, figure, route_and_distance) do
    result = do_check_barriers_on_route(game.squares, move_from, route_and_distance)

    cond do
      # check rook for castling
      result == {:ok} && figure.type == "k" ->
        [rook_from, rook_route_and_distance] = define_rook_move_for_castling(move_to)
        do_check_barriers_on_route(game.squares, rook_from, rook_route_and_distance)

      # continue
      result == {:ok} ->
        1

      # render error message
      result ->
        result
    end
  end

  defp define_rook_move_for_castling(move_to) do
    cond do
      move_to == "g1" -> ["h1", [[-2, 0], 2]]
      move_to == "c1" -> ["a1", [[3, 0], 3]]
      move_to == "g8" -> ["h8", [[-2, 0], 2]]
      move_to == "c8" -> ["a8", [[3, 0], 3]]
      true -> ["", [[0, 0], 0]]
    end
  end

  @doc """
  def new(%Game{squares: squares, current_fen: current_fen, history: history, status: status}, move) when is_binary(move) do
    try do
      [is_attack, is_castling, squares] = check_destination(squares, move_from, move_to, squares[:"#move_to}"], figure, current_position.en_passant, distance)
      [status, check] = end_move(squares, current_position.active, status)

      {:ok,
        %Game{
          squares: squares,
          current_fen: Position.new(squares, current_position, figure, distance, move_to, is_attack, is_castling) |> Position.to_fen,
          history: [%{fen: current_fen, move: move} | history],
          status: status,
          check: check
        }
      }
    rescue
      error -> {:error, error.message}
    end
  end
  """
end
