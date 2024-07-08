import 'package:flutter/material.dart';

class ServiceRequestsTable extends StatefulWidget {
  const ServiceRequestsTable({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId, controllerId;

  @override
  State<ServiceRequestsTable> createState() => _ServiceRequestsTableState();
}

class _ServiceRequestsTableState extends State<ServiceRequestsTable> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
