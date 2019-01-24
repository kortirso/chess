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

        squares
        |> define_active_figures(opponent(active))
        |> define_attackers(king_square)
        |> length()
        |> case do
          0 -> check_attack(squares, active)
          _ -> [:check, opponent(active)]
        end
      end

      defp check_attack(squares, active) do
        {
          opponent_king_square,
          _
        } = Enum.find(squares, fn {_, %Figure{color: color, type: type}} -> type == "k" && color != active end)

        squares
        |> define_active_figures(active)
        |> define_attackers(opponent_king_square)
        |> length()
        |> case do
          0 -> [:playing, nil]
          _ -> [:check, active]
        end
      end
    end
  end
end
