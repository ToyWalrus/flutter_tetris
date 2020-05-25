import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/pos.dart';
import 'package:flutter_tetris/game/tetris_block.dart';
import 'package:flutter_tetris/game/tetromino.dart';

class TetrisGrid {
  final int width;
  final int height;

  /// Indexed as (column, row), or (x, y).
  /// This 2D array holds all of the block
  /// positions that have been settled (i.e.
  /// not being controlled)
  List<List<TetrisBlock>> _occupiedAreas;

  Pos get spawnPoint => Pos(width ~/ 2, height - 1);

  /// Create a new `TetrisGrid` with the
  /// given [width] and [height]. The
  /// (0,0) coordinate is the bottom
  /// leftmost block area.
  TetrisGrid({
    @required this.width,
    @required this.height
  }) {
    List<TetrisBlock> initColumn() => List.filled(height, null);
    _occupiedAreas = List.filled(width, initColumn());
  }

  /// Returns the current state of the grid.
  List<List<TetrisBlock>> getGrid() => List.unmodifiable(_occupiedAreas);

  /// Returns whether the given space is occupied.
  bool isOccupiedSpace(int col, int row) => _occupiedAreas[col][row] != null;

  /// Returns whether the given position is off the grid.
  bool isOffGrid(int col, int row) => col < 0 || col >= width || row < 0 || row >= height;

  /// Clears the given row and shifts all blocks above
  /// the given row down by one. Note that this does
  /// not check whether the row is full or not. For
  /// that, call `isRowFull()`.
  void clearRow(int row) {
    for (int i = row; i < height; ++i) {
      if (i != height - 1) {
        for (int col = 0; col < width; ++col) {
          // It's possible we may have to modify the
          // blocks' x and y, but for now I don't think
          // we need to
          _occupiedAreas[col][i] = _occupiedAreas[col][i + 1];
        }
      }
    }

    // empty the top row
    for (int col = 0; col < width; ++col) {
      _occupiedAreas[col][height - 1] = null;
    }
  }

  /// Checks whether the given row is full and
  /// ready to be cleared.
  bool isRowFull(int row) {
    for (int col = 0; col < width; ++col) {
      if (!isOccupiedSpace(col, row)) return false;
    }
    return true;
  }

  /// To be called when the [currentPiece]
  /// cannot go down anymore. This method adds
  /// all of the blocks in the `Tetromino` to
  /// the grid.
  void addBlocks(Tetromino currentPiece) {
    for (TetrisBlock block in currentPiece.blocks) {
      assert(!isOccupiedSpace(block.x, block.y));
      _occupiedAreas[block.x][block.y] = block;
    }
  }

  bool isDifferentThan(TetrisGrid other) {
    if (this.width != other.width || this.height != other.height) return true;
    for (int col = 0; col < width; ++col) {
      for (int row = 0; row < height; ++row) {
        final thisBlock = this._occupiedAreas[col][row];
        final otherBlock = other._occupiedAreas[col][row];
        if ((thisBlock == null && otherBlock != null) ||
            (thisBlock != null && otherBlock == null)) {
          return true;
        }
        if (thisBlock != null && thisBlock != otherBlock) {
          return true;
        }
      }
    }
    return false;
  }    
}