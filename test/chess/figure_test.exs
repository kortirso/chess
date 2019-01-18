defmodule Chess.FigureTest do
  use ExUnit.Case

  alias Chess.Figure

  test "create figure" do
    %Figure{color: color, type: type} = Figure.new("w", "p")

    assert color == "w"
    assert type == "p"
  end
end
