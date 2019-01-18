defmodule Chess.SquareTest do
  use ExUnit.Case

  alias Chess.{Square, Position}

  test "create squares for starting game" do
    result = Square.prepare_for_new_game()

    assert length(result) == 32
  end

  test "create squares from existed position" do
    position = %Position{position: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"}
    result = Square.prepare_from_position(position)

    assert length(result) == 32
  end
end
