import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoredomButton extends StatefulWidget {
  final Function(double) onPressed;
  final double boredomValue;

  const BoredomButton({
    super.key,
    required this.boredomValue,
    required this.onPressed,
  });

  @override
  _BoredomButtonState createState() => _BoredomButtonState();
}

class _BoredomButtonState extends State<BoredomButton> {
  Timer? timer;
  bool isPressed = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          isPressed = true;
        });
        HapticFeedback.lightImpact();

        widget.onPressed(widget.boredomValue + 2);
      },
      onTapUp: (details) {
        setState(() {
          isPressed = false;
        });
      },
      onLongPressDown: (details) {
        timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
          setState(() {
            isPressed = true;
            widget.onPressed(widget.boredomValue + 0.2);
          });
        });
        HapticFeedback.heavyImpact();
      },
      onLongPressUp: () {
        setState(() {
          isPressed = false;
        });
        timer?.cancel();
      },
      onLongPressCancel: () {
        setState(() {
          isPressed = false;
        });
        timer?.cancel();
      },
      child: Image.asset(
        isPressed ? 'assets/images/sprite_1.png' : 'assets/images/sprite_0.png',
        width: 150, // Adjust the width as needed
        height: 150, // Adjust the height as needed
      ),
    );
  }
}
