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

  /// The player's current score. Each
  /// row clear awards 100 points.
  int get currentScore => _currentScoreInternal;

  /// The next shape to be spawned.
  TetrominoShapes nextShape;

  /// The active Tetromino piece
  /// being controlled by the player.
  Tetromino get currentPiece => Tetromino.clone(_currentPiece);

  Tetromino _currentPiece;
  int _currentScoreInternal;
  Timer _gameTimer;
  Timer _moveActionTimer;
  Timer _rotationActionTimer;
  Duration get _tickDuration => Duration(milliseconds: tickInterval);
  Duration get _moveActionInterval => Duration(milliseconds: 200);
  Duration get _rotationActionInterval => Duration(milliseconds: 100);

  /// Create a new `GameDriver` instance. Each `GameDriver`
  /// represents its own game.
  GameDriver({@required this.onUpdate, @required this.grid, this.tickInterval = 1000});

  void startGame() {
    _currentScoreInternal = 0;
    nextShape = _getNextShape();
    _spawnNewTetromino();
    onUpdate();
  }

  void stopGame() {
    if (_gameTimer.isActive) {
      _gameTimer.cancel();
    }
  }

  void movePieceRight() {
    if (_moveActionTimer?.isActive == true) return;
    if (_currentPiece.moveRight()) {
      _moveActionTimer = Timer(_moveActionInterval, (){});
      onUpdate();
    }
  }

  void movePieceLeft() {
    if (_moveActionTimer?.isActive == true) return;
    if (_currentPiece.moveLeft()) {
      _moveActionTimer = Timer(_moveActionInterval, (){});
      onUpdate();
    }
  }

  void rotatePieceRight() {
    if (_rotationActionTimer?.isActive == true) return;
    if (_currentPiece.rotateRight()) {
      _rotationActionTimer = Timer(_rotationActionInterval, (){});
      onUpdate();
    }
  }

  void rotatePieceLeft() {
    if (_rotationActionTimer?.isActive == true) return;
    if (_currentPiece.rotateLeft()) {
      _rotationActionTimer = Timer(_rotationActionInterval, (){});
      onUpdate();
    }
  }

  /// Manually move the piece down before the end of the tick.
  void movePieceDown() {
    _movePieceDownInternal();
    // reset the tick
    _gameTimer = Timer.periodic(_tickDuration, _onTick);
  }

  void _movePieceDownInternal() {
    final couldMoveDown = _currentPiece.moveDown();
    if (!couldMoveDown) {
      grid.addBlocks(_currentPiece);
      _spawnNewTetromino();
      _clearCompletedRows();
    }
    onUpdate();
  }

  void _clearCompletedRows() {
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
    _currentScoreInternal += 100;
  }

  void _spawnNewTetromino() {
    _currentPiece = Tetromino(shape: nextShape, gameGrid: grid);
    nextShape = _getNextShape();
    _rotationActionTimer?.cancel();
    _moveActionTimer?.cancel();
    _gameTimer = Timer.periodic(_tickDuration, _onTick);
  }

  void _onTick(Timer t) {
    _movePieceDownInternal();
  }

  TetrominoShapes _getNextShape() {
    final shapes = List<TetrominoShapes>.from(TetrominoShapes.values)..shuffle();
    return shapes.first;
  }
}
