defmodule Chess.SquareTest do
  use ExUnit.Case

  alias Chess.Square

  test "create squares for starting game" do
    result = Square.prepare_for_new_game()
    assert Enum.count(result) == 32
  end
end
