defmodule Chess.Square do
  @moduledoc """
  Square module
  """

  alias Chess.{Figure}

  @doc """
  Creates 32 figures for new game and puts them to spesific squares
  Returns keyword list like
  [
    a1: %Chess.Figure{color: "white", type: "r"},
    b1: %Chess.Figure{color: "white", type: "n"},
    ...
  ]
  """
  def prepare_for_new_game() do
    list_of_squares()
    |> List.flatten
    |> Enum.map(fn {x, y} -> create_figure_for_square(x, y) end)
  end

  defp list_of_squares() do
    squares = []
    Enum.map [1, 2, 7, 8], fn y ->
      Enum.map ["a", "b", "c", "d", "e", "f", "g", "h"], fn x ->
        [{x, y} | squares]
      end
    end
  end

  defp create_figure_for_square(x, y) do
    color = choose_color(y)
    type = choose_type(x, y)
    {:"#{x}#{y}", Figure.new(color, type)}
  end

  defp choose_color(line) do
    cond do
      line < 5 -> "white"
      line > 4 -> "black"
    end
  end

  defp choose_type(_x, y) when y == 2 or y == 7 do
    "p"
  end

  defp choose_type(x, _y) do
    cond do
      x in ["a", "h"] -> "r"
      x in ["b", "g"] -> "n"
      x in ["c", "f"] -> "b"
      x == "d" -> "q"
      x == "e" -> "k"
    end
  end
end
