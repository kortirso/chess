defmodule Chess.Move.Parse do
  @moduledoc """
  Module for parsing moves
  """
  defmacro __using__(_opts) do
    quote do
      defp check_move_format(move) do
        move
        |> check_move_as_string
        |> check_move_squares
      end

      defp check_move_as_string(move) do
        cond do
          !is_binary(move) ->
            raise "Invalid move format"
          String.length(move) != 5 ->
            raise "Invalid move format"
          true ->
            move
        end
      end

      defp check_move_squares(move) do
        splitted_move = String.split(move, "", trim: true)
        cond do
          Enum.find(@x_fields, fn x -> x == Enum.at(splitted_move, 0) end) == nil ->
            raise "There is no such square on the board"
          Enum.find(@y_fields, fn x -> x == Enum.at(splitted_move, 1) end) == nil ->
            raise "There is no such square on the board"
          Enum.find(@x_fields, fn x -> x == Enum.at(splitted_move, 3) end) == nil ->
            raise "There is no such square on the board"
          Enum.find(@y_fields, fn x -> x == Enum.at(splitted_move, 4) end) == nil ->
            raise "There is no such square on the board"
          true ->
            move
        end
      end
    end
  end
end
