defmodule Chess.Game do
  @moduledoc """
  Game module
  """

  alias Chess.{Game, Square, Move, Position}

  defstruct squares: nil, current_fen: Position.new, history: []

  @doc """
  Creates a game
  """
  def new() do
    Square.prepare_for_new_game()
    |> Game.new
  end

  def new(squares) do
    %Game{squares: squares}
  end

  @doc """
  Makes a play
  Move represents like e2-e4
  """
  def play(game, move) do
    Move.new(game, move)
  end
end
