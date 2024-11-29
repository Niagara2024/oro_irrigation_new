import 'package:flutter/material.dart';

class TicketHomePage extends StatefulWidget {
  const TicketHomePage({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId, controllerId;

  @override
  State<TicketHomePage> createState() => _TicketHomePageState();
}

class _TicketHomePageState extends State<TicketHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
