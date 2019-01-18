defmodule Chess.Game.CheckStatus do
  @moduledoc """
  Module for checking game status
  """

  alias Chess.{Figure}

  defmacro __using__(_opts) do
    quote do
      defp check_avoiding(squares, active) do
        {
          king_square,
          _
        } = Enum.find(squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && color == active end)
        active_figures = define_active_figures(squares, opponent(active))
        attackers = define_attackers(active_figures, king_square)

        case length(attackers) do
          0 -> check_attack(squares, active)
          _ -> [:check, opponent(active)]
        end
      end

      defp check_attack(squares, active) do
        {
          opponent_king_square,
          _
        } = Enum.find(squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && color != active end)
        active_figures = define_active_figures(squares, active)
        attackers = define_attackers(active_figures, opponent_king_square)

        case length(attackers) do
          0 -> [:playing, nil]
          _ -> [:check, active]
        end
      end
    end
  end
end
