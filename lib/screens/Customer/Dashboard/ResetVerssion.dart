import 'package:flutter/material.dart';

class ResetVerssion extends StatefulWidget {
  const ResetVerssion({Key? key, this.userId, this.controllerId, this.deviceID}) : super(key: key);

  final dynamic userId, controllerId, deviceID;

  @override
  State<ResetVerssion> createState() => _ResetVerssionState();
}

class _ResetVerssionState extends State<ResetVerssion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
