defmodule Chess.PositionTest do
  use ExUnit.Case

  alias Chess.{Game, Position}

  setup_all do
    {:ok, game: Game.new()}
  end

  test "creates default FEN-notation" do
    position = Position.new

    assert "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" = Position.to_fen(position)
  end

  test "creates new FEN-notation after move", state do
    {:ok, game} = Game.play(state[:game], "e2-e4")

    assert "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1" = game.current_fen
  end
end
