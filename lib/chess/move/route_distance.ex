defmodule Chess.Move.RouteDistance do
  @doc false
  defmacro __using__(_opts) do
    quote do
      defp do_calc_route_and_distance(move) do
        # calculate route direction
        route = calc_route(move.from, move.to)
        # calculate distance of move
        distance = calc_distance(route)

        case distance do
          0 -> {:error, "You need to move figure somewhere"}
          _ -> [route, distance]
        end
      end

      defp calc_route(from, to) do
        [move_from_x, move_from_y] = coordinates(from)
        [to_x, to_y] = coordinates(to)

        [
          Enum.find_index(@x_fields, fn x -> x == to_x end) - Enum.find_index(@x_fields, fn x -> x == move_from_x end),
          Enum.find_index(@y_fields, fn y -> y == to_y end) - Enum.find_index(@y_fields, fn y -> y == move_from_y end)
        ]
      end

      defp calc_distance(route) do
        route
        |> Enum.map(fn x -> abs(x) end)
        |> Enum.max()
      end
    end
  end
end
