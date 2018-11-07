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

      defp check_destination(squares, move_from, move_to, _figure_at_the_end, figure) do
        squares = Keyword.delete(squares, :"#{move_from}")
        squares = Keyword.put(squares, :"#{move_to}", figure)
        {:ok, squares}
      end
    end
  end
end
