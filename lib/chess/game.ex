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
    - promotion: if pion achives last line then it will promote to this figure

  ## Examples

      iex> Chess.Game.play(%Game{}, "e2-e4")
      {:ok, %Game{}}

      iex> Chess.Game.play(%Game{}, "e2-e5")
      {:error, ""}

      iex> Chess.Game.play(%Game{}, "e7-e8", "q")
      {:ok, %Game{}}

  """
  def play(%Game{} = game, value, promotion \\ "q")
    when is_binary(value) and promotion in ["r", "n", "b", "q"],
    do: Move.new(game, value, promotion)
end
