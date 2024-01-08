import 'dart:math';

import 'package:flutter/material.dart';
class ConnectedCircles extends StatelessWidget {
  final List<dynamic> list;
  const ConnectedCircles({super.key,required this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/irrigation_image.jpg')
          )
      ),
      child: CustomPaint(
        painter: CirclesPainter(myList: list),
      ),
    );
  }
}

class CirclesPainter extends CustomPainter {
  final List<dynamic> myList;
  CirclesPainter({required this.myList});
  @override
  // var list = ['RTU PLUS(5)','ORO RTU(5)', 'ORO SMART(2)','SMART PLUS(2)', 'ORO SWITCH(4)', 'ORO WEATHER(2)', 'ORO EXTEND(2)', 'ORO SENSE(2)','ORO PUMP(2)','PUMP PLUS(2)'];
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double mainCircleRadius = 100.0;
    final double connectedCircleRadius = 60.0;
    final double lineOffset = 10.0; // Adjust this value to control the line offset
    final int numberOfCircles = myList.length;

    // Draw the surrounding circles with names
    final connectedCirclePaint = Paint()..color = Colors.orange.shade100;
    final textStyle = TextStyle(color: Colors.black, fontSize: 14.0);
    for (int i = 0; i < numberOfCircles; i++) {
      final angle = (i * 2 * pi) / numberOfCircles;
      final x = centerX + cos(angle) * (mainCircleRadius + connectedCircleRadius * 2.5);
      final y = centerY + sin(angle) * (mainCircleRadius + connectedCircleRadius * 2.5);

      // Draw surrounding circle
      canvas.drawCircle(Offset(x, y), connectedCircleRadius, connectedCirclePaint);

      // Display name for the surrounding circles
      final text = '${myList[i]['name']}(${myList[i]['count']})';
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Draw lines connecting the circles
    for (int i = 0; i < numberOfCircles; i++) {
      final angle = (i * 2 * pi) / numberOfCircles;
      final x = centerX + cos(angle) * (mainCircleRadius + connectedCircleRadius * 2.5);
      final y = centerY + sin(angle) * (mainCircleRadius + connectedCircleRadius * 2.5);

      // Calculate the end point of the line
      final endX = centerX + cos(angle) * (mainCircleRadius - lineOffset);
      final endY = centerY + sin(angle) * (mainCircleRadius - lineOffset);

    }

    // Draw the central circle with a name
    final mainCirclePaint = Paint()..color = Colors.green.shade100;
    canvas.drawCircle(Offset(centerX, centerY), mainCircleRadius, mainCirclePaint);

    final centerText = 'ORO GEM';
    final centerTextPainter = TextPainter(
      text: TextSpan(text: centerText, style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    centerTextPainter.layout();
    centerTextPainter.paint(canvas, Offset(centerX - centerTextPainter.width / 2, centerY - centerTextPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}