import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';
import 'package:flutter_tetris/game/tetromino.dart';
import 'package:flutter_tetris/game/tetromino_shapes.dart';

/// The class responsible for maintaining
/// state of the game and progressing it
/// along.
class GameDriver {
  /// How often the grid updates in milliseconds.
  final int tickInterval;

  /// The Tetris grid.
  final TetrisGrid grid;

  /// A callback for each time the
  /// grid or current Tetromino
  /// have been updated.
  final Function onUpdate;

  int currentScore;
  TetrominoShapes nextShape;
  Tetromino _currentPiece;
  Timer _timer;

  Duration get _tickDuration => Duration(milliseconds: tickInterval);

  /// Create a new `GameDriver` instance. Each `GameDriver`
  /// represents its own game.
  GameDriver({@required this.onUpdate, @required this.grid, this.tickInterval = 1000});

  void startGame() {
    currentScore = 0;
    _timer = Timer.periodic(_tickDuration, _onTick);
    final shape = _getNextShape();
    nextShape = _getNextShape();
    _currentPiece = Tetromino(shape: shape, gameGrid: grid);
    onUpdate();
  }

  void stopGame() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  void movePieceRight() {
    if (_currentPiece.moveRight()) {
      onUpdate();
    }
  }

  void movePieceLeft() {
    if (_currentPiece.moveLeft()) {
      onUpdate();
    }
  }

  void rotatePieceRight() {
    if (_currentPiece.rotateRight()) {
      onUpdate();
    }
  }

  void rotatePieceLeft() {
    if (_currentPiece.rotateLeft()) {
      onUpdate();
    }
  }

  /// Manually move the piece down before the end of the tick.
  void movePieceDown() {
    _movePieceDownInternal();
    // reset the tick
    _timer = Timer.periodic(_tickDuration, _onTick);
  }

  void _movePieceDownInternal() {
    final couldMoveDown = _currentPiece.moveDown();
    if (!couldMoveDown) {
      grid.addBlocks(_currentPiece);
      _currentPiece = Tetromino(shape: nextShape, gameGrid: grid);
      nextShape = _getNextShape();
      _checkForCompletedRows();
    }
    onUpdate();
  }

  void _checkForCompletedRows() {
    bool foundCompletedRow;
    do {
      foundCompletedRow = false;
      for (int row = 0; row < grid.height; ++row) {
        if (grid.isRowFull(row)) {
          grid.clearRow(row);
          foundCompletedRow = true;
          _increaseScore();
          break;
        }
      }
    } while (foundCompletedRow);
  }

  void _increaseScore() {
    currentScore += 100;
  }

  void _onTick(Timer t) {
    _movePieceDownInternal();
  }

  TetrominoShapes _getNextShape() {
    final shapes = List<TetrominoShapes>.from(TetrominoShapes.values)..shuffle();
    return shapes.first;
  }
}
