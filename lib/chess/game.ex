defmodule Chess.Game do
  @moduledoc """
  Game module
  """

  defstruct squares: nil, current_fen: ""

  alias Chess.{Game, Square, Move, Position}

  @doc """
  Creates a game
  """
  def new() do
    Square.prepare_for_new_game()
    |> Game.new(Position.new())
  end

  def new(squares, current_fen \\ "") do
    %Game{squares: squares, current_fen: current_fen}
  end

  @doc """
  Makes a play
  Move represents like e2-e4
  """
  def play(game, move) do
    Move.new(game, move)
  end
end
