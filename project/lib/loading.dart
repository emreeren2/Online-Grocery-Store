import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_v1/theme.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SpinKitFadingCube( // SpinKitDoubleBounce
          color: AppColors.logo_color,
          size: 50.0,
        ),
      ),
    );
  }
}