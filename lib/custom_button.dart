import 'dart:async';

import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  /// A callback for when the button is pressed.
  /// It will fire every frame the button press is
  /// held for, with a slight delay after the first
  /// call for debouncing.
  final Function onPress;
  final String text;
  final double textSize;
  final Color buttonInactiveColor;
  final Color buttonActiveColor;
  final IconData icon;
  final double iconSize;

  /// Create a new button with text.
  const CustomButton.text(
      {@required this.text,
      @required this.onPress,
        this.textSize = 24,
      this.buttonInactiveColor = Colors.white,
      this.buttonActiveColor = const Color.fromRGBO(20, 20, 20, 1)})
      : icon = null, iconSize = 0;

  /// Create a new icon button.
  const CustomButton.icon(
      {@required this.icon,
      @required this.onPress,
      this.iconSize = 24,
      this.buttonInactiveColor = Colors.black54,
      this.buttonActiveColor = Colors.black})
      : text = null, textSize = 0;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool get isTextButton => widget.text != null;

  Color get currentTextColor => currentButtonColor == widget.buttonInactiveColor
      ? widget.buttonActiveColor
      : widget.buttonInactiveColor;
  Color currentButtonColor;
  Timer buttonHeldTimer;

  @override
  void initState() {
    super.initState();
    currentButtonColor = widget.buttonInactiveColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) {
          _updateColorTo(widget.buttonActiveColor);
          widget.onPress();

          buttonHeldTimer?.cancel();
          // debounce the first press
          buttonHeldTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
            buttonHeldTimer = Timer.periodic(Duration(milliseconds: 10), (_) => widget.onPress());
          });
        },
        onTapUp: (_) {
          buttonHeldTimer?.cancel();
          _updateColorTo(widget.buttonInactiveColor);
        },
        child: isTextButton ? _buildTextButton() : _buildIconButton());
  }

  void _updateColorTo(Color newColor) => setState(() => currentButtonColor = newColor);

  Widget _buildTextButton() {
    return Container(
        decoration: BoxDecoration(
          color: currentButtonColor,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
            child: Text(widget.text,
                style: TextStyle(fontSize: widget.textSize, color: currentTextColor, fontWeight: FontWeight.bold))));
  }

  Widget _buildIconButton() {
    return Center(
      child: Icon(
        widget.icon,
        color: currentButtonColor,
        size: widget.iconSize,
      )
    );
  }
}
