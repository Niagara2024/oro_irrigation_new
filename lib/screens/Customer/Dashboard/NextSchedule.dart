import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class NextSchedule extends StatefulWidget {
  const NextSchedule({Key? key, required this.siteData, required this.userID, required this.customerID, required this.programQueue}) : super(key: key);
  final DashboardModel siteData;
  final int userID, customerID;
  final List<ProgramQueue> programQueue;

  @override
  State<NextSchedule> createState() => _NextScheduleState();
}

class _NextScheduleState extends State<NextSchedule> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  height:(widget.programQueue.length * 40) + 55,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      dataRowHeight: 45.0,
                      headingRowHeight: 40.0,
                      headingRowColor: MaterialStateProperty.all<Color>(Colors.orange.shade50),
                      columns: const [
                        DataColumn2(
                            label: Text('Name', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.L
                        ),
                        DataColumn2(
                            label: Text('Method', style: TextStyle(fontSize: 13)),
                            size: ColumnSize.M

                        ),
                        DataColumn2(
                            label: Text('Location', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.S
                        ),
                        DataColumn2(
                            label: Center(child: Text('Zone Name', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('Total(Duration/Flow)', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M
                        ),
                      ],
                      rows: List<DataRow>.generate(widget.programQueue.length, (index) => DataRow(cells: [
                        DataCell(Text(widget.programQueue[index].programName)),
                        DataCell(Text(widget.programQueue[index].schMethod==1?'No Schedule':widget.programQueue[index].schMethod==2?'Schedule by days':
                        widget.programQueue[index].schMethod==3?'Schedule as run list':'Day count schedule')),
                        DataCell(Text(widget.programQueue[index].programCategory)),
                        DataCell(Center(child: Text('${widget.programQueue[index].currentZone}'))),
                        DataCell(Center(child: Center(child: Text(widget.programQueue[index].zoneName)))),
                        DataCell(Center(child: Text(_convertTime(widget.programQueue[index].startTime)))),
                        DataCell(Center(child: Text(widget.programQueue[index].totalDurORQty))),
                      ])),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('NEXT SCHEDULE IN QUEUE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _convertTime(String timeString) {
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }
}
