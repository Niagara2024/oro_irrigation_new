import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class CurrentScheduleFinal extends StatefulWidget {
  const CurrentScheduleFinal({Key? key, required this.siteData, required this.customerID}) : super(key: key);
  final DashboardModel siteData;
  final int customerID;

  @override
  State<CurrentScheduleFinal> createState() => _CurrentScheduleFinalState();
}

class _CurrentScheduleFinalState extends State<CurrentScheduleFinal> {

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
    return Container(
      decoration: BoxDecoration(
        color: myTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('CURRENT SCHEDULE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Container(
              color: Colors.white,
              height: provider.currentSchedule.isNotEmpty? (provider.currentSchedule.length * 151) : 25,
              child: provider.currentSchedule.isNotEmpty? ListView.builder(
                itemCount: provider.currentSchedule.length,
                itemBuilder: (BuildContext context, int csIndex) {
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 85,
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 600,
                          dataRowHeight: 50.0,
                          headingRowHeight: 35.0,
                          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
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
                              ) :
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
                        height: 65,
                        child :  Column(
                          children: [
                            (provider.currentSchedule[csIndex].containsKey('MV') && provider.currentSchedule[csIndex]['MV'].length > 0) &&
                                (provider.currentSchedule[csIndex].containsKey('VL') && provider.currentSchedule[csIndex]['VL'].length > 0)? Row(
                              children: [
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['MV'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 2),
                                        Image.asset(
                                          width: 47,
                                          height: 47,
                                          provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==0 ?
                                          'assets/images/valve_gray.png':
                                          provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==1 ?
                                          'assets/images/valve_green.png':
                                          provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==2 ?
                                          'assets/images/valve_orange.png': 'assets/images/valve_red.png',
                                        ),
                                        Text('${provider.currentSchedule[csIndex]['MV'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                      ],
                                    ),
                                  ),
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['VL'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 2),
                                          Image.asset(
                                            width: 47,
                                            height: 47,
                                              provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==0 ?
                                              'assets/images/valve_gray.png':
                                              provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==1 ?
                                              'assets/images/valve_green.png':
                                              provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==2 ?
                                              'assets/images/valve_orange.png': 'assets/images/valve_red.png',
                                          ),
                                          Text('${provider.currentSchedule[csIndex]['VL'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(width: 1, height: 40, color: Colors.grey,),
                                ),
                                SizedBox(
                                  width: '${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 200 : 215,
                                  child: Row(
                                    children: [
                                      Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 'Remaining : ':'Remaining : '),
                                      provider.currentSchedule[csIndex]['Message']=='Running.'? Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}', style: const TextStyle(fontSize: 18, color:Colors.black)):
                                      Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? '--:--:--':'00000', style: const TextStyle(fontSize: 18, color: Colors.black))
                                    ],
                                  ),
                                )
                              ],
                            ) :
                            provider.currentSchedule[csIndex].containsKey('VL') && provider.currentSchedule[csIndex]['VL'].length > 0 ? Row(
                              children: [
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['VL'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==0 ? Colors.grey :
                                            provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                            provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                            provider.currentSchedule[csIndex]['VL'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                            backgroundImage: const AssetImage('assets/images/valve.png'),
                                          ),
                                          const SizedBox(height: 3),
                                          Text('${provider.currentSchedule[csIndex]['VL'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(width: 1, height: 40, color: Colors.grey,),
                                ),
                                SizedBox(
                                  width: '${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 200 : 215,
                                  child: Row(
                                    children: [
                                      Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 'Remaining : ':'Remaining : '),
                                      provider.currentSchedule[csIndex]['Message']=='Running.'? Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}', style: const TextStyle(fontSize: 18, color:Colors.black)):
                                      Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? '--:--:--':'00000', style: TextStyle(fontSize: 18, color: Colors.black))
                                    ],
                                  ),
                                )
                              ],
                            ) :
                            provider.currentSchedule[csIndex].containsKey('MV') && provider.currentSchedule[csIndex]['MV'].length > 0 ? Row(
                              children: [
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[csIndex]['MV'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==0 ? Colors.grey :
                                            provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                            provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                            provider.currentSchedule[csIndex]['MV'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                            backgroundImage: const AssetImage('assets/images/dp_main_valve.png'),
                                          ),
                                          const SizedBox(height: 3),
                                          Text('${provider.currentSchedule[csIndex]['MV'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(width: 1, height: 40, color: Colors.grey,),
                                ),
                                SizedBox(
                                  width: '${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 200 : 215,
                                  child: Row(
                                    children: [
                                      Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? 'Remaining : ':'Remaining : '),
                                      provider.currentSchedule[csIndex]['Message']=='Running.'? Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}', style: const TextStyle(fontSize: 18, color:Colors.black)):
                                      Text('${provider.currentSchedule[csIndex]['Duration_QtyLeft']}'.contains(':') ? '--:--:--':'00000', style: const TextStyle(fontSize: 18, color: Colors.black))
                                    ],
                                  ),
                                )
                              ],
                            ):
                            const SizedBox(),

                          ],
                        ),
                      )
                    ],
                  );
                },
              ) :
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Current schedule not Available', style: TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left),
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
              print(provider.currentSchedule[i]['Duration_QtyLeft']);
              if(provider.currentSchedule[i]['Duration_QtyLeft']>0){
                setState(() {
                  int remainFlow = provider.currentSchedule[i]['Duration_QtyLeft'];
                  int flowRate = provider.currentSchedule[i]['AverageFlowRate'];
                  remainFlow = remainFlow - flowRate;
                  provider.currentSchedule[i]['Duration_QtyLeft'] = remainFlow;
                });
              }else{
                setState(() {
                  provider.currentSchedule[i]['Duration_QtyLeft'] = '0';
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
