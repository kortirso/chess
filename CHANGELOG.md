# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Modify
- avoiding check
- figure color to short name
- readme
- castling when is check for king is forbidden

## [0.3.3] - 2019-01-17
### Added
- Pion's promotion

## [0.3.2] - 2019-01-17
### Added
- structure for Chess.Move

### Modify
- end_move algorithm
- code refactoring

## [0.3.1] - 2019-01-16
### Modify
- readme

## [0.3.0] - 2019-01-16
### Added
- check attackers for the opponent's king
- check try to destroy king's attacker and try to block king's attacker route
- make virtual move after avoiding check to verify valid move
- error for completed game
- verify avoiding check

### Modify
- castling process

## [0.2.0] - 2019-01-13
### Modified
- error handling for Position module
- parsing move process
- checking valid figure for move
- checking routes for figures
- checking barriers for moves
- checking barriers for castling moves
- checking destination point

## [0.1.1] - 2019-01-12
### Modified
- game creation process
- squares creation process for new game
- figure creation process
- Position module
- Move module

## [0.1.0] - 2019-01-12
### Added
- CHANGELOG file
- Game module for creating game and making moves
- Square module
- Position module
- Figure module
- Move module
- Checks for simple moves
