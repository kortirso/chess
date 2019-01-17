defmodule Chess.Move.Destination do
  @moduledoc """
  Module for checking destination point for figure
  """

  alias Chess.{Figure, Move}

  defmacro __using__(_opts) do
    quote do
      # if destination square has own figure
      defp do_check_destination(_, %Move{to: to, figure: %Figure{color: color}}, %Figure{color: end_color}, _)
        when end_color == color,
        do: {:error, "Square #{to} is under control of your figure"}

      # different rules for pions
      defp do_check_destination(squares, %Move{from: from, to: to, figure: %Figure{color: color, type: "p"}} = move, figure_at_the_end, en_passant) do
        [x_route, _] = calc_route(String.split(from, "", trim: true), String.split(to, "", trim: true))

        cond do
          x_route == 0 && figure_at_the_end != nil ->
            {:error, "There are barrier for pion at the and of move"}

          x_route != 0 && figure_at_the_end == nil && to == en_passant ->
            beated_pion = pion_beated_en_passant(color, to)
            squares = Keyword.delete(squares, :"#{beated_pion}")
            [
              true,
              false,
              Keyword.put(squares, :"#{to}", move.figure)
            ]

          x_route != 0 && figure_at_the_end == nil ->
            {:error, "Pion must attack for diagonal move"}

          true ->
            squares = Keyword.delete(squares, :"#{from}")
            [
              is_attack(squares[:"#{to}"]),
              false,
              Keyword.put(squares, :"#{to}", move.figure)
            ]
        end
      end

      # different rules for castling
      defp do_check_destination(squares, %Move{from: from, to: to, figure: %Figure{color: color, type: "k"}, distance: 2} = move, _, _) do
        squares = Keyword.delete(squares, :"#{from}")
        squares = Keyword.put(squares, :"#{to}", move.figure)

        cond do
          to == "g1" ->
            squares = Keyword.put(squares, :f1, squares[:h1])
            [false, "KQ", Keyword.delete(squares, :h1)]

          to == "c1" ->
            squares = Keyword.put(squares, :d1, squares[:a1])
            [false, "KQ", Keyword.delete(squares, :a1)]

          to == "g8" ->
            squares = Keyword.put(squares, :f8, squares[:h8])
            [false, "kq", Keyword.delete(squares, :h8)]

          to == "c8" ->
            squares = Keyword.put(squares, :d8, squares[:a8])
            [false, "kq", Keyword.delete(squares, :a8)]

          true ->
            [false, false, squares]
        end
      end

      # other rules
      defp do_check_destination(squares, %Move{from: from, to: to, figure: figure}, _, _) do
        squares = Keyword.delete(squares, :"#{from}")

        [
          is_attack(squares[:"#{to}"]),
          check_castling_figure(from),
          Keyword.put(squares, :"#{to}", figure)
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
