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
      # continue
      [move_from, move_to] -> 1
      # render error message
      result -> result
    end
  end

  @doc """
  def new(%Game{squares: squares, current_fen: current_fen, history: history, status: status}, move) when is_binary(move) do
    try do
      current_position = Position.new(current_fen)
      [move_from, move_to] = do_parse_move(move, current_position.active)
      figure = find_figure(squares[:"#move_from}"])
      check_active_player(figure, current_position.active)
      [route, distance] = check_route_for_figure(figure, move_from, move_to, current_position.castling)

      if figure.type != "n", do: check_barriers_on_route(squares, move_from, route, distance)
      if figure.type == "k" && distance == 2 do
        [rook_from, rook_route, rook_distance] = define_rook_move_for_castling(move_to)
        check_barriers_on_route(squares, rook_from, rook_route, rook_distance)
      end

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

  defp find_figure(nil), do: raise "Square does not have figure for move"
  defp find_figure(figure), do: figure

  defp check_active_player(%Figure{color: color}, active) do
    if String.first(color) != active, do: raise "This is not move of #{color} player"
  end

  defp check_route_for_figure(figure, move_from, move_to, castling) do
    route = calc_route(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))
    distance = calc_distance(route)
    if distance == 0, do: raise "You need to move figure somewhere"
    check_figure_route(figure, route, String.split(move_from, "", trim: true), castling)

    [
      route,
      distance
    ]
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

  defp define_rook_move_for_castling(move_to) do
    cond do
      move_to == "g1" -> ["h1", [-2, 0], 2]
      move_to == "c1" -> ["a1", [3, 0], 3]
      move_to == "g8" -> ["h8", [-2, 0], 2]
      move_to == "c8" -> ["a8", [3, 0], 3]
      true -> ["", [0, 0], 0]
    end
  end
end
