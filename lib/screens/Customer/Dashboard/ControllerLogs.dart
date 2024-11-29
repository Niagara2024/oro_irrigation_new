import 'package:flutter/cupertino.dart';
import '../../../constants/http_service.dart';

class IrrigationAndPumpLog extends StatefulWidget {
  const IrrigationAndPumpLog({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId;
  final int controllerId;

  @override
  State<IrrigationAndPumpLog> createState() => _ListOfLogConfigState();
}

class _ListOfLogConfigState extends State<IrrigationAndPumpLog> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
