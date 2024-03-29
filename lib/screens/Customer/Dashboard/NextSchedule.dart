import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../ScheduleView.dart';

class NextSchedule extends StatefulWidget {
  const NextSchedule({Key? key, required this.siteData, required this.userID, required this.customerID}) : super(key: key);
  final DashboardModel siteData;
  final int userID, customerID;

  @override
  State<NextSchedule> createState() => _NextScheduleState();
}

class _NextScheduleState extends State<NextSchedule> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: myTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            ListTile(
              tileColor: myTheme.primaryColor.withOpacity(0.2),
              title: const Text('NEXT SCHEDULE IN QUEUE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        tooltip: 'Schedule details',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleViewScreen(deviceId: widget.siteData.deviceId, userId: widget.userID, controllerId: widget.siteData.controllerId, customerId: widget.customerID,),
                            ),
                          );
                        },
                        icon: const Icon(Icons.view_list_outlined)),
                  ]
              ),
            ),
            Container(
              color: Colors.white,
              height: provider.nextSchedule.isNotEmpty? (provider.nextSchedule.length * 45) + 35 : 25,
              child: provider.nextSchedule.isNotEmpty? DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 45.0,
                headingRowHeight: 35.0,
                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
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
                      label: Text('Line', style: TextStyle(fontSize: 13),),
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
                rows: List<DataRow>.generate(provider.nextSchedule.length, (index) => DataRow(cells: [
                  DataCell(Text(provider.nextSchedule[index]['ProgName'])),
                  DataCell(Text(provider.nextSchedule[index]['SchedulingMethod']==1?'No Schedule':provider.nextSchedule[index]['SchedulingMethod']==2?'Schedule by days':'Schedule as run list')),
                  DataCell(Text(provider.nextSchedule[index]['ProgCategory'])),
                  DataCell(Center(child: Text('${provider.nextSchedule[index]['CurrentZone']}'))),
                  DataCell(Center(child: Center(child: Text(provider.nextSchedule[index]['ZoneName'])))),
                  DataCell(Center(child: Text(_convertTime(provider.nextSchedule[index]['StartTime'])))),
                  DataCell(Center(child: Text(provider.nextSchedule[index]['IrrigationDuration_Quantity']))),
                ])),
              ) :
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Next schedule not Available', style: TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _convertTime(String timeString) {
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }
}
