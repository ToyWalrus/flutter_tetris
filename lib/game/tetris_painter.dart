import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/tetris_block.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';
import 'package:flutter_tetris/game/tetromino.dart';

class TetrisPainter extends CustomPainter {
  final TetrisGrid grid;
  final ValueNotifier<Tetromino> notifier;
  final Color backgroundColor;
  final double blockSizeFractionOfCell;

  TetrisPainter(
      {@required this.grid,
      @required this.notifier,
      @required this.backgroundColor,
      this.blockSizeFractionOfCell = 0.9})
      : super(repaint: notifier);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cellWidth = canvasSize.width / grid.width;
    final cellHeight = canvasSize.height / grid.height;
    final cellSize = Size(cellWidth, cellHeight);
    final blockSize = cellSize * blockSizeFractionOfCell;

    // Sets the canvas so that (0,0) is bottom left
    canvas.translate(0, canvasSize.height);
    canvas.scale(1, -1);

//    _drawBackground(canvas, canvasSize, cellSize);
    _drawGrid(canvas, cellSize, blockSize);
    if (notifier?.value != null) {
      _drawCurrentPiece(canvas, cellSize, blockSize);
    }
  }

  void _drawGrid(Canvas canvas, Size cellSize, Size blockSize) {
    final cellCenterOffsetX = cellSize.width / 2;
    final cellCenterOffsetY = cellSize.height / 2;

    final blockGrid = grid.getGrid();
    for (int col = 0; col < blockGrid.length; ++col) {
      for (int row = 0; row < blockGrid[col].length; ++row) {
        final cellCenterX = cellSize.width * col + cellCenterOffsetX;
        final cellCenterY = cellSize.height * row + cellCenterOffsetY;
        final block = blockGrid[col][row];
        if (block == null) {
          _drawBlock(canvas, Colors.white, cellCenterX, cellCenterY, blockSize);
        } else {
          _drawBlock(canvas, block.displayColor, cellCenterX, cellCenterY, blockSize);
        }
      }
    }
  }

  void _drawCurrentPiece(Canvas canvas, Size cellSize, Size blockSize) {
    final cellCenterOffsetX = cellSize.width / 2;
    final cellCenterOffsetY = cellSize.height / 2;
    for (final block in notifier.value.blocks) {
      final cellCenterX = cellSize.width * block.x + cellCenterOffsetX;
      final cellCenterY = cellSize.height * block.y + cellCenterOffsetY;
      _drawBlock(canvas, block.displayColor, cellCenterX, cellCenterY, blockSize);
    }
  }

  void _drawBlock(Canvas canvas, Color blockColor, double centerX, double centerY, Size blockSize) {
    final paint = Paint()
      ..color = blockColor
      ..style = PaintingStyle.fill;
    final rect = Rect.fromCenter(
        center: Offset(centerX, centerY), width: blockSize.width, height: blockSize.height);
    canvas.drawRect(rect, paint);
  }

  void _drawBackground(Canvas canvas, Size canvasSize, Size cellSize) {
    canvas.drawColor(backgroundColor, BlendMode.src);

    final lineStroke = Paint()
      ..strokeWidth = 1
      ..color = Colors.black87;

    canvas.drawLine(Offset(0, 0), Offset(canvasSize.width, 0), lineStroke);
    canvas.drawLine(
        Offset(canvasSize.width, 0), Offset(canvasSize.width, canvasSize.height), lineStroke);
    canvas.drawLine(
        Offset(canvasSize.width, canvasSize.height), Offset(0, canvasSize.height), lineStroke);
    canvas.drawLine(Offset(0, canvasSize.height), Offset(0, 0), lineStroke);
  }

  @override
  bool shouldRepaint(TetrisPainter oldPainter) => true;
}
