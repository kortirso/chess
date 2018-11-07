defmodule Chess.Move.Destination do
  @moduledoc """
  Module for checking destination point for figure
  """
  defmacro __using__(_opts) do
    quote do
      alias Chess.{Figure}

      defp check_destination(_squares, move_from, move_to, %Figure{color: end_color}, %Figure{color: color}) when end_color == color do
        raise "Square #{move_to} is under control of your figure"
      end

      defp check_destination(squares, move_from, move_to, figure_at_the_end, %Figure{color: color, type: type}) when type == "p" do
        [x_route, _y_route] = calc_route(String.split(move_from, "", trim: true), String.split(move_to, "", trim: true))
        cond do
          x_route == 0 && figure_at_the_end != nil ->
            raise "There are barrier for pion at the and of move"
          x_route != 0 && figure_at_the_end == nil ->
            raise "Pion must attack for diagonal move"
          true ->
            squares = Keyword.delete(squares, :"#{move_from}")
            squares = Keyword.put(squares, :"#{move_to}", %Figure{color: color, type: type})
            {:ok, squares}
        end
      end

      defp check_destination(squares, move_from, move_to, _figure_at_the_end, figure) do
        squares = Keyword.delete(squares, :"#{move_from}")
        squares = Keyword.put(squares, :"#{move_to}", figure)
        {:ok, squares}
      end
    end
  end
end
