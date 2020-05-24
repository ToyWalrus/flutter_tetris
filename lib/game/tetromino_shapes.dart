import 'package:flutter/material.dart';

enum TetronimoShapes {
  Square,
  T,
  L,
  Back_L,
  Z,
  Back_Z,
  Line
}

Color getColorForShape(TetronimoShapes shape) {
  switch (shape) {    
    case TetronimoShapes.Square: return Colors.lime;      
    case TetronimoShapes.T: return Colors.deepPurple;      
    case TetronimoShapes.L: return Colors.blue;      
    case TetronimoShapes.Back_L: return Colors.orange;      
    case TetronimoShapes.Z: return Colors.green;      
    case TetronimoShapes.Back_Z: return Colors.red;      
    case TetronimoShapes.Line: return Colors.indigo;      
    default: throw Exception('Unknown Tetronimo shape: $shape');
  }
}