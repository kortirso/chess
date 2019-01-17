defmodule Chess.Move.FindFigure do
  @moduledoc """
  Module for finding figure in squares
  """

  alias Chess.Figure

  defmacro __using__(_opts) do
    quote do
      defp do_find_figure(nil, _), do: {:error, "Square does not have figure for move"}

      defp do_find_figure(%Figure{color: color} = figure, active_player) do
        if String.first(color) != active_player, do: {:error, "This is not move of #{color} player"}, else: figure
      end
    end
  end
end
