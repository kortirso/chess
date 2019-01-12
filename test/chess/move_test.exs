defmodule Chess.MoveTest do
  use ExUnit.Case

  alias Chess.Game

  setup_all do
    game = Game.new()
    {:ok, game: game}
  end

  describe "for move format" do
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

    test "with valid square", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "e2-e3")
    end
  end

  describe "for figure presence" do
    test "figure is exist", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "a2-a3")
    end

    test "figure is not exist", state do
      {:error, message} = Game.play(state[:game], "a3-a4")

      assert message == "Square does not have figure for move"
    end
  end

  describe "for white pions" do
    test "to 1 square forward, without barrier", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "e2-e3")
    end

    test "to 2 squares forward, from start line, without barrier", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "e2-e4")
    end

    test "to 1 square back", state do
      {:error, message} = Game.play(state[:game], "e2-e1")

      assert message == "Pion can not move like this"
    end

    test "to 3 squares forward", state do
      {:error, message} = Game.play(state[:game], "e2-e5")

      assert message == "Pion can not move like this"
    end

    test "to 1 square diagonal, without attack", state do
      {:error, message} = Game.play(state[:game], "e2-f3")

      assert message == "Pion must attack for diagonal move"
    end

    test "to 1 square horizontal", state do
      {:error, message} = Game.play(state[:game], "e2-f2")

      assert message == "Pion can not move like this"
    end

    test "like Knight", state do
      {:error, message} = Game.play(state[:game], "a2-c3")

      assert message == "Pion can not move like this"
    end
  end

  describe "for black pions" do
    test "to 1 square forward, without attack", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      assert {:ok, %Game{}} = Game.play(game, "b7-b6")
    end

    test "to 2 squares forward, from start line, without attack", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      assert {:ok, %Game{}} = Game.play(game, "b7-b5")
    end

    test "to 1 square back", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      {:error, message} = Game.play(game, "b7-b8")

      assert message == "Pion can not move like this"
    end

    test "to 3 squares forward", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      {:error, message} = Game.play(game, "b7-b4")

      assert message == "Pion can not move like this"
    end

    test "to 1 square diagonal, without attack", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      {:error, message} = Game.play(game, "b7-c6")

      assert message == "Pion must attack for diagonal move"
    end

    test "to 1 square horizontal", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      {:error, message} = Game.play(game, "b7-c7")

      assert message == "Pion can not move like this"
    end

    test "like Knight", state do
      {:ok, game} = Game.play(state[:game], "e2-e3")

      {:error, message} = Game.play(game, "b7-d6")

      assert message == "Pion can not move like this"
    end
  end
end
