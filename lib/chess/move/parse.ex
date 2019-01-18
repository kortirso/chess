defmodule Chess.Move.Parse do
  @moduledoc """
  Module for parsing moves
  """

  alias Chess.Game

  defmacro __using__(_opts) do
    quote do
      defp do_parse_move(%Game{status: "check", check: check}, move, active)
        when check != active and (move == "0-0" or move == "0-0-0"),
        do: {:error, "Your king is under attack, castling is forbidden"}

      defp do_parse_move(_, move, active) when move == "0-0" or move == "0-0-0" do
        [
          define_kings_from(active),
          define_kings_to(active, move)
        ]
      end

      defp do_parse_move(_, move, _) do
        result = check_move_format(move)
        cond do
          is_binary(result) -> String.split(result, "-")
          true -> result
        end
      end

      defp define_kings_from("w"), do: "e1"
      defp define_kings_from(_), do: "e8"

      defp define_kings_to("w", move) do
        if move == "0-0", do: "g1", else: "c1"
      end

      defp define_kings_to(_, move) do
        if move == "0-0", do: "g8", else: "c8"
      end

      defp check_move_format(move) do
        cond do
          String.length(move) != 5 -> {:error, "Invalid move format"}
          true -> check_move_squares(move)
        end
      end

      defp check_move_squares(move) do
        splitted_move = String.split(move, "", trim: true)

        cond do
          Enum.find(@x_fields, fn x -> x == Enum.at(splitted_move, 0) end) == nil ->
            {:error, "There is no such square on the board"}

          Enum.find(@y_fields, fn x -> x == Enum.at(splitted_move, 1) end) == nil ->
            {:error, "There is no such square on the board"}

          Enum.find(@x_fields, fn x -> x == Enum.at(splitted_move, 3) end) == nil ->
            {:error, "There is no such square on the board"}

          Enum.find(@y_fields, fn x -> x == Enum.at(splitted_move, 4) end) == nil ->
            {:error, "There is no such square on the board"}

          true ->
            move
        end
      end
    end
  end
end
