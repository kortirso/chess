defmodule Chess.Figure do
  @moduledoc """
  Figure module
  """

  defstruct color: "", type: ""

  alias Chess.{Figure}

  @doc """
  Creates a figure 
  Figure have color: white or black
  Figure have type: p (Pion), r (Rook), n (Knight), b (Bishop), q (Queen), k (King)
  """
  def new(color, type) do
    %Figure{color: color, type: type}
  end
end
