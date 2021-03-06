import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/pos.dart';
import 'package:flutter_tetris/game/tetris_block.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';
import 'package:flutter_tetris/game/tetromino_shapes.dart';

class Tetromino {
  final TetrominoShapes shape;
  final TetrisGrid gameGrid;  
  List<TetrisBlock> blocks;

  /// Each integer represents a
  /// 90 deg turn, 0-3.
  ///
  /// 0: Neutral |
  /// 1: 90 degrees |
  /// 2: 180 degrees |
  /// 3: 270 degrees
  int _rotation;

  /// The color this Tetromino will be rendered with.
  Color get color => getColorForShape(shape);

  /// Create a new `Tetromino` with
  /// the given [shape]. The spawn points
  /// will correspond to its middle
  /// block, if applicable. In the case
  /// of a square shape, the bottom left
  /// block will be considered the spawn
  /// point. In the case of a straight
  /// block, the middle left block will
  /// be considered the spawn point.
  Tetromino({
    @required this.shape,
    @required this.gameGrid,
    bool spawn = true
  }) {
    final spawnPoint = spawn ? gameGrid.spawnPoint : _getCustomSpawnPoint();
    _rotation = 0;
    _initBlocks(spawnPoint.x, spawnPoint.y);
  }

  /// Creates a shallow copy of a Tetromino piece.
  Tetromino.clone(Tetromino other) : shape = other.shape, gameGrid = other.gameGrid {
    _rotation = other._rotation;
    blocks = List.from(other.blocks);
  }

  // See rotations here https://strategywiki.org/wiki/File:Tetris_rotation_Nintendo.png

  bool rotateRight() {
    _rotation = (_rotation + 1) % 4;
    return _doRotation(rotatingRight: true);
  }

  bool rotateLeft() {
    _rotation = (_rotation - 1) % 4;
    return _doRotation(rotatingRight: false);
  }

  bool moveRight() => _doMove(1, 0);
  bool moveLeft() => _doMove(-1, 0);
  bool moveDown() => _doMove(0, -1);

  void _initBlocks(int x, int y) {
    blocks = List.filled(4, null);
    switch (shape) {
      case TetrominoShapes.Square:
        blocks[0] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x + 1, y), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x, y + 1), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x + 1, y + 1), displayColor: color);
        break;
      case TetrominoShapes.T:
        blocks[0] = TetrisBlock(gameGrid, Pos(x - 1, y), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x + 1, y), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x, y + 1), displayColor: color);
        break;
      case TetrominoShapes.L:
        blocks[0] = TetrisBlock(gameGrid, Pos(x, y + 1), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x, y - 1), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x + 1, y - 1), displayColor: color);
        break;
      case TetrominoShapes.Back_L:
        blocks[0] = TetrisBlock(gameGrid, Pos(x, y + 1), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x, y - 1), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x - 1, y - 1), displayColor: color);
        break;
      case TetrominoShapes.Back_Z:
        blocks[0] = TetrisBlock(gameGrid, Pos(x - 1, y - 1), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x, y - 1), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x + 1, y), displayColor: color);
        break;
      case TetrominoShapes.Z:
        blocks[0] = TetrisBlock(gameGrid, Pos(x - 1, y), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x, y - 1), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x + 1, y - 1), displayColor: color);
        break;
      case TetrominoShapes.Line:
        blocks[0] = TetrisBlock(gameGrid, Pos(x - 1, y), displayColor: color);
        blocks[1] = TetrisBlock(gameGrid, Pos(x, y), displayColor: color);
        blocks[2] = TetrisBlock(gameGrid, Pos(x + 1, y), displayColor: color);
        blocks[3] = TetrisBlock(gameGrid, Pos(x + 2, y), displayColor: color);
        break;
      default:
        throw Exception('Unknown Tetromino shape: $shape');
    }
  }

  bool _doMove(int xOffset, int yOffset) {
    final blockPositions = List.generate(4, (i) => blocks[i].position);
    final successes = <bool>[];
    for (final block in blocks) {
      successes.add(block.tryOffsetPosition(xOffset, yOffset));
    }

    // If any of the position updates failed, we need to reset
    // all the positions to what they were
    bool anyBlockCouldNotUpdate = successes.any((couldUpdatePos) => !couldUpdatePos);
    if (anyBlockCouldNotUpdate) {
      for (int i = 0; i < 4; ++i) {
        blocks[i].setPosition(blockPositions[i]);
      }
    }    

    return !anyBlockCouldNotUpdate; 
  }

  bool _doRotation({bool rotatingRight}) {
    final blockPositions = List.generate(4, (i) => blocks[i].position);
    final successes = <bool>[];
    switch (shape) {
      case TetrominoShapes.Square:
        return true;
      case TetrominoShapes.T:
        // Block order for rotation 0:
        // left = 0, middle = 1, right = 2, top = 3
        Pos leftBlockPos = blockPositions[0];
        Pos midBlockPos = blockPositions[1];
        Pos rightBlockPos = blockPositions[2];
        Pos topBlockPos = blockPositions[3];

        if (rotatingRight) {
          // left block always gets topblock's old position
          // top block always gets rightblock's old position
          successes.addAll([
            blocks[0].tryUpdatePosition(topBlockPos),
            blocks[3].tryUpdatePosition(rightBlockPos)
          ]);          
          if (_rotation == 0) {
            successes.add(blocks[2].tryUpdatePosition(midBlockPos.offsetX(1)));
          } else if (_rotation == 1) {
            successes.add(blocks[2].tryUpdatePosition(midBlockPos.offsetY(-1)));
          } else if (_rotation == 2) {
            successes.add(blocks[2].tryUpdatePosition(midBlockPos.offsetX(-1)));
          } else {
            successes.add(blocks[2].tryUpdatePosition(midBlockPos.offsetY(1)));
          }
        } else {
          // right block always gets top block's old position
          // top block always gets left block's old position
          successes.addAll([
            blocks[2].tryUpdatePosition(topBlockPos),
            blocks[3].tryUpdatePosition(leftBlockPos)
          ]);
          if (_rotation == 0) {
            successes.add(blocks[0].tryUpdatePosition(midBlockPos.offsetX(-1)));
          } else if (_rotation == 1) {
            successes.add(blocks[0].tryUpdatePosition(midBlockPos.offsetY(-1)));
          } else if (_rotation == 2) {
            successes.add(blocks[0].tryUpdatePosition(midBlockPos.offsetX(1)));
          } else {
            successes.add(blocks[0].tryUpdatePosition(midBlockPos.offsetY(1)));
          }
        }
        break;
      case TetrominoShapes.L:
        // Block order for rotation 0:
        // top = 0, middle = 1, bottom = 2, bottom right = 3
        Pos midBlockPos = blockPositions[1];
        if (_rotation == 0) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetY(1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(1, -1))
          ]);
        } else if (_rotation == 1) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetX(-1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(-1, -1))
          ]);
        } else if (_rotation == 2) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetY(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(-1, 1))
          ]);
        } else {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetX(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(1, 1))
          ]);
        }
        break;
      case TetrominoShapes.Back_L:
        // Block order for rotation 0:
        // top = 0, middle = 1, bottom = 2, bottom left = 3
        Pos midBlockPos = blockPositions[1];
        if (_rotation == 0) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetY(1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(-1, -1))
          ]);
        } else if (_rotation == 1) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetX(-1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(-1, 1))
          ]);
        } else if (_rotation == 2) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetY(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(1, 1))
          ]);
        } else {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetX(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(1, -1))
          ]);
        }
        break;
      case TetrominoShapes.Z:
        // Block order for rotation 0:
        // left = 0, middle = 1, bottom = 2, bottom right = 3
        Pos midBlockPos = blockPositions[1];
        if (_rotation % 2 == 0) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetX(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(1, -1))
          ]);
        } else {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetXY(1, 1))
          ]);
        }
        break;
      case TetrominoShapes.Back_Z:
        // Block order for rotation 0:
        // bottom left = 0, bottom = 1, middle = 2, right = 3
        Pos midBlockPos = blockPositions[2];
        if (_rotation % 2 == 0) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetXY(-1, -1)),
            blocks[1].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetX(1))
          ]);
        } else {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetXY(1, -1)),
            blocks[1].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetY(1))
          ]);
        }        break;
      case TetrominoShapes.Line:
        // Mid block for line is block[1]
        Pos midBlockPos = blockPositions[1];

        // This will likely return false when close to
        // an edge, so we need to account for that.
        if (_rotation % 2 == 0) {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetX(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetX(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetX(2)),
          ]);
        } else {
          successes.addAll([
            blocks[0].tryUpdatePosition(midBlockPos.offsetY(-1)),
            blocks[2].tryUpdatePosition(midBlockPos.offsetY(1)),
            blocks[3].tryUpdatePosition(midBlockPos.offsetY(2)),
          ]);
        }
        break;
      default:
        throw Exception('Uknown Tetronimo shape: $shape');
    }

    // If any of the position updates failed, we need to reset
    // all the positions to what they were
    bool anyBlockCouldNotUpdate = successes.any((couldUpdatePos) => !couldUpdatePos);
    if (anyBlockCouldNotUpdate) {
      for (int i = 0; i < 4; ++i) {
        blocks[i].setPosition(blockPositions[i]);
      }
    }    
    
    // If any of the blocks could not update, this function should return false.
    return !anyBlockCouldNotUpdate;
  }

  Pos _getCustomSpawnPoint() {
    switch(shape) {
      case TetrominoShapes.Square: return Pos(0, 0);
      case TetrominoShapes.L: return Pos(0, 1);
      default: return Pos(1, 1);
    }
  }

  bool operator ==(other) {
    return other != null &&
      other is Tetromino &&
      this.shape == other.shape &&
      this.blocks[0] == other.blocks[0] &&
      this.blocks[1] == other.blocks[1] &&
      this.blocks[2] == other.blocks[2] &&
      this.blocks[3] == other.blocks[3];
  }

  int get hashCode => shape.hashCode * 3421 + blocks[0].hashCode + blocks[1].hashCode + blocks[2].hashCode + blocks[3].hashCode;
}
