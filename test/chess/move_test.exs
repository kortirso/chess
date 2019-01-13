defmodule Chess.MoveTest do
  use ExUnit.Case

  alias Chess.Game

  setup_all do
    game = Game.new()
    {:ok, game: game}
  end

  describe "for invalid move format" do
    test "without -", state do
      {:error, message} = Game.play(state[:game], "e2e3")

      assert message == "Invalid move format"
    end

    test "with invalid format", state do
      {:error, message} = Game.play(state[:game], "e-e3")

      assert message == "Invalid move format"
    end

    test "with invalid square", state do
      {:error, message} = Game.play(state[:game], "k3-r5")

      assert message == "There is no such square on the board"
    end
  end
end
