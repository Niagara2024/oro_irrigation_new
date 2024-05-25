import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/DurationNotifier.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class CurrentSchedule extends StatefulWidget {
  const CurrentSchedule({Key? key, required this.siteData, required this.customerID}) : super(key: key);
  final DashboardModel siteData;
  final int customerID;

  @override
  State<CurrentSchedule> createState() => _CurrentScheduleState();
}

class _CurrentScheduleState extends State<CurrentSchedule> {

  Timer? _timer;

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
    final currentSchedule = Provider.of<MqttPayloadProvider>(context, listen: false).currentSchedule;
    final durationNotifier = Provider.of<DurationNotifier>(context, listen: false);
    if(currentSchedule.isNotEmpty){
      for (int i = 0; i < currentSchedule.length; i++) {
        if (currentSchedule[i]['Duration_QtyLeft'] != null) {
          if ('${currentSchedule[i]['Duration_QtyLeft']}'.contains(':')) {
            List<String> parts = currentSchedule[i]['Duration_QtyLeft'].split(':');
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
            if (currentSchedule[i]['Duration_QtyLeft'] != '00:00:00') {
              durationNotifier.updateDuration(updatedDurationQtyLeft);
              currentSchedule[i]['Duration_QtyLeft'] = updatedDurationQtyLeft;
            } else {
              _timer?.cancel();
              durationNotifier.updateDuration('00:00:00');
              currentSchedule[i]['Duration_QtyLeft'] = '00:00:00';
            }
          } else {
            double remainFlow = 0.0;
            if (currentSchedule[i]['Duration_QtyLeft'] is int) {
              remainFlow = currentSchedule[i]['Duration_QtyLeft'].toDouble();
            } else if (currentSchedule[i]['Duration_QtyLeft'] is String) {
              remainFlow = double.parse(currentSchedule[i]['Duration_QtyLeft']);
            } else {
              remainFlow = currentSchedule[i]['Duration_QtyLeft'];
            }

            if (remainFlow > 0) {
              double flowRate = currentSchedule[i]['AverageFlowRate'] is String
                  ? double.parse(currentSchedule[i]['AverageFlowRate'])
                  : currentSchedule[i]['AverageFlowRate'];
              remainFlow -= flowRate;
              String formattedFlow = remainFlow.toStringAsFixed(2);
              durationNotifier.updateDuration(formattedFlow);
              currentSchedule[i]['Duration_QtyLeft'] = formattedFlow;
            } else {
              durationNotifier.updateDuration('0.00');
              currentSchedule[i]['Duration_QtyLeft'] = '0.00';
              _timer?.cancel();
            }
          }
        }
        else{
          durationNotifier.updateDuration('00000');
          currentSchedule[i]['Duration_QtyLeft'] = '00000';
          _timer?.cancel();
        }
      }
    }else{
      durationNotifier.updateDuration('00000');
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;
    _startTimer();
    return currentSchedule.isNotEmpty? Padding(
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
                  height: currentSchedule.isNotEmpty? (currentSchedule.length * 45) + 45 : 50,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    dataRowHeight: 45.0,
                    headingRowHeight: 40.0,
                    headingRowColor: MaterialStateProperty.all<Color>(Colors.green.shade50),
                    columns: const [
                      DataColumn2(
                          label: Text('Name', style: TextStyle(fontSize: 13),),
                          size: ColumnSize.L
                      ),
                      DataColumn2(
                          label: Text('Location', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.S
                      ),
                      DataColumn2(
                          label: Text('Zone', style: TextStyle(fontSize: 13),),
                          size: ColumnSize.S
                      ),
                      DataColumn2(
                          label: Text('Zone Name', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.M
                      ),
                      DataColumn2(
                        label: Center(child: Text('RTC', style: TextStyle(fontSize: 13),)),
                        fixedWidth: 75,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                        fixedWidth: 75,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                          size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Total (D/F)', style: TextStyle(fontSize: 13),)),
                        fixedWidth: 90,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Remaining', style: TextStyle(fontSize: 13),)),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                          label: Center(child: Text('')),
                          fixedWidth: 90,
                      ),
                    ],
                    rows: List<DataRow>.generate(currentSchedule.length, (index) => DataRow(cells: [
                      DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(currentSchedule[index]['ProgName']),
                              Text('${getContentByCode(currentSchedule[index]['ProgramStartStopReason'])} - ${currentSchedule[index]['ProgramStartStopReason']}', style: const TextStyle(fontSize: 11, color: Colors.black),),
                            ],
                          )
                      ),
                      DataCell(Text(currentSchedule[index]['ProgCategory'])),
                      DataCell(Text('${currentSchedule[index]['CurrentZone']}/${currentSchedule[index]['TotalZone']}')),
                      DataCell(Text(currentSchedule[index]['ZoneName'])),
                      DataCell(Center(child: Text(formatRtcValues(currentSchedule[index]['CurrentRtc'],currentSchedule[index]['TotalRtc'])))),
                      DataCell(Center(child: Text(formatRtcValues(currentSchedule[index]['CurrentCycle'],currentSchedule[index]['TotalCycle'])))),
                      DataCell(Center(child: Text(_convertTime(currentSchedule[index]['StartTime'])))),
                      DataCell(Center(child: Text('${currentSchedule[index]['Duration_Qty']}'))),
                      DataCell(Center(child: ValueListenableBuilder<String>(
                        valueListenable: Provider.of<DurationNotifier>(context).leftDurationOrFlow,
                        builder: (context, value, child) {
                          return Text(value, style: const TextStyle(fontSize: 20));
                        },
                      ),)),
                      DataCell(Center(
                        child: currentSchedule[index]['ProgName']=='StandAlone - Manual'?
                        MaterialButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          onPressed: currentSchedule[index]['Message']=='Running.'? (){
                            String payload = '0,0,0,0';
                            String payLoadFinal = jsonEncode({
                              "800": [{"801": payload}]
                            });
                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                            Map<String, dynamic> manualOperation = {
                              "programName": 'Default',
                              "programId": 0,
                              "startFlag":0,
                              "method": 1,
                              "time": '00:00:00',
                              "flow": '0',
                              "selected": [],
                            };
                            sentManualModeToServer(manualOperation);
                          } : null,
                          child: const Text('Stop'),
                        ):
                        '${currentSchedule[index]['ProgName']}'.contains('StandAlone') ?
                        MaterialButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            String? prgOffPayload = prefs.getString(currentSchedule[index]['ProgName']);
                            String payLoadFinal = jsonEncode({
                              "3900": [{"3901": prgOffPayload}]
                            });
                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                            Map<String, dynamic> manualOperation = {
                              "programName": currentSchedule[index]['ProgName'],
                              "programId": currentSchedule[index]['SNo'],
                              "startFlag":0,
                              "method": 1,
                              "time": '00:00:00',
                              "flow": '0',
                              "selected": [],
                            };
                            sentManualModeToServer(manualOperation);
                            prefs.remove(currentSchedule[index]['ProgName']);
                          },
                          child: const Text('Stop'),
                        ):
                        MaterialButton(
                          color: Colors.green,
                          textColor: Colors.white,
                          onPressed: currentSchedule[index]['Message']=='Running.'? (){
                            String payload = '${currentSchedule[index]['ScheduleS_No']},0';
                            String payLoadFinal = jsonEncode({
                              "3700": [{"3701": payload}]
                            });
                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                          } : null,
                          child: const Text('Skip'),
                        ),
                      )),
                    ])),
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
                      color: Colors.green.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('CURRENT SCHEDULE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    ) : const SizedBox();
  }

  /*@override
  Widget build(BuildContext context) {
    final currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;
    return currentSchedule.isNotEmpty? Column(
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
                height: currentSchedule.isNotEmpty ? (currentSchedule.length * 148) : 45,
                child: currentSchedule.isNotEmpty ? Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: ListView.builder(
                    itemCount: currentSchedule.length,
                    itemBuilder: (BuildContext context, int csIndex) {
                      return Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width-160,
                            height: 85,
                            child: DataTable2(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 600,
                              dataRowHeight: 45.0,
                              headingRowHeight: 40.0,
                              headingRowColor: MaterialStateProperty.all<Color>(Colors.green.shade50),
                              columns: [
                                const DataColumn2(
                                    label: Text('Name', style: TextStyle(fontSize: 13),),
                                    size: ColumnSize.L
                                ),
                                const DataColumn2(
                                    label: Text('Location', style: TextStyle(fontSize: 13)),
                                    size: ColumnSize.S
                                ),
                                const DataColumn2(
                                    label: Text('Zone', style: TextStyle(fontSize: 13),),
                                    size: ColumnSize.S
                                ),
                                const DataColumn2(
                                    label: Text('Zone Name', style: TextStyle(fontSize: 13)),
                                    size: ColumnSize.M
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('RTC', style: TextStyle(fontSize: 13),)),
                                    fixedWidth: 75,
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                                    fixedWidth: 75,
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                                    size: ColumnSize.M
                                ),
                                DataColumn2(
                                    label: Center(child: Text('${currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 'Total Duration(hh:mm:ss)' : 'Total Flow(Liters)', style: const TextStyle(fontSize: 13),)),
                                    size: ColumnSize.L
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('')),
                                    fixedWidth: 90
                                ),
                              ],
                              rows: List<DataRow>.generate(1, (lsIndex) => DataRow(cells: [
                                DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(currentSchedule[csIndex]['ProgName']),
                                        Text('${getContentByCode(currentSchedule[csIndex]['ProgramStartStopReason'])} - ${currentSchedule[csIndex]['ProgramStartStopReason']}', style: const TextStyle(fontSize: 11, color: Colors.black),),
                                      ],
                                    )
                                ),
                                DataCell(Text(currentSchedule[csIndex]['ProgCategory'])),
                                DataCell(Text('${currentSchedule[csIndex]['CurrentZone']}/${currentSchedule[csIndex]['TotalZone']}')),
                                DataCell(Text(currentSchedule[csIndex]['ZoneName'])),
                                DataCell(Center(child: Text(formatRtcValues(currentSchedule[csIndex]['CurrentRtc'],currentSchedule[csIndex]['TotalRtc'])))),
                                DataCell(Center(child: Text(formatRtcValues(currentSchedule[csIndex]['CurrentCycle'],currentSchedule[csIndex]['TotalCycle'])))),
                                DataCell(Center(child: Text(_convertTime(currentSchedule[csIndex]['StartTime'])))),
                                DataCell(Center(child: Text('${currentSchedule[csIndex]['Duration_Qty']}'))),
                                DataCell(Center(
                                  child: currentSchedule[csIndex]['ProgName']=='StandAlone - Manual'?
                                  MaterialButton(
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    onPressed: currentSchedule[csIndex]['Message']=='Running.'? (){
                                      String payload = '0,0,0,0';
                                      String payLoadFinal = jsonEncode({
                                        "800": [{"801": payload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                                      Map<String, dynamic> manualOperation = {
                                        "programName": 'Default',
                                        "programId": 0,
                                        "startFlag":0,
                                        "method": 1,
                                        "time": '00:00:00',
                                        "flow": '0',
                                        "selected": [],
                                      };
                                      sentManualModeToServer(manualOperation);
                                    } : null,
                                    child: const Text('Stop'),
                                  ):
                                  '${currentSchedule[csIndex]['ProgName']}'.contains('StandAlone') ?
                                  MaterialButton(
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      String? prgOffPayload = prefs.getString(currentSchedule[csIndex]['ProgName']);
                                      String payLoadFinal = jsonEncode({
                                        "3900": [{"3901": prgOffPayload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                                      Map<String, dynamic> manualOperation = {
                                        "programName": currentSchedule[csIndex]['ProgName'],
                                        "programId": currentSchedule[csIndex]['SNo'],
                                        "startFlag":0,
                                        "method": 1,
                                        "time": '00:00:00',
                                        "flow": '0',
                                        "selected": [],
                                      };
                                      sentManualModeToServer(manualOperation);
                                      prefs.remove(currentSchedule[csIndex]['ProgName']);
                                    },
                                    child: const Text('Stop'),
                                  ):
                                  MaterialButton(
                                    color: Colors.green,
                                    textColor: Colors.white,
                                    onPressed: currentSchedule[csIndex]['Message']=='Running.'? (){
                                      String payload = '${currentSchedule[csIndex]['ScheduleS_No']},0';
                                      String payLoadFinal = jsonEncode({
                                        "3700": [{"3701": payload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                                    } : null,
                                    child: const Text('Skip'),
                                  ),
                                )),
                              ])),
                            ),
                          ),
                          const Divider(height: 0),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 60,
                            child :  Column(
                              children: [
                                Row(
                                  children: [
                                    if((currentSchedule[csIndex].containsKey('MV') && currentSchedule[csIndex]['MV'].length > 0))
                                      for(int mvIndex=0; mvIndex<currentSchedule[csIndex]['MV'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('MV', currentSchedule[csIndex]['MV'][mvIndex]['Status'],
                                              currentSchedule[csIndex]['MV'][mvIndex]['Name']),
                                        ),

                                    if((currentSchedule[csIndex].containsKey('VL') && currentSchedule[csIndex]['VL'].length > 0))
                                      for(int mvIndex=0; mvIndex<currentSchedule[csIndex]['VL'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('VL', currentSchedule[csIndex]['VL'][mvIndex]['Status'],
                                              currentSchedule[csIndex]['VL'][mvIndex]['Name']),
                                        ),

                                    if((currentSchedule[csIndex].containsKey('FG') && currentSchedule[csIndex]['FG'].length > 0))
                                      for(int mvIndex=0; mvIndex<currentSchedule[csIndex]['FG'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('FG', currentSchedule[csIndex]['FG'][mvIndex]['Status'],
                                              currentSchedule[csIndex]['FG'][mvIndex]['Name']),
                                        ),

                                    if((currentSchedule[csIndex].containsKey('SL') && currentSchedule[csIndex]['SL'].length > 0))
                                      for(int mvIndex=0; mvIndex<currentSchedule[csIndex]['SL'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('SL', currentSchedule[csIndex]['SL'][mvIndex]['Status'],
                                              currentSchedule[csIndex]['SL'][mvIndex]['Name']),
                                        ),

                                    if((currentSchedule[csIndex].containsKey('FN') && currentSchedule[csIndex]['FN'].length > 0))
                                      for(int mvIndex=0; mvIndex<currentSchedule[csIndex]['FN'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('FN', currentSchedule[csIndex]['FN'][mvIndex]['Status'],
                                              currentSchedule[csIndex]['FN'][mvIndex]['Name']),
                                        ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(width: 1, height: 40, color: Colors.grey,),
                                    ),
                                    SizedBox(
                                      width: '${currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 200 : 215,
                                      child: Row(
                                        children: [
                                          const Text('Remaining : '),
                                          currentSchedule[csIndex]['Message']=='Running.'? Text('${currentSchedule[csIndex]['Duration_QtyLeft']}', style: const TextStyle(fontSize: 18, color:Colors.black)):
                                          Text('${currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? '--:--:--':'00000', style: const TextStyle(fontSize: 18, color: Colors.black))
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ) :
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Current schedule not Available', style: TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left),
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
                    color: Colors.green.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(width: 0.5, color: Colors.grey)
                ),
                child: const Text('CURRENT SCHEDULE',  style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ],
    ) : const SizedBox();
  }*/

  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
    }
  }

  Widget buildWidget(String type, int status, String name) {
    String imagePath;
    if(type=='MV'){
      if (status == 0) {
        imagePath = 'assets/images/dp_main_valve_not_open.png';
      } else if (status == 1) {
        imagePath = 'assets/images/dp_main_valve_open.png';
      } else if (status == 2) {
        imagePath = 'assets/images/dp_main_valve_wait.png';
      } else {
        imagePath = 'assets/images/dp_main_valve_closed.png';
      }
    }
    else if(type=='VL'){
      if (status == 0) {
        imagePath = 'assets/images/valve_gray.png';
      } else if (status == 1) {
        imagePath = 'assets/images/valve_green.png';
      } else if (status == 2) {
        imagePath = 'assets/images/valve_orange.png';
      } else {
        imagePath = 'assets/images/valve_red.png';
      }
    }
    else if(type=='FG'){
      if (status == 0) {
        imagePath = 'assets/images/fogger.png';
      } else if (status == 1) {
        imagePath = 'assets/images/fogger_green.png';
      } else if (status == 2) {
        imagePath = 'assets/images/fogger_orange.png';
      } else {
        imagePath = 'assets/images/fogger_red.png';
      }
    }else if(type=='SL'){
      if (status == 0) {
        imagePath = 'assets/images/selector.png';
      } else if (status == 1) {
        imagePath = 'assets/images/selector_g.png';
      } else if (status == 2) {
        imagePath = 'assets/images/selector_y.png';
      } else {
        imagePath = 'assets/images/selector_r.png';
      }
    }else if(type=='FN'){
      if (status == 0) {
        imagePath = 'assets/images/fan.png';
      } else if (status == 1) {
        imagePath = 'assets/images/fan_green.png';
      } else if (status == 2) {
        imagePath = 'assets/images/fan_orange.png';
      } else {
        imagePath = 'assets/images/fan_red.png';
      }
    }else{
      imagePath = 'assets/images/virtual_water_meter.png';
    }

    return Column(
      children: [
        const SizedBox(height: 3),
        Image.asset(imagePath, width: 40, height: 40),
        const SizedBox(height: 3),
        Text(name, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  List<Widget> buildValveRows(List<Map<String, dynamic>> valveData) {
    return valveData.map((valve) {
      return Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              const SizedBox(height: 3),
              Image.asset(
                width: 40,
                height: 40,
                // Assuming 'Status' is a key in the valve map
                valve['Status'] == 0
                    ? 'assets/images/valve_gray.png'
                    : valve['Status'] == 1
                    ? 'assets/images/valve_green.png'
                    : valve['Status'] == 2
                    ? 'assets/images/valve_orange.png'
                    : 'assets/images/valve_red.png',
              ),
              const SizedBox(height: 3),
              Text(
                '${valve['Name']}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _convertTime(String timeString) {
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }

 /* void durationUpdatingFunction() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      try{
        final provider = Provider.of<MqttPayloadProvider>(context, listen: false);
        for (int i = 0; i < provider.currentSchedule.length; i++) {
          if(provider.currentSchedule[i]['Duration_QtyLeft']!=null){

            if('${provider.currentSchedule[i]['Duration_QtyLeft']}'.contains(':'))
            {
              List<String> parts = provider.currentSchedule[i]['Duration_QtyLeft'].split(':');
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
              if(provider.currentSchedule[i]['Duration_QtyLeft']!='00:00:00'){
                setState(() {
                  provider.currentSchedule[i]['Duration_QtyLeft'] = updatedDurationQtyLeft;
                });
              }
            }
            else{
              //flow
              double remainFlow = double.parse(provider.currentSchedule[i]['Duration_QtyLeft']);
              if (remainFlow > 0) {
                double flowRate = provider.currentSchedule[i]['AverageFlowRate'] is String
                    ? double.parse(provider.currentSchedule[i]['AverageFlowRate'])
                    : provider.currentSchedule[i]['AverageFlowRate'];
                remainFlow -= flowRate;
                String formattedFlow = remainFlow.toStringAsFixed(2);
                setState(() {
                  provider.currentSchedule[i]['Duration_QtyLeft'] = formattedFlow;
                });
              } else {
                setState(() {
                  provider.currentSchedule[i]['Duration_QtyLeft'] = '0.00';
                });
              }
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }*/

  String getContentByCode(int code) {
    switch (code) {
      case 1:
        return 'Running As Per Schedule';
      case 2:
        return 'Turned On Manually';
      case 3:
        return 'Started By Condition';
      case 4:
        return 'Turned Off Manually';
      case 5:
        return 'Program Turned Off';
      case 6:
        return 'Zone Turned Off';
      case 7:
        return 'Stopped By Condition';
      case 8:
        return 'Disabled By Condition';
      case 9:
        return 'StandAlone Program Started';
      case 10:
        return 'StandAlone Program Stopped';
      case 11:
        return 'StandAlone Program Stopped After Set Value';
      case 12:
        return 'StandAlone Manual Started';
      case 13:
        return 'StandAlone Manual Stopped';
      case 14:
        return 'StandAlone Manual Stopped After Set Value';
      case 15:
        return 'Started By Day Count Rtc';
      case 16:
        return 'Paused By User';
      case 17:
        return 'Manually Started Paused By User';
      case 18:
        return 'Program Deleted';
      case 19:
        return 'Program Ready';
      case 20:
        return 'Program Completed';
      case 21:
        return 'Resumed By User';
      case 23:
        return 'Paused By Condition';
      default:
        return 'Unknown content';
    }
  }

  Future<void>sentManualModeToServer(manualOperation) async {
    try {
      final body = {"userId": widget.customerID, "controllerId": widget.siteData.master[0].controllerId, "manualOperation": manualOperation, "createUser": widget.customerID};
      final response = await HttpService().postRequest("createUserManualOperation", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}
