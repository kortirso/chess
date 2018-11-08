defmodule Chess.Position do
  @moduledoc """
  Position module
  """

  @doc """
  Start position on the board in FEN-notation
  """
  def new() do
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  end

  @doc """
  Calculate FEN-notation for current board
  """
  def new(_squares, current_fen) do
    current_fen
  end
end
