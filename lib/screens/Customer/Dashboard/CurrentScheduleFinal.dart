import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class CurrentScheduleFinal extends StatefulWidget {
  const CurrentScheduleFinal({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

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
              height: provider.currentSchedule.isNotEmpty? (provider.currentSchedule.length * 45) + 100 : 25,
              child: provider.currentSchedule.isNotEmpty? ListView.builder(
                itemCount: provider.currentSchedule.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 80,
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 625,
                          dataRowHeight: 45.0,
                          headingRowHeight: 35.0,
                          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                          columns: const [
                            DataColumn2(
                                label: Text('Name', style: TextStyle(fontSize: 13),),
                                size: ColumnSize.S
                            ),
                            DataColumn2(
                                label: Text('Line', style: TextStyle(fontSize: 13)),
                                size: ColumnSize.M

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
                                size: ColumnSize.M
                            ),
                            DataColumn2(
                                label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                                fixedWidth: 100
                            ),
                            DataColumn2(
                                label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                                fixedWidth: 100
                            ),
                            DataColumn2(
                                label: Center(child: Text('Total(D/F)', style: TextStyle(fontSize: 13),)),
                                fixedWidth: 100
                            ),
                            DataColumn2(
                                label: Center(child: Text('')),
                                fixedWidth: 45
                            ),
                          ],
                          rows: List<DataRow>.generate(1, (index) => DataRow(cells: [
                            DataCell(Text(provider.currentSchedule[index]['ProgName'])),
                            DataCell(Text(provider.currentSchedule[index]['ProgCategory'])),
                            DataCell(Text('${provider.currentSchedule[index]['CurrentZone']}/${provider.currentSchedule[index]['TotalZone']}')),
                            DataCell(Text(provider.currentSchedule[index]['ZoneName'])),
                            DataCell(Center(child: Text('${provider.currentSchedule[index]['CurrentRtc']}/${provider.currentSchedule[index]['TotalRtc']}'))),
                            DataCell(Center(child: Center(child: Text('${provider.currentSchedule[index]['CurrentCycle']}/${provider.currentSchedule[index]['TotalCycle']}')))),
                            DataCell(Center(child: Text(_convertTime(provider.currentSchedule[index]['StartTime'])))),
                            DataCell(Center(child: Text('${provider.currentSchedule[index]['Duration_Qty']}'))),
                            DataCell(Center(
                              child: provider.currentSchedule[index]['ProgType']==3? IconButton(
                                tooltip: 'Stop',
                                onPressed: provider.currentSchedule[index]['Message']=='Running.'? (){
                                  String payload = '0,1,0,${provider.currentSchedule[index]['ScheduleS_No']},0,0,${provider.currentSchedule[index]['ProgType']},0';
                                  String payLoadFinal = jsonEncode({
                                    "800": [{"801": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                } : null,
                                icon: const Icon(Icons.stop_circle_outlined,color: Colors.red),
                              ):
                              IconButton(
                                tooltip: 'Skip next',
                                onPressed: provider.currentSchedule[index]['Message']=='Running.'? (){
                                  String payload = '${provider.currentSchedule[index]['ScheduleS_No']},0';
                                  String payLoadFinal = jsonEncode({
                                    "3700": [{"3701": payload}]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                } : null,
                                icon: const Icon(Icons.skip_next_outlined),
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
                            (provider.currentSchedule[index].containsKey('MV') && provider.currentSchedule[index]['MV'].length > 0) &&
                                (provider.currentSchedule[index].containsKey('VL') && provider.currentSchedule[index]['VL'].length > 0)? Row(
                              children: [
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['MV'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: provider.currentSchedule[index]['MV'][mvIndex]['Status']==0 ? Colors.grey :
                                          provider.currentSchedule[index]['MV'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                          provider.currentSchedule[index]['MV'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                          provider.currentSchedule[index]['MV'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                          backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                        ),
                                        const SizedBox(height: 3),
                                        Text('${provider.currentSchedule[index]['MV'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                      ],
                                    ),
                                  ),
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['VL'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: provider.currentSchedule[index]['VL'][mvIndex]['Status']==0 ? Colors.grey :
                                            provider.currentSchedule[index]['VL'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                            provider.currentSchedule[index]['VL'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                            provider.currentSchedule[index]['VL'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                            backgroundImage: const AssetImage('assets/images/valve.png'),
                                          ),
                                          const SizedBox(height: 3),
                                          Text('${provider.currentSchedule[index]['VL'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(width: 1, height: 40, color: Colors.grey,),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: Row(
                                    children: [
                                      Text('${provider.currentSchedule[index]['Duration_QtyLeft']}'.contains(':') ? 'Remaining(hh:mm:ss) : ':'Remaining(liters) : '),
                                      provider.currentSchedule[index]['Message']=='Running.'? Text(provider.currentSchedule[index]['Duration_QtyLeft'], style: const TextStyle(fontSize: 18, color:Colors.black)):
                                      const Text('----', style: TextStyle(fontSize: 18, color: Colors.black))
                                    ],
                                  ),
                                )
                              ],
                            ) :
                            provider.currentSchedule[index].containsKey('VL') && provider.currentSchedule[index]['VL'].length > 0 ? Row(
                              children: [
                                for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['VL'].length; mvIndex++)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: provider.currentSchedule[index]['VL'][mvIndex]['Status']==0 ? Colors.grey :
                                            provider.currentSchedule[index]['VL'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                            provider.currentSchedule[index]['VL'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                            provider.currentSchedule[index]['VL'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                            backgroundImage: const AssetImage('assets/images/valve.png'),
                                          ),
                                          const SizedBox(height: 3),
                                          Text('${provider.currentSchedule[index]['VL'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                        ],
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(width: 1, height: 40, color: Colors.grey,),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: Row(
                                    children: [
                                      Text('${provider.currentSchedule[index]['Duration_QtyLeft']}'.contains(':') ? 'Remaining(hh:mm:ss) : ':'Remaining(liters) : '),
                                      provider.currentSchedule[index]['Message']=='Running.'? Text('${provider.currentSchedule[index]['Duration_QtyLeft']}', style: const TextStyle(fontSize: 18, color:Colors.black)):
                                      const Text('----', style: TextStyle(fontSize: 18, color: Colors.black))
                                    ],
                                  ),
                                )
                              ],
                            ) :
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
            }
          }
        }
      }
      catch(e){
        print(e);
      }

    });
  }

}
