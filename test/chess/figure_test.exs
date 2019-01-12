defmodule Chess.FigureTest do
  use ExUnit.Case

  alias Chess.Figure

  test "create figure" do
    %Figure{color: color, type: type} = Figure.new("white", "p")

    assert color == "white"
    assert type == "p"
  end
end
