defmodule Chess.MoveTest do
  use ExUnit.Case

  alias Chess.{Game, Figure}

  setup_all do
    {:ok, game: Game.new([{:a2, Figure.new("white", "p")}, {:b3, Figure.new("white", "p")}, {:e2, Figure.new("white", "p")}, {:a4, Figure.new("black", "p")}, {:b7, Figure.new("black", "p")}, {:g5, Figure.new("white", "p")}, {:h6, Figure.new("black", "p")}, {:g7, Figure.new("black", "p")}])}
  end

  describe "for move format" do
    test "without -", state do
      {status, message} = Game.play(state[:game], "e2e3")

      assert status == :error
      assert message == "Invalid move format"
    end

    test "with invalid format", state do
      {status, message} = Game.play(state[:game], "e-e3")

      assert status == :error
      assert message == "Invalid move format"
    end

    test "with invalid square", state do
      {status, message} = Game.play(state[:game], "k3-r5")

      assert status == :error
      assert message == "There is no such square on the board"
    end

    test "with valid square", state do
      {status, _message} = Game.play(state[:game], "e2-e3")

      assert status == :ok
    end
  end

  describe "for white pions" do
    test "to 1 square forward, without barrier", state do
      {status, _message} = Game.play(state[:game], "e2-e3")

      assert status == :ok
    end

    test "to 2 squares forward, from start line, without barrier", state do
      {status, _message} = Game.play(state[:game], "e2-e4")

      assert status == :ok
    end

    test "to 1 square diagonal, with attack", state do
      {status, _message} = Game.play(state[:game], "b3-a4")

      assert status == :ok
    end

    test "to 1 square back", state do
      {status, message} = Game.play(state[:game], "e2-e1")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "to 3 squares forward", state do
      {status, message} = Game.play(state[:game], "e2-e5")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, not from start line", state do
      {status, message} = Game.play(state[:game], "b3-b5")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, from start line, with barrier", state do
      {status, message} = Game.play(state[:game], "a2-a4")

      assert status == :error
      assert message == "There are barrier for pion at the and of move"
    end

    test "to 1 square diagonal, without attack", state do
      {status, message} = Game.play(state[:game], "e2-f3")

      assert status == :error
      assert message == "Pion must attack for diagonal move"
    end

    test "to 1 square horizontal", state do
      {status, message} = Game.play(state[:game], "e2-f2")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "like Knight", state do
      {status, message} = Game.play(state[:game], "a2-c3")

      assert status == :error
      assert message == "Pion can not move like this"
    end
  end

  describe "for black pions" do
    test "to 1 square forward, without attack", state do
      {status, _message} = Game.play(state[:game], "b7-b6")

      assert status == :ok
    end

    test "to 2 squares forward, from start line, without attack", state do
      {status, _message} = Game.play(state[:game], "b7-b5")

      assert status == :ok
    end

    test "to 1 square diagonal, with attack", state do
      {status, _message} = Game.play(state[:game], "a4-b3")

      assert status == :ok
    end

    test "to 1 square back", state do
      {status, message} = Game.play(state[:game], "b7-b8")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "to 3 squares forward", state do
      {status, message} = Game.play(state[:game], "b7-b4")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, not from start line", state do
      {status, message} = Game.play(state[:game], "h6-h4")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "to 2 squares forward, from start line, with barrier", state do
      {status, message} = Game.play(state[:game], "g7-g5")

      assert status == :error
      assert message == "There are barrier for pion at the and of move"
    end

    test "to 1 square diagonal, without attack", state do
      {status, message} = Game.play(state[:game], "b7-c6")

      assert status == :error
      assert message == "Pion must attack for diagonal move"
    end

    test "to 1 square horizontal", state do
      {status, message} = Game.play(state[:game], "b7-c7")

      assert status == :error
      assert message == "Pion can not move like this"
    end

    test "like Knight", state do
      {status, message} = Game.play(state[:game], "b7-d6")

      assert status == :error
      assert message == "Pion can not move like this"
    end
  end
end
