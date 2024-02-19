import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../ScheduleView.dart';

class CurrentSchedule extends StatefulWidget {
  const CurrentSchedule({Key? key, required this.userID, required this.customerID, required this.siteData}) : super(key: key);
  final int userID, customerID;
  final DashboardModel siteData;

  @override
  State<CurrentSchedule> createState() => _CurrentScheduleState();
}

class _CurrentScheduleState extends State<CurrentSchedule> {
  final StreamController<String> streamController = StreamController<String>();
  Timer? timer;



  @override
  void dispose() {
    timer?.cancel();
    streamController.close();
    //print('streamController');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.white,
            title: const Text('CURRENT SCHEDULE', style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
            trailing: provider.currentSchedule.isNotEmpty ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/GiffFile/water_drop_animation.gif'),
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
            ) :
            Row(
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
          const Divider(height: 0),
          Container(
            color: Colors.white,
            height: provider.currentSchedule.isNotEmpty? (provider.currentSchedule.length * 55) + 35 : 50,
            child: provider.currentSchedule.isNotEmpty? SizedBox(
              height: (provider.currentSchedule.length * 55) + 35,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 550,
                dataRowHeight: 55.0,
                headingRowHeight: 35.0,
                headingRowColor: MaterialStateProperty.all<Color>(myTheme.primaryColor.withOpacity(0.1)),
                columns: const [
                  DataColumn2(
                      label: Text('Program', style: TextStyle(fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                      label: Text('Line', style: TextStyle(fontSize: 13),),
                      fixedWidth: 70
                  ),
                  DataColumn2(
                      label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 45
                  ),
                  DataColumn2(
                      label: Center(child: Text('Zone Name', style: TextStyle(fontSize: 13),)),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                      label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 100
                  ),
                  DataColumn2(
                      label: Center(child: Text('Duration', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 100
                  ),
                  DataColumn2(
                      label: Center(child: Text('Left', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 100
                  ),
                  DataColumn2(
                      label: Center(child: Text('Valve', style: TextStyle(fontSize: 13),)),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                      label: Center(child: Text('Action', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 50
                  ),
                ],
                rows: List<DataRow>.generate(provider.currentSchedule.length, (index) => DataRow(cells: [
                  DataCell(Text(provider.currentSchedule[index]['ProgName'])),
                  DataCell(Text(provider.currentSchedule[index]['ProgCategory'])),
                  DataCell(Center(child: Text('${provider.currentSchedule[index]['CurrentZone']}/${provider.currentSchedule[index]['TotalZone']}'))),
                  DataCell(Center(child: Text(provider.currentSchedule[index]['ZoneName']))),
                  DataCell(Center(child: Text(_convertTime(provider.currentSchedule[index]['StartTime'])))),
                  DataCell(Center(child: Text(provider.currentSchedule[index]['Duration_Qty']))),
                  DataCell(Center(child: Text(provider.currentSchedule[index]['Duration_QtyLeft']))),
                  DataCell(Center(child: GridView.count(
                    crossAxisCount: 3,
                    children: List.generate(
                      provider.currentSchedule[index]['Valve'].length,
                          (vIndex) => Center(
                            child : IconButton(tooltip: '${provider.currentSchedule[index]['Valve'][vIndex]['Name']}', onPressed: (){}, icon: CircleAvatar(
                              backgroundColor: provider.currentSchedule[index]['Valve'][vIndex]['Status']==0 ? Colors.grey.shade100 :
                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==1 ? Colors.green.shade100 :
                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==2 ? Colors.orange.shade100 :
                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==3 ? Colors.red.shade100 : Colors.black12,
                              backgroundImage: const AssetImage('assets/images/valve.png'),
                            )),

                      ),
                    ),
                  )/*PopupMenuButton(
                    tooltip: 'Details',
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Center(
                            child: SizedBox(
                              width: 130,
                              height: ((provider.currentSchedule[index]['Valve'].length + 1) ~/ 2) * 75.0,
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                ),
                                itemCount: provider.currentSchedule[index]['Valve'].length, // Number of items
                                itemBuilder: (context, vIndex) {
                                  return GridTile(
                                    child: Column(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage('assets/images/valve.png'),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor: provider.currentSchedule[index]['Valve'][vIndex]['Status']==0 ? Colors.grey :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==1 ? Colors.green :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==2 ? Colors.orange :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==3 ? Colors.redAccent : Colors.black12,
                                            ),
                                            const SizedBox(width: 3),
                                            Text('${provider.currentSchedule[index]['Valve'][vIndex]['Name']}(${provider.currentSchedule[index]['Valve'][vIndex]['SNo']})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    child: const Icon(Icons.info_outline),
                  )*/)),
                  DataCell(Center(child: Center(
                    child: IconButton(tooltip:'Skip next',onPressed: (){
                      String payload = '${provider.currentSchedule[index]['ProgType']}, 0';
                      String payLoadFinal = jsonEncode({
                        "3700": [{"3701": payload}]
                      });
                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                    }, icon: const Icon(Icons.skip_next_outlined)),
                  ))),
                ])),
              ),
            ):
            const Center(child: Text('Current Schedule not Available')),
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

  String durationUpdatingFunction(leftDuration) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      List<String> parts = leftDuration.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      if (seconds > 0) {
        seconds--;
      } else {
        if (minutes > 0) {
          minutes--;
          seconds = 59;
        } else {
          if (hours > 0) {
            hours--;
            minutes = 59;
            seconds = 59;
          }
        }
      }

      String updatedDurationQtyLeft = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      leftDuration = updatedDurationQtyLeft;
      streamController.sink.add(updatedDurationQtyLeft);
      if (updatedDurationQtyLeft == '00:00:00') {
        timer?.cancel();
      }
    });

    return leftDuration;
  }

}
