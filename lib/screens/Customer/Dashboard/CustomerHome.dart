import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.currentMaster}) : super(key: key);
  final MasterData currentMaster;

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {

  Timer? _timer;
  late double progress;

  @override
  void initState() {
    super.initState();
    progress = 0.0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateDurationQtyLeft();
    });
  }

  void _updateDurationQtyLeft() {
    bool allOnDelayLeftZero = true;
    try {
      MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
      final currentSchedule = payloadProvider.currentSchedule;
      print(currentSchedule[0].duration_QtyLeft);

      if(currentSchedule.isNotEmpty){
        for (int i = 0; i < currentSchedule.length; i++) {
          if(currentSchedule[i].message=='Running.'){
            if (currentSchedule[i].duration_QtyLeft.contains(':')) {
              List<String> parts = currentSchedule[i].duration_QtyLeft.split(':');
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
              if (currentSchedule[i].duration_QtyLeft != '00:00:00') {
                setState(() {
                  progress = seconds / seconds;
                  currentSchedule[i].duration_QtyLeft = updatedDurationQtyLeft;

                  Duration durationQty = parseDuration(currentSchedule[i].duration_Qty);
                  Duration durationQtyLeft = parseDuration(currentSchedule[i].duration_QtyLeft);

                  progress = calculateProgress(durationQty, durationQtyLeft);

                });
              }
            }
            else {
              double remainFlow = double.parse(currentSchedule[i].duration_QtyLeft);
              if (remainFlow > 0) {
                double flowRate = double.parse(currentSchedule[i].avgFlwRt);
                remainFlow -= flowRate;
                String formattedFlow = remainFlow.toStringAsFixed(2);
                setState(() {
                  currentSchedule[i].duration_QtyLeft = formattedFlow;
                  progress = (int.parse(currentSchedule[i].duration_Qty) - remainFlow) / int.parse(currentSchedule[i].duration_Qty);
                });
              } else {
                currentSchedule[i].duration_QtyLeft = '0.00';
              }
            }
            allOnDelayLeftZero = false;
          }else{
            //pump on delay or filter running
          }
        }
      }
    } catch (e) {
      print(e);
    }

    /*if (allOnDelayLeftZero) {
      _timer?.cancel();
    }*/
  }

  Duration parseDuration(String duration) {
    List<String> parts = duration.split(':');
    int hours = parts.length > 2 ? int.parse(parts[0]) : 0;
    int minutes = parts.length > 1 ? int.parse(parts[parts.length - 2]) : 0;
    int seconds = parts.isNotEmpty ? int.parse(parts[parts.length - 1]) : 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  double calculateProgress(Duration total, Duration left) {
    return (total.inSeconds - left.inSeconds) / total.inSeconds;
  }

  @override
  Widget build(BuildContext context) {

    _startTimer();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: widget.currentMaster.irrigationLine.length - 1,
        itemBuilder: (context, lInx) {
          final irrigationLine = widget.currentMaster.irrigationLine[lInx + 1];
          final filteredCurrentSchedule = filterCurrentScheduleByCategory(Provider.of<MqttPayloadProvider>(context).currentSchedule, irrigationLine.hid);

          return Card(
            elevation: 4,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(lInx==0?Icons.water_drop_outlined:CupertinoIcons.pause_circle, color: lInx==0?Colors.blue:Colors.red,),
                    title: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(irrigationLine.name),
                        ),
                        Flexible(
                          flex: 2,
                          child: Center(child: Text(lInx==0?'Controller running as per schedule':'Program paused by alert',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: lInx==0? myTheme.primaryColorDark:Colors.red),)),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 150,
                          child: LinearProgressIndicator(
                            value: progress, // Value of the indicator (from 0.0 to 1.0)
                            backgroundColor: Colors.grey[300], // Background color of the indicator
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Color of the indicator
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Text('${(progress * 100).toStringAsFixed(1)}%',style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    /*onTap: () {
                      print('Tapped on ${widget.currentMaster.irrigationLine[index].name}');
                    },*/
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: SizedBox(
                      height: 85,
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 600,
                        dataRowHeight: 45.0,
                        headingRowHeight: 40.0,
                        headingRowColor: MaterialStateProperty.all<Color>(Colors.green.shade50),
                        columns: const [
                          DataColumn2(
                              label: Text('Program Name', style: TextStyle(fontSize: 13),),
                              size: ColumnSize.L
                          ),
                          DataColumn2(
                            label: Text('Pressure', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Text('Zone', style: TextStyle(fontSize: 13)),
                            size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Center(child: Text('Current Zone', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Center(child: Text('RTC', style: TextStyle(fontSize: 13),)),
                            fixedWidth: 75,
                          ),
                          DataColumn2(
                            label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Center(child: Text('Total(D/F)', style: TextStyle(fontSize: 13),)),
                              size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Center(child: Text('Next-in-Queue', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M,
                          ),
                        ],
                        rows: List<DataRow>.generate(filteredCurrentSchedule.length, (index) => DataRow(cells: [
                          DataCell(Text(filteredCurrentSchedule[index].programName)),
                          const DataCell(Text('1.0 bar')),
                          DataCell(Text('${filteredCurrentSchedule[index].currentZone}/${filteredCurrentSchedule[index].totalZone}')),
                          DataCell(Center(child: Text(filteredCurrentSchedule[index].zoneName))),
                          DataCell(Center(child: Text(formatRtcValues(filteredCurrentSchedule[index].currentRtc, filteredCurrentSchedule[index].totalRtc)))),
                          DataCell(Center(child: Text(formatRtcValues(filteredCurrentSchedule[index].currentCycle, filteredCurrentSchedule[index].totalCycle)))),
                          DataCell(Center(child: Text(filteredCurrentSchedule[index].duration_Qty))),
                          DataCell(Center(child: Text(filteredCurrentSchedule[index].zoneName))),
                        ])),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<CurrentScheduleModel> filterCurrentScheduleByCategory(List<CurrentScheduleModel> cs, String category) {
    return cs.where((cs) => cs.programCategory.contains(category)).toList();
  }

  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
    }
  }

}
