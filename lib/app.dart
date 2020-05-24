import 'package:flutter/material.dart';
import 'package:flutter_tetris/home_screen.dart';
import 'package:flutter_tetris/theme.dart';

class TetrisApp extends StatelessWidget {
  // https://paletton.com/#uid=71H1+0kmJFs8jT+gzLQtoBuBOrF

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: appTheme,
    );
  }
}