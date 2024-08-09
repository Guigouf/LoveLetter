import 'package:flutter/material.dart';

class AppStyle {

  static final ButtonStyle _buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.deepPurpleAccent[100];
          } else {
            return Colors.deepPurpleAccent;
          }
        }),
    minimumSize: WidgetStateProperty.all<Size>(const Size(150, 35)),
    padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 30)),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
  );

  static TextButton createOkButton(final Function functionOnOkPress) {
    return TextButton(
        onPressed: () => functionOnOkPress(),
        style: _buttonStyle,
        child: const Text("OK",
            style: TextStyle(color: Colors.white, fontSize: 20)));
  }
}