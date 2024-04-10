import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/CurrentScheduleFinal.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/NextSchedule.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/UpcomingProgram.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/MainLine.dart';
import 'Dashboard/MainLineLocal.dart';
import 'Dashboard/RunByManual.dart';
import 'ProgramSchedule.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key, required this.userID, required this.customerID, required this.type, required this.customerName, required this.mobileNo, required this.siteData}) : super(key: key);
  final int userID, customerID, type;
  final String customerName, mobileNo;
  final DashboardModel siteData;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> with SingleTickerProviderStateMixin {

  int wifiStrength = 0, siteIndex = 0;
  String lastSyncData = '';


  @override
  void initState() {
    super.initState();
    String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
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
        if (data['2400'][0].containsKey('2401')) {
          for (var item in data['2400'][0]['2401']) {
            if (item is Map<String, dynamic>) {
              try {
                int position = getNodePositionInNodeList(0, item['SNo']);
                if (position != -1) {
                  widget.siteData.nodeList[position].status = item['Status'];
                  widget.siteData.nodeList[position].batVolt = item['BatVolt'];
                  widget.siteData.nodeList[position].slrVolt = item['SVolt'];
                  widget.siteData.nodeList[position].rlyStatus = [];
                  if (item['RlyStatus'] != null) {
                    List<dynamic> rlyStatusJsonList = item['RlyStatus'];
                    List<RelayStatus> rlyStatusList = rlyStatusJsonList.map((rs) => RelayStatus.fromJson(rs)).toList();
                    widget.siteData.nodeList[position].rlyStatus = rlyStatusList;
                  }
                } else {
                  print('${item['SNo']} The serial number not found');
                }
              } catch (e) {
                print('Error updating node properties: $e');
              }
            }
          }
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
          MainLine(siteData: widget.siteData),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: CurrentScheduleFinal(siteData: widget.siteData, customerID: widget.customerID),
          ),
          //CurrentSchedule(siteData: widget.siteData),
          provider.flowMeter.isNotEmpty? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: Image.asset('assets/images/dp_flowmeter.png',),
              ),
              SizedBox(
                height: 70,
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const Text('0000 - m3/h', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                    const Text('Nominal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const Text('0000 - m3/h', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ):
          const SizedBox(),
          provider.nextSchedule.isNotEmpty? Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NextSchedule(siteData: widget.siteData, userID: widget.userID, customerID: widget.customerID),
          ):
          const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: UpcomingProgram(siteData: widget.siteData),
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
