import 'package:flutter/material.dart';
import 'theme.dart';

class Buttons{
    // ignore: non_constant_identifier_names
  static ButtonStyle elevated_button = ElevatedButton.styleFrom(
    primary: AppColors.primary,
    minimumSize: Size(300, 50),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
  );


  // ignore: non_constant_identifier_names
  static ButtonStyle elevated_button_mini = ElevatedButton.styleFrom(
    primary: AppColors.logo_color,
    minimumSize: Size(100, 50),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
  );
}