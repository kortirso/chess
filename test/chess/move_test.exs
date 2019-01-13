defmodule Chess.MoveTest do
  use ExUnit.Case

  alias Chess.Game

  setup_all do
    game = Game.new()
    {:ok, game: game}
  end

  describe "for invalid move format" do
    test "return error without -", state do
      {:error, message} = Game.play(state[:game], "e2e3")

      assert message == "Invalid move format"
    end

    test "return error with invalid format", state do
      {:error, message} = Game.play(state[:game], "e-e3")

      assert message == "Invalid move format"
    end

    test "return error with invalid square", state do
      {:error, message} = Game.play(state[:game], "k3-r5")

      assert message == "There is no such square on the board"
    end
  end

  describe "for invalid figure in source square" do
    test "return error for unexisted figure", state do
      {:error, message} = Game.play(state[:game], "a3-a4")

      assert message == "Square does not have figure for move"
    end

    test "return error for opponent figure", state do
      {:error, message} = Game.play(state[:game], "a7-a6")

      assert message == "This is not move of black player"
    end
  end
end
