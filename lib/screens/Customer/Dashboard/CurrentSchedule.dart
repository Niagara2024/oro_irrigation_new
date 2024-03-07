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
              height: provider.currentSchedule.isNotEmpty? (provider.currentSchedule.length * 232): 50,
              child: provider.currentSchedule.isNotEmpty? SizedBox(
                height: (provider.currentSchedule.length * 232),
                child: Column(
                  children: [
                    for(int index=0; index<provider.currentSchedule.length; index++)
                      Column(
                        children: [
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
                                        Text('RTC',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
                                        SizedBox(height: 6,),
                                        Text('Cyclic',style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal)),
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
                                        Text('${provider.currentSchedule[index]['CurrentRtc']}/${provider.currentSchedule[index]['TotalRtc']}',style: TextStyle(fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Text('${provider.currentSchedule[index]['CurrentCycle']}/${provider.currentSchedule[index]['TotalCycle']}',style: TextStyle(fontSize: 13)),
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
                                                  child: provider.currentSchedule[index].containsKey('MV')? provider.currentSchedule[index]['MV'].length > 0 ? Row(
                                                    children: [
                                                      for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['MV'].length; mvIndex++)
                                                        Padding(
                                                          padding: const EdgeInsets.all(5.0),
                                                          child: Column(
                                                            children: [
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
                                                        )
                                                    ],
                                                  ):
                                                  const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('IP'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('IP')? provider.currentSchedule[index]['IP'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['IP'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['IP'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['IP'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['IP'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['IP'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['IP'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('SP'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('SP')? provider.currentSchedule[index]['SP'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['SP'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['SP'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['SP'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['SP'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['SP'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['SP'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('SL'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('SL')? provider.currentSchedule[index]['SL'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['SL'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['SL'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['SL'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['SL'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['SL'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['SL'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('FN'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('FN')? provider.currentSchedule[index]['FN'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['FN'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['FN'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['FN'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['FN'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['FN'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/fan.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['FN'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Text('Valve'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('VL')? provider.currentSchedule[index]['VL'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['VL'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
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
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('AG'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('AG')? provider.currentSchedule[index]['AG'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['AG'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['AG'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['AG'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['AG'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['AG'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/main_valve.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['AG'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('Booster'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('FB')? provider.currentSchedule[index]['FB'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['FB'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['FB'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['FB'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['FB'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['FB'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/booster_pump.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['FB'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
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
                                              const Text('fogger'),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width-894,
                                                height: 65,
                                                child: provider.currentSchedule[index].containsKey('FG')? provider.currentSchedule[index]['FG'].length > 0 ? Row(
                                                  children: [
                                                    for(int mvIndex=0; mvIndex<provider.currentSchedule[index]['FG'].length; mvIndex++)
                                                      Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor: provider.currentSchedule[index]['FG'][mvIndex]['Status']==0 ? Colors.grey :
                                                              provider.currentSchedule[index]['FG'][mvIndex]['Status']==1 ? Colors.greenAccent :
                                                              provider.currentSchedule[index]['FG'][mvIndex]['Status']==2 ? Colors.orangeAccent:
                                                              provider.currentSchedule[index]['FG'][mvIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                              backgroundImage: const AssetImage('assets/images/fogger.png'),
                                                            ),
                                                            const SizedBox(height: 3),
                                                            Text('${provider.currentSchedule[index]['FG'][mvIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ):
                                                const Center(child: Text('-----')):const Center(child: Text('-----')),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    /*SizedBox(
                                      width: MediaQuery.sizeOf(context).width-884,
                                      height: 65,
                                      child: provider.currentSchedule[index].containsKey('VL')? provider.currentSchedule[index]['VL'].length > 0 ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for(int vIndex=0; vIndex<provider.currentSchedule[index]['VL'].length;vIndex++)
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: provider.currentSchedule[index]['VL'][vIndex]['Status']==0 ? Colors.grey :
                                                      provider.currentSchedule[index]['VL'][vIndex]['Status']==1 ? Colors.greenAccent :
                                                      provider.currentSchedule[index]['VL'][vIndex]['Status']==2 ? Colors.orangeAccent:
                                                      provider.currentSchedule[index]['VL'][vIndex]['Status']==3 ? Colors.redAccent : Colors.lightBlueAccent,
                                                      backgroundImage: const AssetImage('assets/images/valve.png'),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text('${provider.currentSchedule[index]['VL'][vIndex]['Name']}', style: const TextStyle(fontSize: 10),),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ) :
                                      const Center(child: Text('-----')) : const Center(child: Text('-----')),
                                    ),*/
                                  ],
                                )
                              ),
                              SizedBox(
                                width: 45,
                                child:  Center(
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
                                  ),
                              ),
                            ],
                          ),
                          Container(color:myTheme.primaryColor.withOpacity(0.2), height: 3),
                        ],
                      ),
                  ],
                ),
              ):
              const Center(child: Text('Current Schedule not Available')),
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
