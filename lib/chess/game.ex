defmodule Chess.Game do
  @moduledoc """
  Game module
  """

  defstruct squares: nil

  alias Chess.{Game, Square, Move}

  @doc """
  Creates a game
  """
  def new() do
    Square.prepare_for_new_game()
    |> Game.new()
  end

  def new(squares) do
    %Game{squares: squares}
  end

  @doc """
  Makes a play
  Move represents like e2-e4
  """
  def play(%Game{squares: squares}, move) do
    Move.new(squares, move)
  end
end
