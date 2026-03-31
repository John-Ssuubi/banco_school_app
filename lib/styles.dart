import 'dart:ui';

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


Widget glassButton(IconData icon) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),

        child: Icon(icon),
      ),
    ),
  );
}