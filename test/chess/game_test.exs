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

    assert %Game{status: :completed, check: "b"} = game

    {:error, message} = Game.play(game, "a2-a3")

    assert message == "The game is over"
  end

  test "scholar's mate", state do
    {:ok, game} = Game.play(state[:game], "e2-e4")
    {:ok, game} = Game.play(game, "e7-e5")
    {:ok, game} = Game.play(game, "f1-c4")
    {:ok, game} = Game.play(game, "b8-c6")
    {:ok, game} = Game.play(game, "d1-h5")
    {:ok, game} = Game.play(game, "g8-f6")
    {:ok, game} = Game.play(game, "h5-f7")

    assert %Game{status: :completed, check: "w"} = game
  end

  test "different moves", state do
    {:ok, game} = Game.play(state[:game], "e2-e4")
    {:ok, game} = Game.play(game, "e7-e5")
    {:ok, game} = Game.play(game, "d1-h5")
    {:ok, game} = Game.play(game, "a7-a5")
    {:ok, game} = Game.play(game, "h5-e5")

    assert %Game{status: :check, check: "w"} = game

    {:error, message} = Game.play(game, "b7-b5")

    assert message == "You must avoid check"
  end
end
