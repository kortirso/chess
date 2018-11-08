defmodule Chess.MoveTest do
  use ExUnit.Case

  alias Chess.{Game, Figure}

  setup_all do
    game_with_pions = Game.new([{:a2, Figure.new("white", "p")}, {:b3, Figure.new("white", "p")}, {:e2, Figure.new("white", "p")}, {:a4, Figure.new("black", "p")}, {:b7, Figure.new("black", "p")}, {:g5, Figure.new("white", "p")}, {:h6, Figure.new("black", "p")}, {:g7, Figure.new("black", "p")}])
    figures_game = Game.new([{:a1, Figure.new("white", "r")}, {:b1, Figure.new("white", "n")}, {:c1, Figure.new("white", "b")}, {:d1, Figure.new("white", "q")}, {:e1, Figure.new("white", "k")}, {:a7, Figure.new("black", "r")}, {:c3, Figure.new("black", "n")}, {:g5, Figure.new("black", "b")}, {:d6, Figure.new("black", "q")}, {:e8, Figure.new("black", "k")}])
    {:ok, game: game_with_pions, figures_game: figures_game}
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

    test "to 1 square diagonal, with attack", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "b3-a4")
    end

    test "to 1 square back", state do
      {:error, message} = Game.play(state[:game], "e2-e1")

      assert message == "Pion can not move like this"
    end

    test "to 3 squares forward", state do
      {:error, message} = Game.play(state[:game], "e2-e5")

      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, not from start line", state do
      {:error, message} = Game.play(state[:game], "b3-b5")

      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, from start line, with barrier", state do
      {:error, message} = Game.play(state[:game], "a2-a4")

      assert message == "There are barrier for pion at the and of move"
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
      assert {:ok, %Game{}} = Game.play(state[:game], "b7-b6")
    end

    test "to 2 squares forward, from start line, without attack", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "b7-b5")
    end

    test "to 1 square diagonal, with attack", state do
      assert {:ok, %Game{}} = Game.play(state[:game], "a4-b3")
    end

    test "to 1 square back", state do
      {:error, message} = Game.play(state[:game], "b7-b8")

      assert message == "Pion can not move like this"
    end

    test "to 3 squares forward", state do
      {:error, message} = Game.play(state[:game], "b7-b4")

      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, not from start line", state do
      {:error, message} = Game.play(state[:game], "h6-h4")

      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, from start line, with barrier", state do
      {:error, message} = Game.play(state[:game], "g7-g5")

      assert message == "There are barrier for pion at the and of move"
    end

    test "to 1 square diagonal, without attack", state do
      {:error, message} = Game.play(state[:game], "b7-c6")

      assert message == "Pion must attack for diagonal move"
    end

    test "to 1 square horizontal", state do
      {:error, message} = Game.play(state[:game], "b7-c7")

      assert message == "Pion can not move like this"
    end

    test "like Knight", state do
      {:error, message} = Game.play(state[:game], "b7-d6")

      assert message == "Pion can not move like this"
    end
  end

  describe "for rooks" do
    test "for line moves, without barrier, without attack", state do
      assert {:ok, game} = Game.play(state[:figures_game], "a1-a6")
      assert {:ok, %Game{}} = Game.play(game, "a6-c6")
    end

    test "for line move, without barrier, with attack", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "a1-a7")
    end

    test "for line move, with barrier", state do
      {:error, message} = Game.play(state[:figures_game], "a1-a8")

      assert message == "There is barrier at square a7"
    end

    test "for line move, with own barrier", state do
      {:error, message} = Game.play(state[:figures_game], "a1-b1")

      assert message == "Square b1 is under control of your figure"
    end

    test "for diagonal move", state do
      {:error, message} = Game.play(state[:figures_game], "a1-c3")

      assert message == "Rook can not move like this"
    end

    test "like Knight", state do
      {:error, message} = Game.play(state[:figures_game], "a1-c3")

      assert message == "Rook can not move like this"
    end
  end

  describe "for knights" do
    test "like Knight", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "b1-a3")
    end

    test "like Knight, with attack", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "b1-c3")
    end

    test "for line move", state do
      {:error, message} = Game.play(state[:figures_game], "b1-b3")

      assert message == "Knight can not move like this"
    end

    test "for line move, with barrier", state do
      {:error, message} = Game.play(state[:figures_game], "b1-c1")

      assert message == "Knight can not move like this"
    end

    test "for diagonal move", state do
      {:error, message} = Game.play(state[:figures_game], "b1-d3")

      assert message == "Knight can not move like this"
    end
  end

  describe "for bishop" do
    test "for diagonal move, without barrier", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "c1-f4")
    end

    test "for diagonal move, with attack", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "c1-g5")
    end

    test "for diagonal move, with barrier", state do
      {:error, message} = Game.play(state[:figures_game], "c1-h6")

      assert message == "There is barrier at square g5"
    end

    test "for line move", state do
      {:error, message} = Game.play(state[:figures_game], "c1-c3")

      assert message == "Bishop can not move like this"
    end
  end

  describe "for queen" do
    test "for line moves, without barrier", state do
      assert {:ok, game} = Game.play(state[:figures_game], "d1-d5")
      assert {:ok, %Game{}} = Game.play(game, "d5-a5")
    end

    test "for line move, with attack", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "d1-d6")
    end

    test "for diagonal move, without barrier", state do
      assert {:ok, %Game{}} = Game.play(state[:figures_game], "d1-f3")
    end

    test "for line move, with barrier", state do
      {:error, message} = Game.play(state[:figures_game], "d1-d7")

      assert message == "There is barrier at square d6"
    end

    test "for line move, with own barrier", state do
      {:error, message} = Game.play(state[:figures_game], "d1-e1")

      assert message == "Square e1 is under control of your figure"
    end
  end

  describe "for king" do
    test "for short moves, without barrier", state do
      assert {:ok, game} = Game.play(state[:figures_game], "e1-e2")
      assert {:ok, %Game{}} = Game.play(game, "e2-f3")
    end

    test "for short move, with barrier", state do
      {:error, message} = Game.play(state[:figures_game], "e1-d1")

      assert message == "Square d1 is under control of your figure"
    end

    test "for long move", state do
      {:error, message} = Game.play(state[:figures_game], "e1-e3")

      assert message == "King can not move like this"
    end
  end
end
