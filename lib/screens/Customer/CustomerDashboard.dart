import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/LocalSite.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/NextSchedule.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/UpcomingProgram.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../constants/MQTTManager.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/CurrentSchedule.dart';
import 'Dashboard/PumpLineCentral.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key, required this.userID, required this.customerID, required this.type, required this.customerName, required this.mobileNo, required this.siteData}) : super(key: key);
  final int userID, customerID, type;
  final String customerName, mobileNo;
  final DashboardModel siteData;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {

  int wifiStrength = 0, siteIndex = 0;
  String lastSyncData = '';

  @override
  void initState() {
    super.initState();
    liveSync();
  }

  void liveSync(){
    Future.delayed(const Duration(seconds: 2), () {
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
    });
  }


  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MqttPayloadProvider>(context, listen: true);
    try{
      print(provider.receivedDashboardPayload);
      Map<String, dynamic> data = jsonDecode(provider.receivedDashboardPayload);
      setState(() {
        if (data['2400'][0].containsKey('WifiStrength')) {
          wifiStrength = data['2400'][0]['WifiStrength'];
          lastSyncData = getCurrentDateAndTime();
        }

      });
    }
    catch(e){
      print(e);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          PumpLineCentral(siteData: widget.siteData),
          LocalSite(siteData: widget.siteData),
          //DisplayIrrigationLine(siteData: widget.siteData),
          CurrentSchedule(siteData: widget.siteData, customerID: widget.customerID),
          provider.nextSchedule.isNotEmpty?
          NextSchedule(siteData: widget.siteData, userID: widget.userID, customerID: widget.customerID):
          const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: UpcomingProgram(siteData: widget.siteData, customerId: widget.customerID,),
          ),
        ],
      ),
    );
  }

  String getCurrentDateAndTime() {
    var nowDT = DateTime.now();
    return '${DateFormat('MMMM dd, yyyy').format(nowDT)}-${DateFormat('hh:mm:ss').format(nowDT)}';
  }


  int getNodePositionInNodeList(int siteIndex, int srlNo)
  {
    List<NodeModel> nodeList = widget.siteData.nodeList;
    for (int i = 0; i < nodeList.length; i++) {
      if (nodeList[i].serialNumber == srlNo) {
        return i;
      }
    }
    return -1;
  }

}


class DisplayIrrigationLine extends StatefulWidget {
  const DisplayIrrigationLine({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<DisplayIrrigationLine> createState() => _DisplayIrrigationLineState();
}

class _DisplayIrrigationLineState extends State<DisplayIrrigationLine> {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: widget.siteData.irrigationLine.length * 107,
      child: ListView.builder(
        itemCount: widget.siteData.irrigationLine.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: widget.siteData.irrigationLine[index].mainValve.length * 116,
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.siteData.irrigationLine[index].mainValve.length,
                                itemBuilder: (BuildContext context, int vlIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 3),
                                    child: SizedBox(
                                      height: 50,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          Image.asset('assets/images/dp_main_valve_not_open.png', width: 40, height: 40,),
                                          const SizedBox(height: 5),
                                          Text(widget.siteData.irrigationLine[index].mainValve[vlIndex].name, style: const TextStyle(fontSize: 11),)
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width-280,
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.siteData.irrigationLine[index].valve.length,
                                itemBuilder: (BuildContext context, int vlIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 3),
                                    child: SizedBox(
                                      height: 50,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          Image.asset('assets/images/valve_gray.png', width: 40, height: 40,),
                                          const SizedBox(height: 5),
                                          Text(widget.siteData.irrigationLine[index].valve[vlIndex].name, style: const TextStyle(fontSize: 11),)
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7.5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.cyan.shade200,
                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                        ),
                        child: Text(widget.siteData.irrigationLine[index].name.toUpperCase(),  style: const TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}


