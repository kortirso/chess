defmodule Chess.Square do
  @moduledoc """
  Square module
  """

  @x_lines ["a", "b", "c", "d", "e", "f", "g", "h"]
  @y_lines [1, 2, 7, 8]

  alias Chess.{Figure, Position}

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
  defp do_line, do: Enum.reduce(@y_lines, [], fn y, acc -> [do_line(y) | acc] end)
  defp do_line(y), do: Enum.reduce(@x_lines, [], fn x, acc -> [{x, y} | acc] end)

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

  @doc """
  Creates figures for new game from existed position

  ## Examples

      iex> Chess.Square.prepare_from_position(position)
      [
        a1: %Chess.Figure{color: "w", type: "r"},
        b1: %Chess.Figure{color: "w", type: "n"},
        ...
      ]

  """
  def prepare_from_position(%Position{position: position}) do
    position
    |> String.split("/", trim: true)
    |> Stream.with_index()
    |> parse_lines()
    |> List.flatten()
  end

  defp parse_lines(lines) do
    Enum.reduce(lines, [], fn {line, index}, acc ->
      {result, _} = parse_line(line, index)
      [result | acc]
    end)
  end

  defp parse_line(line, index) do
    line
    |> String.codepoints()
    |> add_figures(index)
  end

  defp add_figures(figures, index) do
    Enum.reduce(figures, {[], 0}, fn x, {squares, inline_index} ->
      case Integer.parse(x) do
        :error -> {[add_figure(x, inline_index, 8 - index) | squares], inline_index + 1}
        {number, _} -> {squares, inline_index + number}
      end
    end)
  end

  defp add_figure(x, x_index, y_line) do
    type = String.downcase(x)
    color = if type == x, do: "b", else: "w"

    {
      :"#{Enum.at(@x_lines, x_index)}#{y_line}",
      Figure.new(color, type)
    }
  end
end
