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

  /// Whether the game is currently running.
  bool get isActive => _gameTimer?.isActive == true;

  /// The next shape to be spawned.
  TetrominoShapes nextShape;

  /// The active Tetromino piece
  /// being controlled by the player.
  Tetromino get currentPiece => Tetromino.clone(_currentPiece);

  /// Whether the game has ended.
  bool get gameOver => grid.overflowedTop;

  Tetromino _currentPiece;
  int _currentScoreInternal;
  Timer _gameTimer;
//  Timer _moveActionTimer;
//  Timer _rotationActionTimer;
  Duration get _tickDuration => Duration(milliseconds: tickInterval);
//  Duration get _moveActionInterval => Duration(milliseconds: 200);
//  Duration get _rotationActionInterval => Duration(milliseconds: 100);

  /// Create a new `GameDriver` instance. Each `GameDriver`
  /// represents its own game.
  GameDriver({@required this.onUpdate, @required this.grid, this.tickInterval = 1000}) {
    nextShape = _getNextShape();
    _currentPiece = Tetromino(shape: nextShape, gameGrid: grid, spawn: false);
  }

  /// To be called when the widget containing
  /// this is disposed.
  void dispose() {
    _gameTimer?.cancel();
//    _moveActionTimer?.cancel();
//    _rotationActionTimer?.cancel();
  }

  void startGame() {
    _currentScoreInternal = 0;
    _spawnNewTetromino();
    onUpdate();
  }

  void resumeGame() {
    if (!isActive && !gameOver) {
      _gameTimer = Timer.periodic(_tickDuration, _onTick);
    }
  }

  void stopGame() {
    if (isActive) {
      _gameTimer.cancel();
    }
  }

  void movePieceRight() {
    if (gameOver) return;
    if (_currentPiece.moveRight()) {
      onUpdate();
    }
  }

  void movePieceLeft() {
    if (gameOver) return;
    if (_currentPiece.moveLeft()) {
      onUpdate();
    }
  }

  void rotatePieceRight() {
    if (gameOver) return;
    if (_currentPiece.rotateRight()) {
      onUpdate();
    }
  }

  void rotatePieceLeft() {
    if (gameOver) return;
    if (_currentPiece.rotateLeft()) {
      onUpdate();
    }
  }

  /// Manually move the piece down before the end of the tick.
  void movePieceDown() {
    if (gameOver) return;
    _movePieceDownInternal();
    // reset the tick
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(_tickDuration, _onTick);
  }

  void _movePieceDownInternal() {
    print('Move ${_currentPiece.shape} piece down');
    final couldMoveDown = _currentPiece.moveDown();
    if (!couldMoveDown) {
      print('Reached bottom');
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
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(_tickDuration, _onTick);
  }

  void _onTick(Timer t) {
    _movePieceDownInternal();
    if (grid.overflowedTop) {
      _gameTimer.cancel();
    }
  }

  TetrominoShapes _getNextShape() {
    final shapes = List<TetrominoShapes>.from(TetrominoShapes.values)..shuffle();
    return shapes.first;
  }
}
