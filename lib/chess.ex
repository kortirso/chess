defmodule Chess do
  @moduledoc """
  Main module for Chess

  Contains global variables and access functions
  """

  @x_fields ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_fields ["1", "2", "3", "4", "5", "6", "7", "8"]

  @indexes [0, 1, 2, 3, 4, 5, 6, 7]

  # route constants
  @diagonals [[-1, -1], [-1, 1], [1, 1], [1, -1]]
  @linears [[-1, 0], [0, 1], [1, 0], [0, -1]]
  @knights [[-1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2]]
  @white_pions [[1, 1], [-1, 1]]
  @black_pions [[1, -1], [-1, -1]]
  @white_pions_moves [[0, 1], [0, 1]]
  @black_pions_moves [[0, -1], [0, -1]]

  alias Chess.Game
  
  def new_game, do: Game.new()
  def new_game(current_fen), do: Game.new(current_fen)

  defdelegate play(game, move), to: Game
  defdelegate play(game, move, promotion), to: Game

  # calls for global variables
  def x_fields, do: @x_fields

  def y_fields, do: @y_fields

  def indexes, do: @indexes

  def diagonals, do: @diagonals

  def linears, do: @linears

  def knights, do: @knights

  def white_pions, do: @white_pions

  def black_pions, do: @black_pions

  def white_pions_moves, do: @white_pions_moves

  def black_pions_moves, do: @black_pions_moves
end
