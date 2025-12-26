defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Game

  setup_all do
    {:ok, game: Game.new()}
  end

  test "create game", state do
    assert %Game{} = state[:game]
  end

  test "create game from FEN-notation" do
    %Game{squares: squares, current_fen: current_fen, status: status, check: check} = Game.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

    assert length(squares) == 32
    assert current_fen == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    assert status == :playing
    assert check == nil
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

    assert message == "This move is invalid, king is under attack"
  end

  test "make_virtual_move handles error tuple during check validation" do
    # This position triggers a MatchError in make_virtual_move/4 if error tuples
    # from Game.play are not handled properly during check validation.
    # Previously crashed with: ** (MatchError) no match of right hand side value:
    # {:error, "There is barrier at square e1"}
    #
    # The bug occurred during virtual move simulation when checking if a piece
    # could block or capture an attacker. The fix handles {:error, _} tuples
    # gracefully instead of crashing.
    fen = "3rk2r/ppp1bppp/2n5/8/6b1/5q2/PPP2P1P/R2RK3 b k - 11 18"
    game = Game.new(fen)

    # This move should succeed without crashing - it's actually checkmate
    {:ok, game} = Game.play(game, "f3-h1")

    assert %Game{status: :completed, check: "b"} = game
  end

  test "Kasparov-Topalov, 1999", state do
    {:ok, game} = Game.play(state[:game], "e2-e4")
    {:ok, game} = Game.play(game, "d7-d6")
    {:ok, game} = Game.play(game, "d2-d4")
    {:ok, game} = Game.play(game, "g8-f6")
    {:ok, game} = Game.play(game, "b1-c3")
    {:ok, game} = Game.play(game, "g7-g6")
    {:ok, game} = Game.play(game, "c1-e3")
    {:ok, game} = Game.play(game, "f8-g7")
    {:ok, game} = Game.play(game, "d1-d2")
    {:ok, game} = Game.play(game, "c7-c6")
    {:ok, game} = Game.play(game, "f2-f3")
    {:ok, game} = Game.play(game, "b7-b5")
    {:ok, game} = Game.play(game, "g1-e2")
    {:ok, game} = Game.play(game, "b8-d7")
    {:ok, game} = Game.play(game, "e3-h6")
    {:ok, game} = Game.play(game, "g7-h6")
    {:ok, game} = Game.play(game, "d2-h6")
    {:ok, game} = Game.play(game, "c8-b7")
    {:ok, game} = Game.play(game, "a2-a3")
    {:ok, game} = Game.play(game, "e7-e5")
    {:ok, game} = Game.play(game, "0-0-0")
    {:ok, game} = Game.play(game, "d8-e7")
    {:ok, game} = Game.play(game, "c1-b1")
    {:ok, game} = Game.play(game, "a7-a6")
    {:ok, game} = Game.play(game, "e2-c1")
    {:ok, game} = Game.play(game, "0-0-0")
    {:ok, game} = Game.play(game, "c1-b3")
    {:ok, game} = Game.play(game, "e5-d4")
    {:ok, game} = Game.play(game, "d1-d4")
    {:ok, game} = Game.play(game, "c6-c5")
    {:ok, game} = Game.play(game, "d4-d1")
    {:ok, game} = Game.play(game, "d7-b6")
    {:ok, game} = Game.play(game, "g2-g3")
    {:ok, game} = Game.play(game, "c8-b8")
    {:ok, game} = Game.play(game, "b3-a5")
    {:ok, game} = Game.play(game, "b7-a8")
    {:ok, game} = Game.play(game, "f1-h3")
    {:ok, game} = Game.play(game, "d6-d5")
    {:ok, game} = Game.play(game, "h6-f4")
    {:ok, game} = Game.play(game, "b8-a7")
    {:ok, game} = Game.play(game, "h1-e1")
    {:ok, game} = Game.play(game, "d5-d4")
    {:ok, game} = Game.play(game, "c3-d5")
    {:ok, game} = Game.play(game, "b6-d5")
    {:ok, game} = Game.play(game, "e4-d5")
    {:ok, game} = Game.play(game, "e7-d6")
    {:ok, game} = Game.play(game, "d1-d4")
    {:ok, game} = Game.play(game, "c5-d4")
    {:ok, game} = Game.play(game, "e1-e7")
    {:ok, game} = Game.play(game, "a7-b6")
    {:ok, game} = Game.play(game, "f4-d4")
    {:ok, game} = Game.play(game, "b6-a5")
    {:ok, game} = Game.play(game, "b2-b4")
    {:ok, game} = Game.play(game, "a5-a4")
    {:ok, game} = Game.play(game, "d4-c3")
    {:ok, game} = Game.play(game, "d6-d5")
    {:ok, game} = Game.play(game, "e7-a7")
    {:ok, game} = Game.play(game, "a8-b7")
    {:ok, game} = Game.play(game, "a7-b7")
    {:ok, game} = Game.play(game, "d5-c4")
    {:ok, game} = Game.play(game, "c3-f6")
    {:ok, game} = Game.play(game, "a4-a3")
    {:ok, game} = Game.play(game, "f6-a6")
    {:ok, game} = Game.play(game, "a3-b4")
    {:ok, game} = Game.play(game, "c2-c3")
    {:ok, game} = Game.play(game, "b4-c3")
    {:ok, game} = Game.play(game, "a6-a1")
    {:ok, game} = Game.play(game, "c3-d2")
    {:ok, game} = Game.play(game, "a1-b2")
    {:ok, game} = Game.play(game, "d2-d1")
    {:ok, game} = Game.play(game, "h3-f1")
    {:ok, game} = Game.play(game, "d8-d2")
    {:ok, game} = Game.play(game, "b7-d7")
    {:ok, game} = Game.play(game, "d2-d7")
    {:ok, game} = Game.play(game, "f1-c4")
    {:ok, game} = Game.play(game, "b5-c4")
    {:ok, game} = Game.play(game, "b2-h8")
    {:ok, game} = Game.play(game, "d7-d3")
    {:ok, game} = Game.play(game, "h8-a8")
    {:ok, game} = Game.play(game, "c4-c3")
    {:ok, game} = Game.play(game, "a8-a4")
    {:ok, game} = Game.play(game, "d1-e1")
    {:ok, game} = Game.play(game, "f3-f4")
    {:ok, game} = Game.play(game, "f7-f5")
    {:ok, game} = Game.play(game, "b1-c1")
    {:ok, game} = Game.play(game, "d3-d2")
    {:ok, game} = Game.play(game, "a4-a7")

    # end of the real game
    assert %Game{status: :playing, check: nil} = game

    # additional moves not from the real game
    {:ok, game} = Game.play(game, "c3-c2")
    {:ok, game} = Game.play(game, "c1-b2")
    {:ok, game} = Game.play(game, "c2-c1", "n")

    assert %Game{status: :check, check: "b"} = game
  end
end
