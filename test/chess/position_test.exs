defmodule Chess.PositionTest do
  use ExUnit.Case

  alias Chess.{Game, Position, Figure}

  test "create position" do
    %Position{position: position, active: active, castling: castling, en_passant: en_passant, half_move: half_move, full_move: full_move} = Position.new

    assert position == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    assert active == "w"
    assert castling == "KQkq"
    assert en_passant == "-"
    assert half_move == 0
    assert full_move == 1
  end

  test "create position from FEN-notation" do
    %Position{position: position, active: active, castling: castling, en_passant: en_passant, half_move: half_move, full_move: full_move} = Position.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

    assert position == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    assert active == "w"
    assert castling == "KQkq"
    assert en_passant == "-"
    assert half_move == 0
    assert full_move == 1
  end

  test "create FEN-notation from position" do
    fen = Position.new() |> Position.to_fen()

    assert fen == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  end

  test "calculate FEN-notation after move" do
    game = Game.new()
    squares = game.squares

    squares = Keyword.delete(squares, :e2)
    squares = Keyword.put(squares, :e3, %Figure{color: "white", type: "p"})
    %Position{position: position, active: active, castling: castling, en_passant: en_passant, half_move: half_move, full_move: full_move} = Position.new(squares, Position.new(), %Figure{color: "white", type: "p"}, 1, "e3", false, false)

    assert position == "rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR"
    assert active == "b"
    assert castling == "KQkq"
    assert en_passant == "-"
    assert half_move == 0
    assert full_move == 1
  end
end
