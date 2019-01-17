defmodule Chess.Game do
  @moduledoc """
  Game module
  """

  alias Chess.{Game, Square, Move, Position}

  defstruct squares: nil,
            current_fen: Position.new |> Position.to_fen(),
            history: [],
            status: :playing,
            check: nil

  @doc """
  Creates a game

  ## Examples

      iex> Chess.Game.new()
      %Chess.Game{squares: [...]}

  """
  def new do
    squares = Square.prepare_for_new_game()
    %Game{squares: squares}
  end

  @doc """
  Makes a play

  ## Parameters

    - game: game object
    - value: move is represented like e2-e4

  ## Examples

      iex> Chess.Game.play(%Game{}, "e2-e4")
      {:ok, %Game{}}

      iex> Chess.Game.play(%Game{}, "e2-e5")
      {:error, ""}

  """
  def play(%Game{} = game, value) when is_binary(value), do: Move.new(game, value)
end
