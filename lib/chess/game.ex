defmodule Chess.Game do
  @moduledoc """
  Game module
  """

  defstruct squares: nil

  alias Chess.{Game}

  @doc """
  Creates a game 
  """
  def new() do
    %Game{}
  end
end
