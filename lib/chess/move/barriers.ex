defmodule Chess.Move.Barriers do
  @moduledoc """
  Module for checking barriers on figures routes
  """

  defmacro __using__(_opts) do
    quote do
      defp do_check_barriers_on_route(squares, move_from, route, distance) do
        check_squares_for_barrier(
          squares,
          move_from |> coordinates() |> calc_from_index(),
          calc_direction(route),
          distance,
          1
        )
      end

      defp calc_from_index([move_from_x, move_from_y]) do
        [
          Enum.find_index(Chess.x_fields, fn x -> x == move_from_x end),
          Enum.find_index(Chess.y_fields, fn x -> x == move_from_y end)
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
        square = "#{Enum.at(Chess.x_fields, move_to_x_index)}#{Enum.at(Chess.y_fields, move_to_y_index)}"

        case squares[:"#{square}"] != nil do
          true -> {:error, "There is barrier at square #{square}"}
          false -> check_squares_for_barrier(squares, [move_from_x_index, move_from_y_index], [x_direction, y_direction], distance, step + 1)
        end
      end

      defp check_squares_for_barrier(_, _, _, _, _), do: {:ok}
    end
  end
end
