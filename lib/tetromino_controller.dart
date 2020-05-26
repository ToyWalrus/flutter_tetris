import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tetris/custom_button.dart';
import 'package:flutter_tetris/game/game_driver.dart';

class TetrominoController extends StatelessWidget {
  final GameDriver gameDriver;
  const TetrominoController(this.gameDriver);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(flex: 1, child: _buildSpeedUpButton()),
      Expanded(flex: 2, child: _buildControllerRow())
    ]);
  }

  Widget _buildSpeedUpButton() {
    return Row(children: [
      Expanded(
          child: CustomButton.text(
              text: 'Speed up',
              textSize: 20,
              onPress: () => null, //gameDriver.movePieceDown(),
              buttonActiveColor: Colors.blue,
              buttonInactiveColor: Colors.white))
    ]);
  }

  Widget _buildControllerRow() {
    final inactiveIconColor = Colors.grey[900];
    final activeIconColor = Colors.blue;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          CustomButton.icon(
            icon: Icons.arrow_back,
            onPress: () => null,
            //gameDriver.movePieceLeft(),
            buttonInactiveColor: inactiveIconColor,
            buttonActiveColor: activeIconColor,
            iconSize: 40,
          ),
          Transform(
              transform: Matrix4.rotationY(pi),
              origin: Offset(20, 20),
              child: CustomButton.icon(
                icon: Icons.refresh,
                onPress: () => null,
                //gameDriver.rotatePieceLeft(),
                buttonInactiveColor: inactiveIconColor,
                buttonActiveColor: activeIconColor,
                iconSize: 40,
              )),
          CustomButton.icon(
            icon: Icons.refresh,
            onPress: () => null,
            //gameDriver.rotatePieceRight(),
            buttonInactiveColor: inactiveIconColor,
            buttonActiveColor: activeIconColor,
            iconSize: 40,
          ),
          CustomButton.icon(
            icon: Icons.arrow_forward,
            onPress: () => null,
            //gameDriver.movePieceRight(),
            buttonInactiveColor: inactiveIconColor,
            buttonActiveColor: activeIconColor,
            iconSize: 40,
          )
        ]));
  }
}
