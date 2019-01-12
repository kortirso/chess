defmodule Chess.Move.Barriers do
  @moduledoc """
  Module for checking barriers on figures routes
  """

  defmacro __using__(_opts) do
    quote do
      defp check_barriers_on_route(squares, move_from, route, distance) do
        check_squares_for_barrier(squares, calc_from_index(coordinates(move_from)), calc_direction(route), distance, 1)
      end

      defp coordinates(move_from), do: String.split(move_from, "", trim: true)

      defp calc_from_index([move_from_x, move_from_y]) do
        [
          Enum.find_index(@x_fields, fn x -> x == move_from_x end),
          Enum.find_index(@y_fields, fn x -> x == move_from_y end)
        ]
      end

      defp calc_direction(route) do
        Enum.map(route, fn x ->
          case x do
            0 -> 0
            _ -> x / abs(x)
          end
        end)
      end

      defp check_squares_for_barrier(squares, [move_from_x_index, move_from_y_index], [x_direction, y_direction], distance, step) when distance > step do
        move_to_x_index = Kernel.trunc(move_from_x_index + step * x_direction)
        move_to_y_index = Kernel.trunc(move_from_y_index + step * y_direction)

        "#{Enum.at(@x_fields, move_to_x_index)}#{Enum.at(@y_fields, move_to_y_index)}"
        |> check_square(squares)

        check_squares_for_barrier(squares, [move_from_x_index, move_from_y_index], [x_direction, y_direction], distance, step + 1)
      end

      defp check_squares_for_barrier(_, _, _, _, _) do
      end

      defp check_square(new_square, squares) do
        if squares[:"#{new_square}"] != nil, do: raise "There is barrier at square #{new_square}"
      end
    end
  end
end
