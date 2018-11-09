defmodule Chess.Position.Parse do
  @moduledoc """
  Module for parsing fen-notation
  """
  defmacro __using__(_opts) do
    quote do
      defp check_fen_format(fen) do
        fen
        |> check_fen_as_string
        |> check_fen_data
      end

      defp check_fen_as_string(fen) do
        cond do
          !is_binary(fen) ->
            raise "Invalid fen format"
          true ->
            fen
        end
      end

      defp check_fen_data(fen) do
        splitted_fen = String.split(fen, " ", trim: true)
        cond do
          length(String.split(Enum.at(splitted_fen, 0), "/", trim: true)) != 8 ->
            raise "Position must contain 8 blocks for each line"
          Enum.find(["w", "b"], fn x -> x == Enum.at(splitted_fen, 1) end) == nil ->
            raise "Active side must be w or b"
          true ->
            splitted_fen
        end
      end
    end
  end
end
