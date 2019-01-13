defmodule Chess.Move.Destination do
  @moduledoc """
  Module for checking destination point for figure
  """

  alias Chess.Figure

  defmacro __using__(_opts) do
    quote do
      # if destination square has own figure
      defp do_check_destination(_, [_, move_to], %Figure{color: end_color}, %Figure{color: color}, _, _)
        when end_color == color,
        do: {:error, "Square #{move_to} is under control of your figure"}

      # different rules for pions
      defp do_check_destination(squares, [move_from, move_to], figure_at_the_end, %Figure{color: color, type: "p"} = figure, en_passant, _) do
        [x_route, _] = calc_route(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))

        cond do
          x_route == 0 && figure_at_the_end != nil ->
            {:error, "There are barrier for pion at the and of move"}

          x_route != 0 && figure_at_the_end == nil && move_to == en_passant ->
            beated_pion = pion_beated_en_passant(color, move_to)
            squares = Keyword.delete(squares, :"#{beated_pion}")
            [
              true,
              false,
              Keyword.put(squares, :"#{move_to}", figure)
            ]

          x_route != 0 && figure_at_the_end == nil ->
            {:error, "Pion must attack for diagonal move"}

          true ->
            squares = Keyword.delete(squares, :"#{move_from}")
            [
              is_attack(squares[:"#{move_to}"]),
              false,
              Keyword.put(squares, :"#{move_to}", figure)
            ]
        end
      end

      # different rules for castling
      defp do_check_destination(squares, [move_from, move_to], _, %Figure{color: color, type: "k"} = figure, _, 2) do
        squares = Keyword.delete(squares, :"#{move_from}")
        squares = Keyword.put(squares, :"#{move_to}", figure)

        cond do
          move_to == "g1" ->
            squares = Keyword.put(squares, :f1, squares[:h1])
            [false, "KQ", Keyword.delete(squares, :h1)]

          move_to == "c1" ->
            squares = Keyword.put(squares, :d1, squares[:a1])
            [false, "KQ", Keyword.delete(squares, :a1)]

          move_to == "g8" ->
            squares = Keyword.put(squares, :f8, squares[:h8])
            [false, "kq", Keyword.delete(squares, :h8)]

          move_to == "c8" ->
            squares = Keyword.put(squares, :d8, squares[:a8])
            [false, "kq", Keyword.delete(squares, :a8)]

          true ->
            [false, false, squares]
        end
      end

      # other rules
      defp do_check_destination(squares, [move_from, move_to], _, figure, _, _) do
        squares = Keyword.delete(squares, :"#{move_from}")

        [
          is_attack(squares[:"#{move_to}"]),
          check_castling_figure(move_from),
          Keyword.put(squares, :"#{move_to}", figure)
        ]
      end

      defp pion_beated_en_passant(color, move_to) do
        y_point = String.last(move_to)
        y_point = Enum.find_index(@y_fields, fn y -> y == y_point end)
        coefficient = if color == "white", do: -1, else: 1
        String.first(move_to) <> Enum.at(@y_fields, y_point + coefficient)
      end

      defp is_attack(nil), do: false
      defp is_attack(_), do: true

      defp check_castling_figure(move_from) do
        case move_from do
          "a1" -> "Q"
          "e1" -> ["K", "Q"]
          "h1" -> "K"
          "a8" -> "q"
          "e8" -> ["k", "q"]
          "h8" -> "k"
          _ -> false
        end
      end
    end
  end
end
