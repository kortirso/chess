defmodule Chess.Move.Destination do
  @moduledoc """
  Module for checking destination point for figure
  """
  defmacro __using__(_opts) do
    quote do
      alias Chess.{Figure}

      defp check_destination(_squares, move_from, move_to, %Figure{color: end_color}, %Figure{color: color}, _en_passant) when end_color == color do
        raise "Square #{move_to} is under control of your figure"
      end

      defp check_destination(squares, move_from, move_to, figure_at_the_end, %Figure{color: color, type: type}, en_passant) when type == "p" do
        [x_route, _y_route] = calc_route(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))
        cond do
          x_route == 0 && figure_at_the_end != nil ->
            raise "There are barrier for pion at the and of move"
          x_route != 0 && figure_at_the_end == nil && move_to == en_passant ->
            beated_pion = pion_beated_en_passant(color, move_to)
            squares = Keyword.delete(squares, :"#{beated_pion}")
            Keyword.put(squares, :"#{move_to}", %Figure{color: color, type: type})
          x_route != 0 && figure_at_the_end == nil ->
            raise "Pion must attack for diagonal move"
          true ->
            squares = Keyword.delete(squares, :"#{move_from}")
            Keyword.put(squares, :"#{move_to}", %Figure{color: color, type: type})
        end
      end

      defp check_destination(squares, move_from, move_to, _figure_at_the_end, figure, _en_passant) do
        squares = Keyword.delete(squares, :"#{move_from}")
        Keyword.put(squares, :"#{move_to}", figure)
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
    end
  end
end
