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

    assert %Game{status: :completed, check: "mat"} = game
  end

  test "scholar's mate", state do
    {:ok, game} = Game.play(state[:game], "e2-e4")
    {:ok, game} = Game.play(game, "e7-e5")
    {:ok, game} = Game.play(game, "f1-c4")
    {:ok, game} = Game.play(game, "b8-c6")
    {:ok, game} = Game.play(game, "d1-h5")
    {:ok, game} = Game.play(game, "g8-f6")
    {:ok, game} = Game.play(game, "h5-f7")

    assert %Game{status: :completed, check: "mat"} = game
  end
end
