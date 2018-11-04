defmodule Chess.Game do
  @moduledoc """
  Game module
  """

  defstruct squares: nil

  alias Chess.{Game, Square}

  @doc """
  Creates a game 
  """
  def new() do
    Chess.Square.prepare_for_new_game()
    |> Game.new()
  end

  def new(squares) do
    %Game{squares: squares}
  end
end
