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
import '../../../state_management/MqttPayloadProvider.dart';

class CurrentSchedule extends StatefulWidget {
  const CurrentSchedule({Key? key, required this.siteData, required this.customerID}) : super(key: key);
  final DashboardModel siteData;
  final int customerID;

  @override
  State<CurrentSchedule> createState() => _CurrentScheduleState();
}

class _CurrentScheduleState extends State<CurrentSchedule> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    durationUpdatingFunction();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MqttPayloadProvider>(context);
    return provider.currentSchedule.isNotEmpty? Column(
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
                height: provider.currentSchedule.isNotEmpty ? (provider.currentSchedule.length * 148) : 45,
                child: provider.currentSchedule.isNotEmpty ? Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: ListView.builder(
                    itemCount: provider.currentSchedule.length,
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
                                    label: Text('Line', style: TextStyle(fontSize: 13)),
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
                                    size: ColumnSize.M
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                                    size: ColumnSize.M
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                                    size: ColumnSize.M
                                ),
                                DataColumn2(
                                    label: Center(child: Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 'Total Duration(hh:mm:ss)' : 'Total Flow(Liters)', style: const TextStyle(fontSize: 13),)),
                                    size: ColumnSize.L
                                ),
                                const DataColumn2(
                                    label: Center(child: Text('')),
                                    fixedWidth: 90
                                ),
                              ],
                              rows: List<DataRow>.generate(1, (lsIndex) => DataRow(cells: [
                                DataCell(Text(provider.currentSchedule[csIndex]['ProgName'])),
                                DataCell(Text(provider.currentSchedule[csIndex]['ProgCategory'])),
                                DataCell(Text('${provider.currentSchedule[csIndex]['CurrentZone']}/${provider.currentSchedule[csIndex]['TotalZone']}')),
                                DataCell(Text(provider.currentSchedule[csIndex]['ZoneName'])),
                                DataCell(Center(child: Text('${provider.currentSchedule[csIndex]['CurrentRtc']}/${provider.currentSchedule[csIndex]['TotalRtc']}'))),
                                DataCell(Center(child: Center(child: Text('${provider.currentSchedule[csIndex]['CurrentCycle']}/${provider.currentSchedule[csIndex]['TotalCycle']}')))),
                                DataCell(Center(child: Text(_convertTime(provider.currentSchedule[csIndex]['StartTime'])))),
                                DataCell(Center(child: Text('${provider.currentSchedule[csIndex]['Duration_Qty']}'))),
                                DataCell(Center(
                                  child: provider.currentSchedule[csIndex]['ProgName']=='StandAlone - Manual'?
                                  MaterialButton(
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    onPressed: provider.currentSchedule[csIndex]['Message']=='Running.'? (){
                                      String payload = '0,0,0,0';
                                      String payLoadFinal = jsonEncode({
                                        "800": [{"801": payload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                      Map<String, dynamic> manualOperation = {
                                        "method": 1,
                                        "time": '00:00',
                                        "flow": '0',
                                        "selected": [],
                                      };
                                      sentManualModeToServer(manualOperation);
                                    } : null,
                                    child: const Text('Stop'),
                                  ):
                                  '${provider.currentSchedule[csIndex]['ProgName']}'.contains('StandAlone') ?
                                  MaterialButton(
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      String? prgOffPayload = prefs.getString('StandAloneProgramOff');
                                      String payLoadFinal = jsonEncode({
                                        "3900": [{"3901": prgOffPayload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                    },
                                    child: const Text('Stop'),
                                  ):
                                  MaterialButton(
                                    color: Colors.green,
                                    textColor: Colors.white,
                                    onPressed: provider.currentSchedule[csIndex]['Message']=='Running.'? (){
                                      String payload = '${provider.currentSchedule[csIndex]['ScheduleS_No']},0';
                                      String payLoadFinal = jsonEncode({
                                        "3700": [{"3701": payload}]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
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
                                    if((provider.currentSchedule[csIndex].containsKey('MV') && provider.currentSchedule[csIndex]['MV'].length > 0))
                                      for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['MV'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('MV', provider.currentSchedule[csIndex]['MV'][mvIndex]['Status'],
                                              provider.currentSchedule[csIndex]['MV'][mvIndex]['Name']),
                                        ),

                                    if((provider.currentSchedule[csIndex].containsKey('VL') && provider.currentSchedule[csIndex]['VL'].length > 0))
                                      for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['VL'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('VL', provider.currentSchedule[csIndex]['VL'][mvIndex]['Status'],
                                              provider.currentSchedule[csIndex]['VL'][mvIndex]['Name']),
                                        ),

                                    if((provider.currentSchedule[csIndex].containsKey('FG') && provider.currentSchedule[csIndex]['FG'].length > 0))
                                      for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['FG'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('FG', provider.currentSchedule[csIndex]['FG'][mvIndex]['Status'],
                                              provider.currentSchedule[csIndex]['FG'][mvIndex]['Name']),
                                        ),

                                    if((provider.currentSchedule[csIndex].containsKey('SL') && provider.currentSchedule[csIndex]['SL'].length > 0))
                                      for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['SL'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('SL', provider.currentSchedule[csIndex]['SL'][mvIndex]['Status'],
                                              provider.currentSchedule[csIndex]['SL'][mvIndex]['Name']),
                                        ),

                                    if((provider.currentSchedule[csIndex].containsKey('FN') && provider.currentSchedule[csIndex]['FN'].length > 0))
                                      for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['FN'].length; mvIndex++)
                                        Expanded(
                                          flex: 1,
                                          child: buildWidget('FN', provider.currentSchedule[csIndex]['FN'][mvIndex]['Status'],
                                              provider.currentSchedule[csIndex]['FN'][mvIndex]['Name']),
                                        ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(width: 1, height: 40, color: Colors.grey,),
                                    ),
                                    SizedBox(
                                      width: '${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 200 : 215,
                                      child: Row(
                                        children: [
                                          const Text('Remaining : '),
                                          provider.currentSchedule[csIndex]['Message']=='Running.'? Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}', style: const TextStyle(fontSize: 18, color:Colors.black)):
                                          Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? '--:--:--':'00000', style: const TextStyle(fontSize: 18, color: Colors.black))
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

  void durationUpdatingFunction() {
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
  }

  Future<void>sentManualModeToServer(manualOperation) async {
    try {
      final body = {"userId": widget.customerID, "controllerId": widget.siteData.controllerId, "manualOperation": manualOperation, "createUser": widget.customerID};
      final response = await HttpService().postRequest("createUserManualOperation", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}
