import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';
import 'package:flutter_tetris/game/tetromino.dart';
import 'package:flutter_tetris/game/tetromino_shapes.dart';

/// The class responsible for maintaining
/// state of the game and progressing it
/// along.
class GameDriver extends ValueNotifier<Tetromino> {
  @override
  Tetromino get value => hasStarted ? _currentPiece : null;

  /// How often the grid updates in milliseconds.
  final int tickInterval;

  /// The Tetris grid.
  final TetrisGrid grid;

  /// The player's current score. Each
  /// row clear awards 100 points.
  int get currentScore => _currentScoreInternal;

  /// Whether the game is currently running.
  bool get isActive => _gameTimer?.isActive == true && !_paused;

  bool get hasStarted => _hasStartedInternal;
  bool _hasStartedInternal;

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
  bool _paused;
  Duration get _tickDuration => Duration(milliseconds: tickInterval);

  /// Create a new `GameDriver` instance. Each `GameDriver`
  /// represents its own game.
  GameDriver({@required this.grid, this.tickInterval = 1000}) : super(null) {
    nextShape = _getNextShape();
    _paused = false;
    _hasStartedInternal = false;
    _currentScoreInternal = 0;
    _currentPiece = Tetromino(shape: nextShape, gameGrid: grid, spawn: false);
  }

  /// To be called when the widget containing
  /// this is disposed.
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    _hasStartedInternal = true;
    _spawnNewTetromino();
    notifyListeners();
  }

  void resumeGame() {
    if (!isActive && !gameOver) {
      _paused = false;
      _gameTimer = Timer.periodic(_tickDuration, _onTick);
    }
  }

  void pauseGame() {
    if (isActive && !gameOver) {
      _gameTimer.cancel();
      _paused = true;
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
      notifyListeners();
    }
  }

  void movePieceLeft() {
    if (gameOver) return;
    if (_currentPiece.moveLeft()) {
      notifyListeners();
    }
  }

  void rotatePieceRight() {
    if (gameOver) return;
    if (_currentPiece.rotateRight()) {
      notifyListeners();
    }
  }

  void rotatePieceLeft() {
    if (gameOver) return;
    if (_currentPiece.rotateLeft()) {
      notifyListeners();
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
    final couldMoveDown = _currentPiece.moveDown();
    if (!couldMoveDown) {
      grid.addBlocks(_currentPiece);
      _spawnNewTetromino();
      _clearCompletedRows();
    }
    notifyListeners();
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
