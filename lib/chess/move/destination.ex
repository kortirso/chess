defmodule Chess.Move.Destination do
  @moduledoc """
  Module for checking destination point for figure
  """
  defmacro __using__(_opts) do
    quote do
      alias Chess.{Figure}

      defp check_destination(_squares, move_from, move_to, %Figure{color: end_color}, %Figure{color: color}, _en_passant, _distance) when end_color == color do
        raise "Square #{move_to} is under control of your figure"
      end

      defp check_destination(squares, move_from, move_to, figure_at_the_end, %Figure{color: color, type: type}, en_passant, _distance) when type == "p" do
        [x_route, _y_route] = calc_route(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))
        cond do
          x_route == 0 && figure_at_the_end != nil ->
            raise "There are barrier for pion at the and of move"
          x_route != 0 && figure_at_the_end == nil && move_to == en_passant ->
            beated_pion = pion_beated_en_passant(color, move_to)
            squares = Keyword.delete(squares, :"#{beated_pion}")
            [true, nil, Keyword.put(squares, :"#{move_to}", %Figure{color: color, type: type})]
          x_route != 0 && figure_at_the_end == nil ->
            raise "Pion must attack for diagonal move"
          true ->
            squares = Keyword.delete(squares, :"#{move_from}")
            [is_attack(squares[:"#{move_to}"]), nil, Keyword.put(squares, :"#{move_to}", %Figure{color: color, type: type})]
        end
      end

      defp check_destination(squares, move_from, move_to, _figure_at_the_end, %Figure{color: color, type: type}, _en_passant, distance) when type == "k" and distance == 2 do
        squares = Keyword.delete(squares, :"#{move_from}")
        squares = Keyword.put(squares, :"#{move_to}", %Figure{color: color, type: type})
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
            [false, nil, squares]
        end
      end

      defp check_destination(squares, move_from, move_to, _figure_at_the_end, figure, _en_passant, _distance) do
        squares = Keyword.delete(squares, :"#{move_from}")
        [is_attack(squares[:"#{move_to}"]), nil, Keyword.put(squares, :"#{move_to}", figure)]
      end

      defp pion_beated_en_passant(color, move_to) do
        y_point = String.last(move_to)
        y_point = Enum.find_index(@y_fields, fn y -> y == y_point end)
        if color == "white" do
          String.first(move_to) <> Enum.at(@y_fields, y_point - 1)
        else
          String.first(move_to) <> Enum.at(@y_fields, y_point + 1)
        end
      end

      defp is_attack(figure) when figure == nil do
        false
      end

      defp is_attack(_figure) do
        true
      end
    end
  end
end
