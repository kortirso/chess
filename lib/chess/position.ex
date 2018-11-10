defmodule Chess.Position do
  @moduledoc """
  Position module
  """

  @x_fields ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_fields [8, 7, 6, 5, 4, 3, 2, 1]

  alias Chess.{Figure, Position}

  defstruct position: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR", active: "w", castling: "KQkq", en_passant: "-", half_move: 0, full_move: 1

  use Position.Parse

  @doc """
  Start position on the board in FEN-notation
  """
  def new() do
    %Position{}
  end

  @doc """
  Calculate FEN-notation for current board
  """
  def new(squares, %Position{active: active, castling: castling, half_move: half_move, full_move: full_move}, figure, distance, move_to, is_attack, is_castling) do
    position = calc_position_from_squares(squares)

    %Position{position: position, active: change_active_player(active), castling: check_castling(castling, is_castling), en_passant: check_en_passant(figure, distance, move_to), half_move: check_half_move(half_move, figure, is_attack), full_move: add_full_move(full_move, active)}
  end

  def from_fen(current_fen) do
    fen = check_fen_format(current_fen)
    %Position{position: Enum.at(fen, 0), active: Enum.at(fen, 1), castling: Enum.at(fen, 2), en_passant: Enum.at(fen, 3), half_move: parse(Integer.parse(Enum.at(fen, 4))), full_move: parse(Integer.parse(Enum.at(fen, 5)))}
  end

  def to_fen(position) do
    [position.position, position.active, position.castling, position.en_passant, position.half_move, position.full_move]
    |> Enum.join(" ")
  end

  defp change_active_player(active) do
    if active == "w" do
      "b"
    else
      "w"
    end
  end

  defp check_castling(castling, is_castling) when is_castling == nil do
    castling
  end

  defp check_castling(castling, [is_king, is_queen]) do
    castling = check_castling(castling, is_king)
    check_castling(castling, is_queen)
  end

  defp check_castling(castling, is_castling) do
    castling = String.replace(castling, is_castling, "")
    if castling == "", do: "-", else: castling
  end

  defp check_en_passant(%Figure{type: type}, distance, _move_to) when type != "p" or distance != 2 do
    "-"
  end

  defp check_en_passant(%Figure{color: color}, _distance, move_to) do
    {y_point, _} = Integer.parse(String.last(move_to))
    if color == "white" do
      "#{String.first(move_to)}#{y_point - 1}"
    else
      "#{String.first(move_to)}#{y_point + 1}"
    end
  end

  defp check_half_move(_half_move, %Figure{type: type}, is_attack) when type == "p" or is_attack do
    0
  end

  defp check_half_move(half_move, _figure, _is_attack) do
    half_move + 1
  end

  defp add_full_move(full_move, active) do
    if active == "b" do
      full_move + 1
    else
      full_move
    end
  end

  defp calc_position_from_squares(squares) do
    Enum.map(@y_fields, fn y ->
      check_line(@x_fields, squares, y, "", 0)
    end)
    |> Enum.join("/")
  end

  defp parse(result) when result == :error do
    raise "There is no valid integer for moves"
  end

  defp parse({result, _}) do
    result
  end

  defp check_line(_fields, _squares, _y_line, _acc, spaces) when spaces == 8 do
    "8"
  end

  defp check_line(fields, _squares, _y_line, acc, _spaces) when fields == [] do
    acc
  end

  defp check_line([head | tail], squares, y_line, acc, spaces) do
    result = check_figure(squares[:"#{head}#{y_line}"])
    cond do
      result == 1 && tail == [] ->
        acc <> "#{spaces + 1}"
      result == 1 ->
        check_line(tail, squares, y_line, acc, spaces + 1)
      spaces != 0 ->
        check_line(tail, squares, y_line, acc <> "#{spaces}#{result}", 0)
      true ->
        check_line(tail, squares, y_line, acc <> result, 0)
    end
  end  

  defp check_figure(figure) when figure == nil do
    1
  end

  defp check_figure(%Figure{color: color, type: type}) do
    case color do
      "white" ->
        String.first(type)
        |> String.capitalize
      "black" -> String.first(type)
    end
  end
end
