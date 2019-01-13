defmodule Chess.Position do
  @moduledoc """
  Position module
  """

  @x_lines ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_lines [8, 7, 6, 5, 4, 3, 2, 1]

  alias Chess.{Figure, Position}

  defstruct position: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
            active: "w",
            castling: "KQkq",
            en_passant: "-",
            half_move: 0,
            full_move: 1

  @doc """
  Start position on the board in FEN-notation

  ## Examples

      iex> Chess.Position.new()
      %Chess.Position{}

  """
  def new, do: %Position{}

  @doc """
  Calculate current position from FEN-notation

  ## Examples

      iex> Chess.Position.new("FEN")
      %Chess.Position{}

      iex> Chess.Position.new("r")
      {:error, "Position must contain 8 blocks for each line"}

  """
  def new(current_fen) when is_binary(current_fen) do
    case parse_fen(current_fen) do
      # create position
      {:ok, fen} ->
        %Position{
          position: Enum.at(fen, 0),
          active: Enum.at(fen, 1),
          castling: Enum.at(fen, 2),
          en_passant: Enum.at(fen, 3),
          half_move: fen |> Enum.at(4) |> Integer.parse() |> parse(),
          full_move: fen |> Enum.at(5) |> Integer.parse() |> parse()
        }

      # return error
      result ->
        result
    end
  end

  defp parse_fen(fen) do
    splitted_fen = String.split(fen, " ", trim: true)

    cond do
      length(String.split(Enum.at(splitted_fen, 0), "/", trim: true)) != 8 ->
        {:error, "Position must contain 8 blocks for each line"}

      Enum.find(["w", "b"], fn x -> x == Enum.at(splitted_fen, 1) end) == nil ->
        {:error, "Active side must be w or b" }

      true ->
        {:ok, splitted_fen}
    end
  end

  @doc """
  Calculate FEN-notation for current board

  ## Examples

      iex> Chess.Position.new(squares, %Chess.Position{}, figure, distance, move_to, as_attack, is_castling)
      %Chess.Position{}

  """
  def new(
        squares,
        %Position{active: active, castling: castling, half_move: half_move, full_move: full_move},
        %Figure{} = figure,
        distance,
        move_to,
        is_attack,
        is_castling
      ) do
    position = calc_position_from_squares(squares)

    %Position{
      position: position,
      active: change_active_player(active),
      castling: check_castling(castling, is_castling),
      en_passant: check_en_passant(figure, distance, move_to),
      half_move: check_half_move(half_move, figure, is_attack),
      full_move: add_full_move(full_move, active)
    }
  end

  @doc """
  Calculate current position to FEN-notation

  ## Examples

      iex> Chess.Position.to_fen(%Chess.Position{})
      ""

  """
  def to_fen(%Position{} = position) do
    [
      position.position,
      position.active,
      position.castling,
      position.en_passant,
      position.half_move,
      position.full_move
    ]
    |> Enum.join(" ")
  end

  defp change_active_player("w"), do: "b"
  defp change_active_player(_), do: "w"

  defp check_castling(castling, false), do: castling

  defp check_castling(castling, [is_king, is_queen]) do
    castling = check_castling(castling, is_king)
    check_castling(castling, is_queen)
  end

  defp check_castling(castling, is_castling) do
    castling = String.replace(castling, is_castling, "")
    if castling == "", do: "-", else: castling
  end

  defp check_en_passant(%Figure{type: type}, distance, _) when type != "p" or distance != 2 do
    "-"
  end

  defp check_en_passant(%Figure{color: color}, _, move_to) do
    {y_point, _} = move_to |> String.last() |> Integer.parse()

    if color == "white" do
      "#{String.first(move_to)}#{y_point - 1}"
    else
      "#{String.first(move_to)}#{y_point + 1}"
    end
  end

  defp check_half_move(_, %Figure{type: type}, is_attack) when type == "p" or is_attack, do: 0
  defp check_half_move(half_move, _, _), do: half_move + 1

  defp add_full_move(full_move, "b"), do: full_move + 1
  defp add_full_move(full_move, _), do: full_move

  defp calc_position_from_squares(squares) do
    @y_lines
    |> Enum.map(fn y -> check_line(@x_lines, squares, y, "", 0) end)
    |> Enum.join("/")
  end

  defp parse({result, _}), do: result

  defp check_line(_, _, _, _, 8), do: "8"
  defp check_line([], _, _, acc, _), do: acc

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

  defp check_figure(nil), do: 1

  defp check_figure(%Figure{color: color, type: type}) do
    case color do
      "white" ->
        String.first(type)
        |> String.capitalize

      "black" ->
        String.first(type)
    end
  end
end
