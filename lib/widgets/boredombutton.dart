import 'dart:async';

import 'package:flutter/material.dart';

class BoredomButton extends StatefulWidget {
  final Function onPressed;
  final double boredomValue;

  const BoredomButton({super.key, 
    required this.boredomValue,
    required this.onPressed,
  });

  @override
  _BoredomButtonState createState() => _BoredomButtonState();
}

class _BoredomButtonState extends State<BoredomButton> {
  Timer? timer;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onPressed(widget.boredomValue + 2);
        },
        onLongPressDown: (details) {
          print('down');
          timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
            setState(() {
              widget.onPressed(widget.boredomValue + 0.2);
            });
          });
        },
        onLongPressUp: () {
          print('up');
          timer?.cancel();
        },
        onLongPressCancel: () {
          print('cancel');
          timer?.cancel();
        },
        child: Container(
          width: 100, // Adjust the width as needed
          height: 100, // Adjust the height as needed
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: const Border(),
              color: Theme.of(context).colorScheme.primaryContainer),
          child: Center(
            child: Text(
              'I\'m Bored!',
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ));
  }
}
