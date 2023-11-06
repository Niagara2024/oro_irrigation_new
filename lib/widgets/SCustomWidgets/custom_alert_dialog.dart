import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  const CustomAlertDialog({super.key, required this.title, required this.content, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red,),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(content),
      actions: actions,
    );
  }
}
