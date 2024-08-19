defmodule Chess.PromotionTest do
  use ExUnit.Case

  alias Chess.Game

  test "promotion to queen - 1" do
    game = Game.new("r3qbnr/ppP2k1p/8/8/8/6p1/PP5P/RNBQ1KpR w - - 0 18")
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(game, "c7-c8")

    assert current_fen == "r1Q1qbnr/pp3k1p/8/8/8/6p1/PP5P/RNBQ1KpR b - - 0 18"
  end

  test "promotion to queen - 2" do
    game = Game.new("rnPq1bnr/ppP2kpp/8/8/8/8/PPP1K2P/RNBQ1ppR w - - 0 12")
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(game, "c7-b8", "q")

    assert current_fen == "rQPq1bnr/pp3kpp/8/8/8/8/PPP1K2P/RNBQ1ppR b - - 0 12"
  end

  test "promotion to queen - 3" do
    game = Game.new("rnPq1bnr/ppP2kpp/8/8/8/8/PPP1K2P/RNBQ1ppR w - - 0 12")
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(game, "c7-d8", "q")

    assert current_fen == "rnPQ1bnr/pp3kpp/8/8/8/8/PPP1K2P/RNBQ1ppR b - - 0 12"
  end

  test "promotion to knight - 1" do
    game = Game.new("r3qbnr/ppP2k1p/8/8/8/6p1/PP5P/RNBQ1KpR w - - 0 18")
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(game, "c7-c8", "n")

    assert current_fen == "r1N1qbnr/pp3k1p/8/8/8/6p1/PP5P/RNBQ1KpR b - - 0 18"
  end

  test "promotion to knight - 2" do
    game = Game.new("rnPq1bnr/ppP2kpp/8/8/8/8/PPP1K2P/RNBQ1ppR w - - 0 12")
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(game, "c7-b8", "n")

    assert current_fen == "rNPq1bnr/pp3kpp/8/8/8/8/PPP1K2P/RNBQ1ppR b - - 0 12"
  end

  test "promotion to knight - 3" do
    game = Game.new("rnPq1bnr/ppP2kpp/8/8/8/8/PPP1K2P/RNBQ1ppR w - - 0 12")
    {:ok, %Game{squares: _, current_fen: current_fen, status: _, check: _}} = Game.play(game, "c7-d8", "n")

    assert current_fen == "rnPN1bnr/pp3kpp/8/8/8/8/PPP1K2P/RNBQ1ppR b - - 0 12"
  end

end
