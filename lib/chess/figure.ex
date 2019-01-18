defmodule Chess.Figure do
  @moduledoc """
  Figure module
  """

  defstruct color: "", type: ""

  alias Chess.Figure

  @doc """
  Creates a figure

  ## Options

      color - w or b
      type - p (Pion), r (Rook), n (Knight), b (Bishop), q (Queen), k (King)

  ## Examples

      iex> Chess.Figure.new("w", "p")
      %Chess.Figure{color: "w", type: "p"}

  """
  def new(color, type)
      when color in ["w", "b"] and type in ["p", "r", "n", "b", "q", "k"],
      do: %Figure{color: color, type: type}
end
