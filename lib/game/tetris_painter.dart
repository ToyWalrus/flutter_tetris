import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/tetris_block.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';
import 'package:flutter_tetris/game/tetromino.dart';

class TetrisPainter extends CustomPainter {
  final TetrisGrid grid;
  final Tetromino currentPiece;
  final Color backgroundColor;
  final double blockSizeFractionOfCell;

  TetrisPainter({
    @required this.grid,
    @required this.currentPiece,
    @required this.backgroundColor,
    this.blockSizeFractionOfCell = 0.9
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cellWidth = canvasSize.width / grid.width;
    final cellHeight = canvasSize.height / grid.height;
    final cellSize = Size(cellWidth, cellHeight);
    final blockSize = Size(cellSize.width * blockSizeFractionOfCell, cellSize.height * blockSizeFractionOfCell);

    // Sets the canvas so that (0,0) is bottom left
    canvas.translate(0, canvasSize.height);
    canvas.scale(1, -1);

    _drawBackground(canvas, canvasSize, cellSize);
    _drawGrid(canvas, cellSize, blockSize);
    _drawCurrentPiece(canvas, cellSize, blockSize);
  }

  void _drawGrid(Canvas canvas, Size cellSize, Size blockSize) {
    final cellCenterOffsetX = cellSize.width / 2;
    final cellCenterOffsetY = cellSize.height / 2;

    final blockGrid = grid.getGrid();
    for (final column in blockGrid) {
      for (final block in column) {        
        final cellCenterX = cellSize.width * block.x + cellCenterOffsetX;
        final cellCenterY = cellSize.height * block.y + cellCenterOffsetY;
        _drawBlock(canvas, block, cellCenterX, cellCenterY, blockSize);
      }
    }
  }

  void _drawCurrentPiece(Canvas canvas, Size cellSize, Size blockSize) {
    final cellCenterOffsetX = cellSize.width / 2;
    final cellCenterOffsetY = cellSize.height / 2;
    for (final block in currentPiece.blocks) {
      final cellCenterX = cellSize.width * block.x + cellCenterOffsetX;
      final cellCenterY = cellSize.height * block.y + cellCenterOffsetY;
      _drawBlock(canvas, block, cellCenterX, cellCenterY, blockSize);
    }
  }

  void _drawBlock(Canvas canvas, TetrisBlock block, double centerX, double centerY, Size blockSize) {
    final paint = Paint()
      ..color = block.displayColor
      ..style = PaintingStyle.fill;
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY), 
      width: blockSize.width, 
      height: blockSize.height
    );
    canvas.drawRect(rect, paint);
  }

  void _drawBackground(Canvas canvas, Size canvasSize, Size cellSize) {
    canvas.drawColor(backgroundColor, BlendMode.src);

    final numVerticalLines = grid.width - 1;
    final numHorizontalLines = grid.height - 1;
    final lineStroke = Paint()
      ..strokeWidth = 1
      ..color = Colors.black87;

    for (int i = 1; i <= numVerticalLines; ++i) {
      final xOffset = cellSize.width * i;
      canvas.drawLine(Offset(xOffset, 0), Offset(xOffset, canvasSize.height), lineStroke);
    }

    for (int i = 1; i <= numHorizontalLines; ++i) {
      final yOffset = cellSize.height * i;
      canvas.drawLine(Offset(0, yOffset), Offset(canvasSize.width, yOffset), lineStroke);
    }
  }

  @override
  bool shouldRepaint(TetrisPainter oldPainter) => 
    currentPiece != oldPainter.currentPiece || 
    grid.isDifferentThan(oldPainter.grid) ||
    backgroundColor != oldPainter.backgroundColor;
}