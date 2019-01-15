defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Game

  setup_all do
    {:ok, game: Game.new()}
  end

  test "create game", state do
    assert %Game{} = state[:game]
  end

  test "fool's mate", state do
    {:ok, game} = Game.play(state[:game], "f2-f3")
    {:ok, game} = Game.play(game, "e7-e6")
    {:ok, game} = Game.play(game, "g2-g4")
    {:ok, game} = Game.play(game, "d8-h4")

    IO.inspect game
  end
end
