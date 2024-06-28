import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import '../Dashboard/SentAndReceived.dart';

class PumpDashboard extends StatefulWidget {
  const PumpDashboard({Key? key, required this.siteData, required this.masterIndex, required this.customerId}) : super(key: key);
  final DashboardModel siteData;
  final int customerId, masterIndex;

  @override
  State<PumpDashboard> createState() => _PumpDashboardState();
}

class _PumpDashboardState extends State<PumpDashboard> {

  String valR ='000', valY ='000', valB ='000';
  String cVersion ='';
  int wifiStrength = 0;
  int batVolt = 0;

  List<CMType1> pumpList = [];

  @override
  void initState() {
    super.initState();

    if (widget.siteData.master[widget.masterIndex].pumpLive[3] is CMType2) {
      List<String> rybValue = (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).v!.split(',');
      valR = rybValue[0]; valY = rybValue[1]; valB = rybValue[2];
      cVersion = (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).vs!;

      wifiStrength = (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).ss!;
      batVolt = (widget.siteData.master[widget.masterIndex].pumpLive[3] as CMType2).b!;

      pumpList =  widget.siteData.master[widget.masterIndex].pumpLive.whereType<CMType1>().cast<CMType1>().toList();
    }


    syncLive();
  }

  void syncLive(){
    String livePayload = jsonEncode({"sentSMS": "#live"});
    Future.delayed(const Duration(seconds: 3), () {
      MQTTManager().publish(livePayload, 'AppToFirmware/${widget.siteData.master[widget.masterIndex].deviceId}');
    });
  }

  @override
  Widget build(BuildContext context) {

    final pcLivePayload = Provider.of<MqttPayloadProvider>(context).pumpControllerLive;
    //Map<String, dynamic> json = jsonDecode(pcLivePayload.isNotEmpty? pcLivePayload:null);


    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          SizedBox(
            width: 300,
            height: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    border: Border.all(
                      color: Colors.green,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Expanded(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: SizedBox(
                          width: 45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(wifiStrength == 0? Icons.wifi_off:
                              wifiStrength >= 1 && wifiStrength <= 20 ? Icons.network_wifi_1_bar_outlined:
                              wifiStrength >= 21 && wifiStrength <= 40 ? Icons.network_wifi_2_bar_outlined:
                              wifiStrength >= 41 && wifiStrength <= 60 ? Icons.network_wifi_3_bar_outlined:
                              wifiStrength >= 61 && wifiStrength <= 80 ? Icons.network_wifi_3_bar_outlined:
                              Icons.wifi, color: Colors.black,),
                              Text('$wifiStrength%'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox(
                        width: 45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('MOTOR OFF'),
                            Text('ams : 100'),
                          ],
                        ),
                      )),
                      SizedBox(
                        width: 45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(batVolt == 0? Icons.battery_alert_sharp:
                            batVolt >= 1 && batVolt <= 20 ? Icons.battery_1_bar:
                            batVolt >= 21 && batVolt <= 40 ? Icons.battery_2_bar:
                            batVolt >= 41 && batVolt <= 60 ? Icons.battery_3_bar:
                            batVolt >= 61 && batVolt <= 80 ? Icons.battery_4_bar:
                            Icons.battery_6_bar, color: Colors.black,),
                            Text('$batVolt%'),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
                /*IconButton(
                  tooltip: 'refresh',
                  icon: const Icon(Icons.refresh, color: Colors.teal,),
                  onPressed: (){
                    String livePayload = jsonEncode({"sentSMS": "#live"});
                    MQTTManager().publish(livePayload, 'AppToFirmware/${widget.siteData.master[widget.masterIndex].deviceId}');
                  },
                ),*/
                Card(
                    elevation: 2.0,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(05.0),
                    ),
                    child:  SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(flex:1, child: Container(
                            color: Colors.red.shade100,
                            child: Center(child: Text('R : $valR V')),
                          )),
                          Flexible(flex:1, child: Container(
                            color: Colors.yellow.shade100,
                            child: Center(child: Text('Y : $valY V')),
                          )),
                          Flexible(flex:1, child: Container(
                            color: Colors.blue.shade100,
                            child: Center(child: Text('B : $valB V')),
                          )),
                        ],
                      ),
                    )
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.3,
                    ),
                    scrollDirection: Axis.vertical,
                    itemCount: pumpList.length,
                    itemBuilder: (context, index) {
                      List<String> floatVal = pumpList[index].ft!.split(':');
                      return Card(
                        elevation: 1.0,
                        surfaceTintColor: Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(05.0),
                        ),
                        child:  Column(
                          children: [
                            SizedBox(
                              width: 300,
                              height: 75,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(child: Image(image: AssetImage(pumpList[index].st==1? "assets/GifFile/motor_on_new.gif":"assets/GifFile/motor_off_new.gif"), width: 75,)),
                                    const SizedBox(width: 30,),
                                    Material(
                                      elevation: 8.0, // Add shadow elevation
                                      shape: const CircleBorder(), // Ensure the shadow has the same shape as the CircleAvatar
                                      child: CircleAvatar(
                                        radius: 22.0,
                                        backgroundColor: Colors.green,
                                        child: IconButton(tooltip:'Start', onPressed: (){
                                          String onPayload = jsonEncode({"sentSMS": "MOTOR${index+1}ON"});
                                          MQTTManager().publish(onPayload, 'AppToFirmware/${widget.siteData.master[widget.masterIndex].deviceId}');
                                        }, icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    Material(
                                      elevation: 8.0, // Add shadow elevation
                                      shape: const CircleBorder(), // Ensure the shadow has the same shape as the CircleAvatar
                                      child: CircleAvatar(
                                        radius: 22.0,
                                        backgroundColor: Colors.redAccent,
                                        child: IconButton(tooltip:'Stop',onPressed: (){
                                          String onPayload = jsonEncode({"sentSMS": "MOTOR${index+1}OF"});
                                          MQTTManager().publish(onPayload, 'AppToFirmware/${widget.siteData.master[widget.masterIndex].deviceId}');
                                        }, icon: const Icon(Icons.power_settings_new, color: Colors.white,)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              height: 100,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              pumpList[index].ft=='-:-:-:-'? const Text('--'):
                                              Row(
                                                children: [
                                                  Text('${floatVal[0]}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                                  const Text(' | ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.teal),),
                                                  Text('${floatVal[1]}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                                  const Text(' | ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.teal),),
                                                  Text('${floatVal[2]}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                                  const Text(' | ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.teal),),
                                                  Text('${floatVal[3]}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                                ],
                                              ),
                                              const Text('Float Status', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(pumpList[index].lv=='-'? '--':'${pumpList[index].lv} %', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                              const Text('Level', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text('${pumpList[index].ph}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                              const Text('Phase', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(pumpList[index].pr=='-'?'--':'${pumpList[index].pr}/bar', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                              const Text('Pressure', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(pumpList[index].wm=='-'?'--':'${pumpList[index].wm}/bar', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                              const Text('Flow rate', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(pumpList[index].cf=='-'?'--':'${pumpList[index].cf}/Lts', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),),
                                              const Text('C-Flow', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 300,
                              height: 32,
                              color:Colors.teal.shade100,
                              child: const Center(child: Text('reason text here', style: TextStyle(fontSize: 11),)),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(10.0),
                  ),
                ),
                const Divider(thickness: 0.3,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Version : ',  style: TextStyle(fontWeight: FontWeight.normal),),
                    Text(cVersion, style: const TextStyle(fontWeight: FontWeight.bold),),
                  ],
                )
              ],
            ),
          ),
          const VerticalDivider(thickness: 0.3,),
          Expanded(
            child: DefaultTabController(
              length: 5, // Number of tabs
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.pinkAccent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Power & Motor'),
                      Tab(text: 'Sent & Received'),
                      Tab(text: 'Report'),
                      Tab(text: 'Logs'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const Center(child: Text('Tab 1 Content')),
                        SentAndReceived(customerID: widget.customerId, controllerId: widget.siteData.master[widget.masterIndex].controllerId, from: 'Pump',),
                        const Center(child: Text('Tab 3 Content')),
                        const Center(child: Text('Tab 4 Content')),
                        const Center(child: Text('Tab 5 Content')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




