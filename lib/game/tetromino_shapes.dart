import 'package:flutter/material.dart';

enum TetrominoShapes {
  Square,
  T,
  L,
  Back_L,
  Z,
  Back_Z,
  Line
}

Color getColorForShape(TetrominoShapes shape) {
  switch (shape) {    
    case TetrominoShapes.Square: return Colors.lime;
    case TetrominoShapes.T: return Colors.deepPurple;
    case TetrominoShapes.L: return Colors.blue;
    case TetrominoShapes.Back_L: return Colors.orange;
    case TetrominoShapes.Z: return Colors.green;
    case TetrominoShapes.Back_Z: return Colors.red;
    case TetrominoShapes.Line: return Colors.indigo;
    default: throw Exception('Unknown Tetronimo shape: $shape');
  }
}