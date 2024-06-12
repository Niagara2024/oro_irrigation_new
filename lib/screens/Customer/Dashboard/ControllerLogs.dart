import 'package:flutter/cupertino.dart';
import '../../../constants/http_service.dart';

class ListOfLogConfig extends StatefulWidget {
  const ListOfLogConfig({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId;
  final int controllerId;

  @override
  State<ListOfLogConfig> createState() => _ListOfLogConfigState();
}

class _ListOfLogConfigState extends State<ListOfLogConfig> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
