import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/pos.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';

class TetrisBlock {
  final Color displayColor;
  final TetrisGrid gameGrid;
  int _x;
  int _y;

  TetrisBlock(this.gameGrid, Pos position, {this.displayColor = Colors.black}) {
    _x = position.x;
    _y = position.y;
  }

  /// Attempts to update this block's position. If
  /// it could not update the position due to a
  /// grid constraint, the position is not updated
  /// and this will return false.
  bool tryUpdatePosition(Pos newPos) {
    int x = newPos.x;
    int y = newPos.y;
    if (gameGrid.isOccupiedSpace(x, y) || gameGrid.isOffGrid(x, y)) {
      return false;
    }
    setPosition(newPos);
    return true;
  }

  /// Attempts to offset this block's position.
  /// Works similarly to `tryUpdatePosition()`
  /// but this function takes into account the
  /// current position of the block.
  bool tryOffsetPosition(int xAmt, int yAmt) {
    int x = this.x + xAmt;
    int y = this.y + yAmt;
    if (gameGrid.isOccupiedSpace(x, y) || gameGrid.isOffGrid(x, y)) {
      return false;
    }
    setPosition(Pos(x, y));
    return true;
  }

  /// Manually sets the position of the block without
  /// any checks on whether it's legal or not. Most of
  /// the time, you probably want to use `tryUpdatePosition()`
  /// or `tryOffsetPosition()`.
  void setPosition(Pos newPos) {
    _x = newPos.x;
    _y = newPos.y;
  }

  Pos get position => Pos(_x, _y);
  int get x => position.x;
  int get y => position.y;
}