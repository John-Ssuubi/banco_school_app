import 'package:flutter/material.dart';

Color mainColor = const Color.fromARGB(255, 2, 116, 63);
double largefonts = 30;
double normalFontSize = 20;

var schoolname = 'Banco School App';

var whiteText = TextStyle(color: Colors.white);

InputDecoration customDecorationParentForm({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: mainColor,
        fontWeight: FontWeight.bold,
        fontSize: normalFontSize,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mainColor),
      ),
      errorBorder: OutlineInputBorder(
        // Added for better error display
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Added for better error display
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }
