import 'package:flutter/material.dart';
import 'package:flutter_tetris/game_screen.dart';

class HomeScreen extends StatelessWidget {
  final int highScore;

  const HomeScreen({this.highScore = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        _buildAnimatedBackground(context),
        _buildForeground(context)
      ]
    );    
  }

  Widget _buildAnimatedBackground(BuildContext context) {
    return Container(
      color: Colors.white
    );
  }

  Widget _buildForeground(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Tetris', style: Theme.of(context).textTheme.headline3),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text('High Score: $highScore', style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: Theme.of(context).textTheme.headline4.fontSize
          ))
        ),
        SizedBox(height: 100),
        RaisedButton(
          onPressed: () => _onPlayPressed(context),
          color: Theme.of(context).accentColor,
          child: Text('Play'),
        )
      ]
    );
  }

  void _onPlayPressed(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, _, __) {
        return GameScreen();
      },
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, anim, _, child) {
        return ScaleTransition(
          scale: anim,
          alignment: Alignment.center,
          child: child,
        );
      }
    ));
  }
}