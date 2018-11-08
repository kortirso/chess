defmodule ChessTest do
  use ExUnit.Case

  alias Chess.{Game}

  test "Can create game" do
    assert %Game{} = Game.new()
  end
  
  test "Can play moves" do
    game = Game.new()

    assert {:ok, game} = Game.play(game, "e2-e4")
    assert {:ok, %Game{}} = Game.play(game, "c7-c5")
  end
end
