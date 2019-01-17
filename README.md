# Chess

Chess package for playing chess, with game logics, validations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chess` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chess, "~> 0.3.2"}
  ]
end
```

## Start new game

```elixir
  alias Chess.Game

  Game.new()
```

New game will be created with squares and figures, FEN-notation, and game's status

## Make move

```elixir
  Game.play(%Game{}, "e2-e4")
```

After valid move game object will contain new figure's position and FEN-notation

## TODO

- [X] Create game
- [ ] Create game from FEN-notation
- [X] Figure movements
- [X] Pion's en passant
- [X] Castling
- [X] Checkmate
- [X] Checking possible checkmate for next turn
- [ ] Draw
- [ ] Pion's promotion at last line

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kortirso/chess.

## License

The package is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Disclaimer

Use this package at your own peril and risk.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/chess](https://hexdocs.pm/chess).

