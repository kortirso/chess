defmodule Chess.Square do
  @moduledoc """
  Square module
  """

  alias Chess.Figure

  @x_lines [1, 2, 7, 8]
  @y_lines ["a", "b", "c", "d", "e", "f", "g", "h"]

  @doc """
  Creates 32 figures for new game and puts them to specific squares

  ## Examples

      iex> Chess.Square.prepare_for_new_game()
      [
        a1: %Chess.Figure{color: "w", type: "r"},
        b1: %Chess.Figure{color: "w", type: "n"},
        ...
      ]

  """
  def prepare_for_new_game() do
    do_line()
    |> List.flatten()
    |> Enum.map(fn {x, y} -> create_figure_for_square(x, y) end)
    |> Enum.reverse()
  end

  # create list of square names
  defp do_line, do: Enum.reduce(@x_lines, [], fn y, acc -> [do_line(y) | acc] end)
  defp do_line(y), do: Enum.reduce(@y_lines, [], fn x, acc -> [{x, y} | acc] end)

  # create figure for square
  defp create_figure_for_square(x, y) do
    color = choose_color(y)
    type = choose_type(x, y)

    {
      :"#{x}#{y}",
      Figure.new(color, type)
    }
  end

  # choose color based on x_line
  defp choose_color(line) when line <= 4, do: "w"
  defp choose_color(line) when line >= 5, do: "b"

  # choose type based on y_line
  defp choose_type(_, y) when y == 2 or y == 7, do: "p"

  # choose type based on x_line
  defp choose_type(x, _) do
    cond do
      x in ["a", "h"] -> "r"
      x in ["b", "g"] -> "n"
      x in ["c", "f"] -> "b"
      x == "d" -> "q"
      x == "e" -> "k"
    end
  end
end
