defmodule Chess.EnPassantTest do
  use ExUnit.Case

  alias Chess.Game

  setup_all do
    game = Game.new("rnbqkbnr/p1p1pppp/8/3pP3/1p6/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 1")
    {:ok, game: game}
  end

  test "valid en passant", state do
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(state[:game], "e5-d6")

    assert current_fen == "rnbqkbnr/p1p1pppp/3P4/8/1p6/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
  end

  test "invalid en passant", state do
    {:error, message} = Game.play(state[:game], "e5-f6")

    assert message == "Pion must attack for diagonal move"
  end
end
