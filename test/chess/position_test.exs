defmodule Chess.PositionTest do
  use ExUnit.Case

  alias Chess.{Position}

  test "creates default FEN-notation" do
    assert "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" = Position.new
  end
end
