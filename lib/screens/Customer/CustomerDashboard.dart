import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/NextSchedule.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/UpcomingProgram.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../constants/MQTTManager.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/CurrentSchedule.dart';
import 'Dashboard/PumpLineCentral.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key, required this.userID, required this.customerID, required this.type, required this.customerName, required this.mobileNo, required this.siteData, required this.crrIrrLine}) : super(key: key);
  final int userID, customerID, type;
  final String customerName, mobileNo;
  final DashboardModel siteData;
  final IrrigationLine crrIrrLine;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {

  int wifiStrength = 0, siteIndex = 0;

  @override
  void initState() {
    super.initState();
    liveSync();
    print(widget.crrIrrLine.name);
  }

  void liveSync(){
    Future.delayed(const Duration(seconds: 2), () {
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
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
        }

      });
    }
    catch(e){
      print(e);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PumpLineCentral(currentSiteData: widget.siteData, crrIrrLine:  widget.crrIrrLine,),
                  Divider(height: 0, color: Colors.grey.shade300),
                  Container(height: 4, color: Colors.white24),
                  Padding(
                    padding: const EdgeInsets.only(left: 05, right: 00),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  DisplayIrrigationLine(irrigationLine: widget.crrIrrLine),
                ],
              ),
            ),
          ),
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
    /*List<NodeModel> nodeList = widget.siteData.nodeList;
    for (int i = 0; i < nodeList.length; i++) {
      if (nodeList[i].serialNumber == srlNo) {
        return i;
      }
    }*/
    return -1;
  }

}


class DisplayIrrigationLine extends StatefulWidget {
  const DisplayIrrigationLine({Key? key, required this.irrigationLine}) : super(key: key);
  final IrrigationLine irrigationLine;

  @override
  State<DisplayIrrigationLine> createState() => _DisplayIrrigationLineState();
}

class _DisplayIrrigationLineState extends State<DisplayIrrigationLine> {

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;
    // Combine main valves and valves into a single list of widgets
    final List<Widget> valveWidgets = [
      ...widget.irrigationLine.mainValve.map((mv) => MainValveWidget(mv: mv, status: getStatusForValve(mv.hid, currentSchedule),)).toList(),
      ...widget.irrigationLine.valve.map((vl) => ValveWidget(vl: vl, status: getStatusForValve(vl.id, currentSchedule),)).toList(),
    ];

    int crossAxisCount = (screenWidth / 95).floor().clamp(1, double.infinity).toInt();
    int rowCount = (valveWidgets.length / crossAxisCount).ceil();
    double itemHeight = 70;
    double gridHeight = rowCount * (itemHeight + 2);

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: gridHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.25,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
          ),
          itemCount: valveWidgets.length,
          itemBuilder: (context, index) {
            return Container(color: Colors.white, child: valveWidgets[index]);
          },
        ),
      ),
    );
  }

  int getStatusForValve(String name, List<dynamic> currentSchedule) {
    for (final scheduleItem in currentSchedule) {
      //print(scheduleItem);
      if (scheduleItem.containsKey('VL')) {
        if (scheduleItem['VL'] != null) {
          final vlList = scheduleItem['VL'] as List<dynamic>;
          final valve = vlList.firstWhere((v) => v['Name'] == name, orElse: () => null);
          if (valve != null) {
            return valve['Status'] ?? 0;
          }
        }
      } else if (scheduleItem.containsKey('MV')) {
        if (scheduleItem['MV'] != null) {
          final mvlList = scheduleItem['MV'] as List<dynamic>;
          final mValve = mvlList.firstWhere((v) => v['Name'] == name, orElse: () => null);
          if (mValve != null) {
            return mValve['Status'] ?? 0;
          }
        }
      }
    }
    return 0;
  }

}

class MainValveWidget extends StatelessWidget {
  final MainValve mv;
  final int status;
  const MainValveWidget({super.key, required this.mv, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 100,
            height: 13.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VerticalDivider(width: 0,),
                SizedBox(width: 4,),
                VerticalDivider(width: 0,),
              ],
            ),
          ),
          Image.asset(
            width: 35,
            height: 35,
            status == 0
                ? 'assets/images/dp_main_valve_not_open.png'
                : status == 1
                ? 'assets/images/dp_main_valve_open.png'
                : status == 2
                ? 'assets/images/dp_main_valve_wait.png'
                : 'assets/images/dp_main_valve_closed.png',
          ),
          const SizedBox(height: 5),
          Text(mv.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
        ],
      ),
    );
  }
}

class ValveWidget extends StatelessWidget {
  final Valve vl;
  final int status;
  const ValveWidget({super.key, required this.vl, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 100,
            height: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VerticalDivider(width: 0,),
                SizedBox(width: 4,),
                VerticalDivider(width: 0,),
              ],
            ),
          ),
          Image.asset(
            width: 35,
            height: 35,
            status == 0
                ? 'assets/images/valve_gray.png'
                : status == 1
                ? 'assets/images/valve_green.png'
                : status == 2
                ? 'assets/images/valve_orange.png'
                : 'assets/images/valve_red.png',
          ),
          const SizedBox(height: 4),
          Text(vl.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
        ],
      ),
    );
  }
}


