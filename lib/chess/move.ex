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
  @white_pions_moves [[0, 1], [0, 1]]
  @black_pions_moves [[0, -1], [0, -1]]

  defstruct value: "",
            from: "",
            to: "",
            figure: nil,
            route: [],
            distance: 0,
            is_attack: false,
            is_castling: false,
            squares: [],
            promotion: ""

  alias Chess.{Game, Move, Position, Figure}
  use Move.{Parse, FindFigure, RouteDistance, FigureRoute, Barriers, CheckCastling, Destination, EndMove}

  @doc """
  Make new move in chess game

  ## Examples

      iex> Chess.Move.new(%Chess.Game{}, "e2-e4")
      {:ok, %Chess.Game{}}

      iex> Chess.Move.new(%Chess.Game{}, "e2-e5")
      {:error, ""}

  """

  def new(%Game{} = game, value, promotion \\ "q") when is_binary(value) and promotion in ["r", "n", "b", "q"] do
    current_position = Position.new(game.current_fen)

    case do_parse_move(game, value, current_position.active) do
      # render error message
      {:error, message} ->
        {:error, message}

      # continue
      [from, to] ->
        %Move{value: value, from: from, to: to, promotion: promotion}
        |> find_figure(game, current_position)
    end
  end

  # checking source square for existed figure for move
  defp find_figure(move, game, current_position) do
    case do_find_figure(game.squares[:"#{move.from}"], current_position.active) do
      # render error message
      {:error, message} ->
        {:error, message}

      # continue
      figure ->
        %{move | figure: figure}
        |> calc_route_for_figure(game, current_position)
    end
  end

  # calculates route and distance for figure's move
  defp calc_route_for_figure(move, game, current_position) do
    case do_calc_route_and_distance(move) do
      # render error message
      {:error, message} ->
        {:error, message}

      # continue
      [route, distance] ->
        %{move | route: route, distance: distance}
        |> check_route_for_figure(game, current_position)
    end
  end

  defp check_route_for_figure(move, game, current_position) do
    case do_check_figure_route(move.figure, move.route, coordinates(move.from), current_position.castling) do
      # render error message
      {:error, message} -> {:error, message}
      # continue
      _ -> check_barriers_on_route(move, game, current_position, move.figure, move.distance)
    end
  end

  # check barriers on the figure's route
  # except knight's move and moves to distance in 1 square
  defp check_barriers_on_route(move, game, current_position, %Figure{type: type}, distance)
    when type == "n" or distance == 1,
    do: check_destination(move, game, current_position)

  # check castling
  defp check_barriers_on_route(move, game, current_position, %Figure{type: "k"}, _) do
    [route, distance] = define_rook_move_for_castling(move.to)
    result = do_check_barriers_on_route(game.squares, move.from, route, distance)

    case result do
      # continue
      {:ok} -> check_castling(move, game, current_position)
      # render error message
      _ -> result
    end
  end

  defp check_barriers_on_route(move, game, current_position, _, _) do
    result = do_check_barriers_on_route(game.squares, move.from, move.route, move.distance)

    case result do
      # continue
      {:ok} -> check_destination(move, game, current_position)
      # render error message
      _ -> result
    end
  end

  defp define_rook_move_for_castling(square) when square in ["g1", "g8"], do: [[1, 0], 3]
  defp define_rook_move_for_castling(square) when square in ["c1", "c8"], do: [[-1, 0], 4]

  # check attacked middle square while castling
  defp check_castling(move, game, current_position) do
    result = do_check_castling(move, game, current_position)

    case result do
      # continue
      {:ok} -> check_destination(move, game, current_position)
      # render error message
      _ -> result
    end
  end

  # check destanation point
  defp check_destination(move, game, current_position) do
    after_move_status = do_check_destination(game.squares, move, game.squares[:"#{move.to}"], current_position.en_passant)

    case after_move_status do
      # render error message
      {:error, message} ->
        {:error, message}

      # continue
      [is_attack, is_castling, squares] ->
        %{move | is_attack: is_attack, is_castling: is_castling, squares: squares}
        |> complete_move(game, current_position)
    end
  end

  # complete move
  defp complete_move(move, game, current_position) do
    case do_end_move(move, game, current_position) do
      # valid move
      {:ok, [status, check]} ->
        {:ok,
          %Game{
            squares: move.squares,
            current_fen: Position.new(move, current_position) |> Position.to_fen(),
            history: [%{fen: game.current_fen, move: move.value} | game.history],
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
