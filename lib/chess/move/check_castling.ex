defmodule Chess.Move.CheckCastling do
  @moduledoc """
  Module for checking castling
  """

  defmacro __using__(_opts) do
    quote do
      defp do_check_castling(move, game, current_position) do
        king_square = find_square(move.to)
        active_figures = define_active_figures(game.squares, opponent(current_position.active))
        attackers = define_attackers(active_figures, find_square(move.to))

        case length(attackers) do
          0 -> {:ok}
          _ -> {:error, "Castling is forbidden, square #{king_square} is under attack"}
        end
      end

      defp find_square("g1"), do: :f1
      defp find_square("g8"), do: :f8
      defp find_square("c1"), do: :d1
      defp find_square("c8"), do: :d8
    end
  end
end
