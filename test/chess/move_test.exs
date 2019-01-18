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

      assert message == "This is not move of b player"
    end
  end

  describe "for invalid figure routes, pion" do
    test "return error for move like knight", state do
      {:error, message} = Game.play(state[:game], "a2-b4")

      assert message == "Pion can not move like this"
    end

    test "return error for long diagonal move", state do
      {:error, message} = Game.play(state[:game], "a2-c4")

      assert message == "Pion can not move like this"
    end

    test "return error for long linear move", state do
      {:error, message} = Game.play(state[:game], "a2-a5")

      assert message == "Pion can not move like this"
    end

    test "return error for strafe move", state do
      {:error, message} = Game.play(state[:game], "a2-b2")

      assert message == "Pion can not move like this"
    end

    test "return error for back move", state do
      {:error, message} = Game.play(state[:game], "a2-a1")

      assert message == "Pion can not move like this"
    end
  end

  describe "for invalid figure routes, rook" do
    test "return error for move like knight", state do
      {:error, message} = Game.play(state[:game], "a1-b3")

      assert message == "Rook can not move like this"
    end

    test "return error for diagonal move", state do
      {:error, message} = Game.play(state[:game], "a1-b2")

      assert message == "Rook can not move like this"
    end
  end

  describe "for invalid figure routes, knight" do
    test "return error for diagonal move", state do
      {:error, message} = Game.play(state[:game], "b1-a2")

      assert message == "Knight can not move like this"
    end

    test "return error for linear move", state do
      {:error, message} = Game.play(state[:game], "b1-b2")

      assert message == "Knight can not move like this"
    end
  end

  describe "for invalid figure routes, bishop" do
    test "return error for move like knight", state do
      {:error, message} = Game.play(state[:game], "c1-e2")

      assert message == "Bishop can not move like this"
    end

    test "return error for linear move", state do
      {:error, message} = Game.play(state[:game], "c1-c2")

      assert message == "Bishop can not move like this"
    end
  end

  describe "for invalid figure routes, queen" do
    test "return error for move like knight", state do
      {:error, message} = Game.play(state[:game], "d1-e3")

      assert message == "Queen can not move like this"
    end
  end

  describe "for invalid figure routes, king" do
    test "return error for move like knight", state do
      {:error, message} = Game.play(state[:game], "e1-d3")

      assert message == "King can not move like this"
    end

    test "return error for long diagonal move", state do
      {:error, message} = Game.play(state[:game], "e1-g3")

      assert message == "King can not move like this"
    end

    test "return error for long linear move", state do
      {:error, message} = Game.play(state[:game], "e1-e3")

      assert message == "King can not move like this"
    end
  end

  describe "for invalid figure routes with barriers" do
    test "return error, example 1", state do
      {:error, message} = Game.play(state[:game], "a1-a3")

      assert message == "There is barrier at square a2"
    end

    test "return error, example 2", state do
      {:error, message} = Game.play(state[:game], "a1-c1")

      assert message == "There is barrier at square b1"
    end

    test "return error, example 3", state do
      {:error, message} = Game.play(state[:game], "c1-a3")

      assert message == "There is barrier at square b2"
    end

    test "return error, example 4", state do
      {:error, message} = Game.play(state[:game], "d1-d8")

      assert message == "There is barrier at square d2"
    end

    test "return error, example 5", state do
      {:error, message} = Game.play(state[:game], "0-0-0")

      assert message == "There is barrier at square d1"
    end
  end

  describe "for invalid destination square" do
    test "return error", state do
      {:error, message} = Game.play(state[:game], "a1-a2")

      assert message == "Square a2 is under control of your figure"
    end
  end
end
