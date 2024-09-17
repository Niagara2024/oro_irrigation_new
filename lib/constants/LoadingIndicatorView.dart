import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingIndicatorView extends StatelessWidget {
  final bool isVisible;
  final double width;
  final Color indicatorColor;
  final Color backgroundColor;

  const LoadingIndicatorView({
    Key? key,
    required this.isVisible,
    required this.width,
    this.indicatorColor = Colors.blue,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Center(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ),
    );
  }
}