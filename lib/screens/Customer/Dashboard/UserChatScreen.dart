import 'package:flutter/material.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({Key? key, required this.userId, required this.dealerId, required this.userName}) : super(key: key);

  final int userId, dealerId;
  final String userName;

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
