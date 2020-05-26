import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/game_driver.dart';
import 'package:flutter_tetris/game/tetris_grid.dart';
import 'package:flutter_tetris/game/tetris_painter.dart';
import 'package:flutter_tetris/game/tetromino.dart';
import 'package:flutter_tetris/game/tetromino_shapes.dart';
import 'package:flutter_tetris/tetromino_controller.dart';

class GameScreen extends StatefulWidget {
  final int numColumns;
  final int numRows;

  const GameScreen({this.numColumns = 10, this.numRows = 18});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  TetrisGrid grid;
  GameDriver gameDriver;

  Tetromino get nextShape => Tetromino(shape: gameDriver.nextShape, gameGrid: grid, spawn: false);
  final double blockSizeRatio = 0.9;

  @override
  void initState() {
    super.initState();
    grid = TetrisGrid(height: widget.numRows, width: widget.numColumns);
    gameDriver = GameDriver(grid: grid, onUpdate: () => setState((){}), tickInterval: 1000);
    Future.delayed(Duration(milliseconds: 500)).then(_showStartGameDialog);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(children: [
      Expanded(child: _buildTopArea()),
      _buildGameView(screenSize.width, screenSize.height * .75),
      Expanded(child: TetrominoController(gameDriver))
    ]));
  }

  Widget _buildTopArea() {
    final iconSize = 20.0;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              onPressed: _onCloseGameScreen,
              icon: Icon(Icons.close, size: iconSize),
            ),
          ),
          Expanded(child: _buildNextTetrominoView()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: 150,
            child: Row(
              children: [
                IconButton(
                  onPressed: gameDriver.isActive ?  _pauseGame : null,
                  icon: Icon(Icons.pause, size: iconSize)
                ),
                IconButton(
                  onPressed: gameDriver.isActive ? null : _resumeGame,
                  icon: Icon(Icons.play_arrow, size: iconSize)
                )
              ]
            )
          )
        ]);
  }

  Widget _buildGameView(double width, double height) {
    return CustomPaint(
      size: Size(width, height),
      painter: TetrisPainter(
        grid: grid,
        currentPiece: gameDriver.currentPiece,
        blockSizeFractionOfCell: blockSizeRatio,
        backgroundColor: Colors.white
      ),
    );
  }

  Widget _buildNextTetrominoView() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Next:', style: TextStyle(fontWeight: FontWeight.bold)),
          CustomPaint(
            painter: _NextTetrominoPainter(nextShape, blockSizeRatio),
            size: Size.square(50),
          )
        ]);
  }

  void _onCloseGameScreen() {
    gameDriver.stopGame();
    Navigator.of(context).pop();
  }

  void _pauseGame() => gameDriver.stopGame();
  void _resumeGame() => gameDriver.resumeGame();

  void _showStartGameDialog(_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        title: Text('Ready?'),
        actions: [
          FlatButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Future.delayed(Duration(milliseconds: 500));
              gameDriver.startGame();
            },
            child: Text('Start')
          )
        ]
      )
    );
  }
}

class _NextTetrominoPainter extends CustomPainter {
  final Tetromino piece;
  final double blockSizeRatio;

  const _NextTetrominoPainter(this.piece, this.blockSizeRatio);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Sets the canvas so that (0,0) is bottom left
    final shape = piece.shape;
    Size cellSize;
    if (shape == TetrominoShapes.Line) {
      cellSize = Size(canvasSize.width / 4, canvasSize.height / 4);
    } else if (shape == TetrominoShapes.Square) {
      cellSize = Size(canvasSize.width / 2, canvasSize.height / 2);
    } else {
      cellSize = Size(canvasSize.width / 3, canvasSize.height / 3);
    }
    final blockSize = cellSize * blockSizeRatio;

    canvas.translate(0, canvasSize.height);
    canvas.scale(1, -1);

    for (final block in piece.blocks) {
      final cellCenterOffsetX = cellSize.width / 2;
      final cellCenterOffsetY = cellSize.height / 2;
      final centerX = cellSize.width * block.x + cellCenterOffsetX;
      final centerY = cellSize.height * block.y + cellCenterOffsetY;

      final paint = Paint()
        ..color = block.displayColor
        ..style = PaintingStyle.fill;
      final rect = Rect.fromCenter(
          center: Offset(centerX, centerY), width: blockSize.width, height: blockSize.height);

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_NextTetrominoPainter oldDelegate) =>
      piece != oldDelegate.piece || blockSizeRatio != oldDelegate.blockSizeRatio;
}
