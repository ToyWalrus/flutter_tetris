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
  final Color buttonDisabledColor;
  final IconData icon;
  final double iconSize;

  /// Create a new button with text.
  const CustomButton.text(
      {@required this.text,
      @required this.onPress,
      this.textSize = 24,
      this.buttonInactiveColor = Colors.white,
      this.buttonDisabledColor = Colors.grey,
      this.buttonActiveColor = const Color.fromRGBO(20, 20, 20, 1)})
      : icon = null,
        iconSize = 0;

  /// Create a new icon button.
  const CustomButton.icon(
      {@required this.icon,
      @required this.onPress,
      this.iconSize = 24,
      this.buttonDisabledColor = Colors.grey,
      this.buttonInactiveColor = Colors.black54,
      this.buttonActiveColor = Colors.black})
      : text = null,
        textSize = 0;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool get isTextButton => widget.text != null;

  Function get onPress => widget.onPress ?? () {};

  bool get disabled => widget.onPress == null;

  Color get currentTextColor => currentButtonColor == widget.buttonInactiveColor && !disabled
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
          onPress();

          buttonHeldTimer?.cancel();
          // debounce the first press
          buttonHeldTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
            buttonHeldTimer.cancel();
            buttonHeldTimer = Timer.periodic(Duration(milliseconds: 80), (_) => onPress());
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
          color: disabled ? widget.buttonDisabledColor : currentButtonColor,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
            child: Text(widget.text,
                style: TextStyle(
                    fontSize: widget.textSize,
                    color: currentTextColor,
                    fontWeight: FontWeight.bold))));
  }

  Widget _buildIconButton() {
    return Center(
        child: Icon(
      widget.icon,
      color: disabled ? widget.buttonDisabledColor : currentButtonColor,
      size: widget.iconSize,
    ));
  }
}
