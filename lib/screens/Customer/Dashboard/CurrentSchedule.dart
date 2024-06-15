import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class CurrentSchedule extends StatefulWidget {
  const CurrentSchedule({Key? key, required this.siteData, required this.customerID, required this.currentSchedule}) : super(key: key);
  final DashboardModel siteData;
  final int customerID;
  final List<CurrentScheduleModel> currentSchedule;

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
    bool allOnDelayLeftZero = true;
    try {
      if(widget.currentSchedule.isNotEmpty){
        for (int i = 0; i < widget.currentSchedule.length; i++) {
          if(widget.currentSchedule[i].message=='Running.'){
            if (widget.currentSchedule[i].duration_QtyLeft.contains(':')) {
              List<String> parts = widget.currentSchedule[i].duration_QtyLeft.split(':');
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
              if (widget.currentSchedule[i].duration_QtyLeft != '00:00:00') {
                setState(() {
                  widget.currentSchedule[i].duration_QtyLeft = updatedDurationQtyLeft;
                });
              }
            }
            else {
              double remainFlow = double.parse(widget.currentSchedule[i].duration_QtyLeft);
              if (remainFlow > 0) {
                double flowRate = double.parse(widget.currentSchedule[i].avgFlwRt);
                remainFlow -= flowRate;
                String formattedFlow = remainFlow.toStringAsFixed(2);
                setState(() {
                  widget.currentSchedule[i].duration_QtyLeft = formattedFlow;
                });
              } else {
                widget.currentSchedule[i].duration_QtyLeft = '0.00';
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

    if (allOnDelayLeftZero) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    _startTimer();
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: screenWidth > 600 ? buildWideLayout():
                buildNarrowLayout(),
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
    );
  }

  Widget buildNarrowLayout() {
    return SizedBox(
      height: widget.currentSchedule.length * 190,
      child: Card(
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
        elevation: 5,
        child: ListView.builder(
          itemCount: widget.currentSchedule.length,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8, top: 5, bottom: 5),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Start at', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(width: 5,),
                                      Text(_convertTime(widget.currentSchedule[index].startTime)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Duration', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(width: 5,),
                                      Text(widget.currentSchedule[index].duration_Qty),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(width: 0,),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(widget.currentSchedule[index].duration_QtyLeft,style: const TextStyle(fontSize: 20)),
                                  const VerticalDivider(),
                                  Text('${widget.currentSchedule[index].currentZone}/${widget.currentSchedule[index].totalZone}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Current program', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Location & Zone', style: TextStyle(fontWeight: FontWeight.normal),),
                              SizedBox(height: 3,),
                              Text('Current RTC & Cyclic', style: TextStyle(fontWeight: FontWeight.normal),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(widget.currentSchedule[index].programName),
                              const SizedBox(height: 3,),
                              Text('${widget.currentSchedule[index].programCategory} & ${widget.currentSchedule[index].zoneName}'),
                              const SizedBox(height: 3,),
                              Text('${formatRtcValues(widget.currentSchedule[index].currentRtc, widget.currentSchedule[index].totalRtc)} & '
                                  '${formatRtcValues(widget.currentSchedule[index].currentCycle,widget.currentSchedule[index].totalCycle)}'),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(getContentByCode(widget.currentSchedule[index].reasonCode), style: const TextStyle(fontSize: 12, color: Colors.black),),
                          widget.currentSchedule[index].programName=='StandAlone - Manual'?
                          MaterialButton(
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            onPressed: widget.currentSchedule[index].message=='Running.'? (){
                              String payload = '0,0,0,0';
                              String payLoadFinal = jsonEncode({
                                "800": [{"801": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                              Map<String, dynamic> manualOperation = {
                                "programName": 'Default',
                                "programId": 0,
                                "startFlag": 0,
                                "method": 1,
                                "time": '00:00:00',
                                "flow": '0',
                                "selected": [],
                              };
                              sentManualModeToServer(manualOperation);
                            } : null,
                            child: const Text('Stop'),
                          ):
                          widget.currentSchedule[index].programName.contains('StandAlone') ?
                          MaterialButton(
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            onPressed: () async {
                              print(widget.currentSchedule[index]);
                              final prefs = await SharedPreferences.getInstance();
                              String? prgOffPayload = prefs.getString(widget.currentSchedule[index].programName);
                              String payLoadFinal = jsonEncode({
                                "3900": [{"3901": prgOffPayload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                              Map<String, dynamic> manualOperation = {
                                "programName": widget.currentSchedule[index].programName,
                                "programId": widget.currentSchedule[index].programType,
                                "startFlag":0,
                                "method": 1,
                                "time": '00:00:00',
                                "flow": '0',
                                "selected": [],
                              };
                              sentManualModeToServer(manualOperation);
                              prefs.remove(widget.currentSchedule[index].programName);
                            },
                            child: const Text('Stop'),
                          ):
                          MaterialButton(
                            color: Colors.green,
                            textColor: Colors.white,
                            onPressed: widget.currentSchedule[index].message=='Running.'? (){
                              String payload = '${widget.currentSchedule[index].srlNo},0';
                              String payLoadFinal = jsonEncode({
                                "3700": [{"3701": payload}]
                              });
                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                            } : null,
                            child: const Text('Skip'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if(index != widget.currentSchedule.length - 1)
                  Divider(height: 5, color: Colors.teal.shade50, thickness: 4,),
                const SizedBox(height: 5,),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildWideLayout() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      height: (widget.currentSchedule.length * 45) + 45,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 1200,
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
        rows: List<DataRow>.generate(widget.currentSchedule.length, (index) => DataRow(cells: [
          DataCell(
           Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.currentSchedule[index].programName),
                  Text('${getContentByCode(widget.currentSchedule[index].reasonCode)} - ${widget.currentSchedule[index].reasonCode}', style: const TextStyle(fontSize: 11, color: Colors.black),),
                ],
              ),
          ),
          DataCell(Text(widget.currentSchedule[index].programCategory)),
          DataCell(Text('${widget.currentSchedule[index].currentZone}/${widget.currentSchedule[index].totalZone}')),
          DataCell(Text(widget.currentSchedule[index].zoneName)),
          DataCell(Center(child: Text(formatRtcValues(widget.currentSchedule[index].currentRtc, widget.currentSchedule[index].totalRtc)))),
          DataCell(Center(child: Text(formatRtcValues(widget.currentSchedule[index].currentCycle,widget.currentSchedule[index].totalCycle)))),
          DataCell(Center(child: Text(_convertTime(widget.currentSchedule[index].startTime)))),
          DataCell(Center(child: Text(widget.currentSchedule[index].duration_Qty))),
          DataCell(Center(child: Text(widget.currentSchedule[index].duration_QtyLeft,style: const TextStyle(fontSize: 20)))),
          DataCell(Center(
            child: widget.currentSchedule[index].programName=='StandAlone - Manual'?
            MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: widget.currentSchedule[index].message=='Running.'? (){
                String payload = '0,0,0,0';
                String payLoadFinal = jsonEncode({
                  "800": [{"801": payload}]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                Map<String, dynamic> manualOperation = {
                  "programName": 'Default',
                  "programId": 0,
                  "startFlag": 0,
                  "method": 1,
                  "time": '00:00:00',
                  "flow": '0',
                  "selected": [],
                };
                sentManualModeToServer(manualOperation);
              } : null,
              child: const Text('Stop'),
            ):
            widget.currentSchedule[index].programName.contains('StandAlone') ?
            MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: () async {
                print(widget.currentSchedule[index]);
                final prefs = await SharedPreferences.getInstance();
                String? prgOffPayload = prefs.getString(widget.currentSchedule[index].programName);
                String payLoadFinal = jsonEncode({
                  "3900": [{"3901": prgOffPayload}]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                Map<String, dynamic> manualOperation = {
                  "programName": widget.currentSchedule[index].programName,
                  "programId": widget.currentSchedule[index].programType,
                  "startFlag":0,
                  "method": 1,
                  "time": '00:00:00',
                  "flow": '0',
                  "selected": [],
                };
                sentManualModeToServer(manualOperation);
                prefs.remove(widget.currentSchedule[index].programName);
              },
              child: const Text('Stop'),
            ):
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              onPressed: widget.currentSchedule[index].message=='Running.'? (){
                String payload = '${widget.currentSchedule[index].srlNo},0';
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
    );
  }


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
