defmodule Chess.PositionTest do
  use ExUnit.Case

  alias Chess.{Game, Position}

  setup_all do
    {:ok, game: Game.new()}
  end

  test "creates default FEN-notation" do
    assert "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" = Position.new
  end

  test "creates new FEN-notation", state do
    {:ok, %Game{squares: squares, current_fen: current_fen}} = Game.play(state[:game], "e2-e4")

    assert "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR" = Position.new(squares, current_fen)
  end
end
