import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../state_management/MqttPayloadProvider.dart';

class CurrentSchedule extends StatefulWidget {
  const CurrentSchedule({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

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
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          ListTile(
            tileColor: myTheme.primaryColor.withOpacity(0.2),
            title: const Text('CURRENT SCHEDULE', style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
            trailing: provider.currentSchedule.isNotEmpty ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/GiffFile/water_drop_animation.gif'),
                ]
            ): null,
          ),
          Container(
            color: Colors.white,
            height: provider.currentSchedule.isNotEmpty? (provider.currentSchedule.length * 200): 50,
            child: provider.currentSchedule.isNotEmpty? SizedBox(
              height: (provider.currentSchedule.length * 200),
              child: Column(
                children: [
                  for(int index=0; index<provider.currentSchedule.length; index++)
                    Row(
                      children: [
                        const SizedBox(
                            width: 150,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Program Name',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                  SizedBox(height: 6,),
                                  Text('Irrigation Line',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                  SizedBox(height: 6,),
                                  Text('Zone',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                  SizedBox(height: 6,),
                                  Text('Zone Name',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                  SizedBox(height: 6,),
                                  Text('Start Time',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                  SizedBox(height: 6,),
                                  Text('Total(Duration/Flow)',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                  SizedBox(height: 6,),
                                  Text('Left(Duration/Flow)',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                ],
                              ),
                            )
                        ),
                        const SizedBox(
                            width: 10,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6,),
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6,),
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6,),
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6,),
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6,),
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 6,),
                                  Text(':',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                        ),
                        SizedBox(
                            width: 175,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(provider.currentSchedule[index]['ProgName'],style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text(provider.currentSchedule[index]['ProgCategory'],style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text('${provider.currentSchedule[index]['CurrentZone']}/${provider.currentSchedule[index]['TotalZone']}',style: TextStyle(fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text(provider.currentSchedule[index]['ZoneName'],style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text(_convertTime(provider.currentSchedule[index]['StartTime']),style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text(provider.currentSchedule[index]['Duration_Qty'],style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 6),
                                  provider.currentSchedule[index]['Message']=='Running.'? Text(provider.currentSchedule[index]['Duration_QtyLeft'],style: TextStyle(fontSize: 14, color:myTheme.primaryColorDark) ):
                                      const SizedBox(width : 50, height : 15, child: LoadingIndicator(indicatorType: Indicator.ballPulse)),

                                ],
                              ),
                            )
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width-894,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Text('Main valve'),
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context).width-894,
                                            height: 65,
                                            child: provider.currentSchedule[index]['MainValve'].length > 0 ? Row(
                                              children: [
                                                for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['MainValve'].length; mvIndex++)
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Column(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor: provider.currentSchedule[index]['MainValve'][mvIndex]['Status']==0 ? Colors.grey :
                                                          provider.currentSchedule[index]['MainValve'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                          provider.currentSchedule[index]['MainValve'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                          provider.currentSchedule[index]['MainValve'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                          backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                                        ),
                                                        const SizedBox(height: 3),
                                                        Text('${provider.currentSchedule[index]['MainValve'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                      ],
                                                    ),
                                                  )
                                              ],
                                            ):
                                            const Center(child: Text('-----')),
                                          ),
                                        ],
                                      ),
                                  ),
                                  Expanded(
                                    flex:1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text('Pump'),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width-894,
                                          height: 65,
                                          child : provider.currentSchedule[index]['Message']=='Running.'? Row(
                                            children: [
                                              for(int pIndex=0; pIndex<provider.currentSchedule[index]['Pump'].length; pIndex++)
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor: provider.currentSchedule[index]['Pump'][pIndex]['Status']==0 ? Colors.grey :
                                                        provider.currentSchedule[index]['Pump'][pIndex]['Status']==1 ? Colors.greenAccent :
                                                        provider.currentSchedule[index]['Pump'][pIndex]['Status']==2 ? Colors.orangeAccent:
                                                        provider.currentSchedule[index]['Pump'][pIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                        backgroundImage: const AssetImage('assets/images/irrigation_pump.png'),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text('${provider.currentSchedule[index]['Pump'][pIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                    ],
                                                  ),
                                                )
                                            ],
                                          ):
                                          Text('${provider.currentSchedule[index]['Message']}(${provider.currentSchedule[index]['OnDelayTimeLeft']})'),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const Divider(),
                              const Text('Valve'),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width-884,
                                height: 65,
                                child: provider.currentSchedule[index]['Valve'].length > 0 ? Row(
                                  children: [
                                    for(int vIndex=0; vIndex<provider.currentSchedule[index]['Valve'].length;vIndex++)
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: provider.currentSchedule[index]['Valve'][vIndex]['Status']==0 ? Colors.grey :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==1 ? Colors.greenAccent :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==2 ? Colors.orangeAccent:
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                              backgroundImage: const AssetImage('assets/images/valve.png'),
                                            ),
                                            const SizedBox(height: 3),
                                            Text('${provider.currentSchedule[index]['Valve'][vIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                          ],
                                        ),
                                      ),
                                  ],
                                ) :
                                const Center(child: Text('-----')),
                                /*child: provider.currentSchedule[index]['Message']=='Running.'? provider.currentSchedule[index]['Valve'].length > 0 ? Row(
                                  children: [
                                    for(int vIndex=0; vIndex<provider.currentSchedule[index]['Valve'].length;vIndex++)
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: provider.currentSchedule[index]['Valve'][vIndex]['Status']==0 ? Colors.grey :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==1 ? Colors.greenAccent :
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==2 ? Colors.orangeAccent:
                                              provider.currentSchedule[index]['Valve'][vIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                              backgroundImage: const AssetImage('assets/images/valve.png'),
                                            ),
                                            const SizedBox(height: 3),
                                            Text('${provider.currentSchedule[index]['Valve'][vIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                          ],
                                        ),
                                      )
                                  ],
                                ):
                                const Center(child: Text('-----')) : Text('${provider.currentSchedule[index]['Message']}(${provider.currentSchedule[index]['OnDelayTimeLeft']})'),*/
                              ),
                            ],
                          )
                        ),
                        SizedBox(
                          width: 45,
                          child:  Center(
                              child: IconButton(
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
                            )
                        ),
                      ],
                    ),
                  const Divider(),
                ],
              ),
            ):
            const Center(child: Text('Current Schedule not Available')),
          ),
          /*Container(
            color: Colors.white,
            height: provider.currentSchedule.isNotEmpty? (provider.currentSchedule.length * 55) + 40 : 50,
            child: provider.currentSchedule.isNotEmpty? SizedBox(
              height: (provider.currentSchedule.length * 55) + 40,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1000,
                dataRowHeight: 55.0,
                headingRowHeight: 40.0,
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
                      label: Center(child: Text('Total(T/F)', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 100
                  ),
                  DataColumn2(
                      label: Center(child: Text('Left', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 100
                  ),
                  DataColumn2(
                      label: Text('Main Valve', style: TextStyle(fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                      label: Text('Valve', style: TextStyle(fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                      label: Center(child: Text('Action', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 50
                  ),
                ],
                rows: provider.currentSchedule.map<DataRow>((data) {
                  final List<DataCell> cells = [
                    DataCell(
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(radius: 15, backgroundColor: Colors.greenAccent,child: Text('M')),
                        title: Text(data['ProgName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(data['SchedulingMethod']==1? 'No Schedule':data['SchedulingMethod']==2?'Schedule as run list':'Schedule by days', style: const TextStyle(fontSize: 11),),
                      ),
                    ),
                    DataCell(Text(data['ProgCategory'])),
                    DataCell(Center(child: Text('${data['CurrentZone']}/${data['TotalZone']}'))),
                    DataCell(Center(child: Text(data['ZoneName']))),
                    DataCell(Center(child: Text(_convertTime(data['StartTime'])))),
                    DataCell(Center(child: Text(data['Duration_Qty']))),
                    DataCell(Center(child: data['Message']=='Running.'? Text(data['Duration_QtyLeft']) : const LoadingIndicator(indicatorType: Indicator.ballPulse))),
                    DataCell(
                      Center(
                          child: data['MainValve'].length>0?GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(
                              data['MainValve'].length,
                                  (vIndex) => Center(
                                child : IconButton(
                                    tooltip: '${data['MainValve'][vIndex]['Name']}',
                                    onPressed: (){},
                                    icon: CircleAvatar(
                                      backgroundColor: data['MainValve'][vIndex]['Status']==0 ? Colors.grey :
                                      data['MainValve'][vIndex]['Status']==1 ? Colors.greenAccent :
                                      data['MainValve'][vIndex]['Status']==2 ? Colors.orangeAccent:
                                      data['MainValve'][vIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                      backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                    )
                                ),
                              ),
                            ),
                          ):
                          Center(child: Text('---')),
                      ),
                    ),
                    DataCell(
                      Center(
                          child: data['Message']=='Running.'? GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(
                              data['Valve'].length,
                                  (vIndex) => Center(
                                child : IconButton(
                                    tooltip: '${data['Valve'][vIndex]['Name']}',
                                    onPressed: (){},
                                    icon: CircleAvatar(
                                      backgroundColor: data['Valve'][vIndex]['Status']==0 ? Colors.grey :
                                      data['Valve'][vIndex]['Status']==1 ? Colors.greenAccent :
                                      data['Valve'][vIndex]['Status']==2 ? Colors.orangeAccent:
                                      data['Valve'][vIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                      backgroundImage: const AssetImage('assets/images/valve.png'),
                                    )
                                ),
                              ),
                            ),
                          ) : Text('${data['Message']}(${data['OnDelayTimeLeft']})')
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          tooltip: 'Skip next',
                          onPressed: data['Message']=='Running.'? (){
                            String payload = '${data['ScheduleS_No']},0';
                            String payLoadFinal = jsonEncode({
                              "3700": [{"3701": payload}]
                            });
                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                          } : null,
                          icon: const Icon(Icons.skip_next_outlined),
                        ),
                      ),
                    ),
                  ];

                  return DataRow(cells: cells);
                }).toList(),
              ),
            ):
            const Center(child: Text('Current Schedule not Available')),
          ),*/
        ],
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

          if(provider.currentSchedule[i]['Message']=='Running.'){
            if(provider.currentSchedule[i]['Duration_QtyLeft']!=null){
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
          }else{
            if(provider.currentSchedule[i]['OnDelayTimeLeft']!=null){
              List<String> parts = provider.currentSchedule[i]['OnDelayTimeLeft'].split(':');
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
              if(provider.currentSchedule[i]['OnDelayTimeLeft']!='00:00:00'){
                setState(() {
                  provider.currentSchedule[i]['OnDelayTimeLeft'] = updatedDurationQtyLeft;
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

}
