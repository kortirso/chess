# Chess

Chess package for playing chess, with game logics, validations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chess` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chess, "~> 0.4.4"}
  ]
end
```

## Start new game

```elixir
  # start new game
  Chess.new_game()

  # or initialize game from FEN-notation
  Chess.new_game("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
```

New game will be created with squares and figures, FEN-notation, and game's status

## Make move

```elixir
  Chess.play(%Chess.Game{}, "e2-e4")
```

After valid move game object will contain new figure's position and FEN-notation

### Pion's promotion

Add third option if pion achives last line, one from [q|n|r|b], default - q

```elixir
  Chess.play(%Chess.Game{}, "e7-e8", "q")
```

### Castling

To make castling move:

```elixir
  Chess.play(%Chess.Game{}, "0-0")
  Chess.play(%Chess.Game{}, "0-0-0")
```

## TODO

- [X] Create game
- [X] Create game from FEN-notation
- [X] Figure movements
- [X] Pion's en passant
- [X] Castling
- [X] Checkmate
- [X] Checking possible checkmate for next turn
- [X] Pion's promotion at last line
- [ ] Draw
- [ ] Using PGN
- [ ] Manual change game's status

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

