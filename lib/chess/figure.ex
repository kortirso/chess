defmodule Chess.Figure do
  @moduledoc """
  Figure module
  """

  defstruct color: "", type: ""

  alias Chess.Figure

  @doc """
  Creates a figure

  ## Options

      color - white or black
      type - p (Pion), r (Rook), n (Knight), b (Bishop), q (Queen), k (King)

  ## Examples

      iex> Chess.Figure.new("white", "p")
      %Chess.Figure{color: "white", type: "p"}

  """
  def new(color, type)
      when color in ["white", "black"] and type in ["p", "r", "n", "b", "q", "k"],
      do: %Figure{color: color, type: type}
end
