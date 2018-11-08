defmodule ChessTest do
  use ExUnit.Case

  alias Chess.{Game}

  setup_all do
    {:ok, game: Game.new()}
  end

  test "Can create game", state do
    assert %Game{} = state[:game]
  end
  
  test "Can play moves", state do
    assert {:ok, game} = Game.play(state[:game], "e2-e4")
    assert {:ok, %Game{}} = Game.play(game, "c7-c5")
  end
end
