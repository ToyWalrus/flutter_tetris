import 'package:flutter/material.dart';
import 'package:flutter_tetris/game/game_driver.dart';
import 'package:flutter_tetris/tetromino_controller.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .75,
            child: Placeholder()
          ),
          Expanded(
            child: TetrominoController(
              gameDriver: null,
            )
          )
        ]
      )
    );
  }
}