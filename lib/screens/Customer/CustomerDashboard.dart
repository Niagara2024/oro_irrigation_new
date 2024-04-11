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
        /*if (data['2400'][0].containsKey('2401')) {
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
        }*/

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
            padding: const EdgeInsets.only(top: 8),
            child: DisplayIrrigationLine(siteData: widget.siteData),
          ),
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
              const SizedBox(
                height: 70,
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    Text('0000 - m3/h', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
                    Text('Nominal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    Text('0000 - m3/h', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11)),
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
      height: widget.siteData.irrigationLine.length * 135,
      child: ListView.builder(
        itemCount: widget.siteData.irrigationLine.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: myTheme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: Text(widget.siteData.irrigationLine[index].name.toUpperCase(),  style: const TextStyle(color: Colors.white)),
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color:myTheme.primaryColor.withOpacity(0.3),
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
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.siteData.irrigationLine[index].mainValve.length,
                            itemBuilder: (BuildContext context, int vlIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
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
                          width: widget.siteData.irrigationLine[index].valve.length * 116,
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.siteData.irrigationLine[index].valve.length,
                            itemBuilder: (BuildContext context, int vlIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
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
                ],
              ),
            ),
          );
        },
      ),
    );
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
              title: const Text('IRRIGATION LINE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 100,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child : ListView.builder(
                  itemCount: widget.siteData.irrigationLine.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Text(widget.siteData.irrigationLine[index].name)
                      ],
                    );
                  },
                ),
                /*child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.siteData.irrigationLine.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/images/valve.png'),
                        ),
                      ],
                    );
                  },
                ),*/
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFertCheImage(int cIndex, int status, int cheLength) {
    String imageName;

    if(cIndex == cheLength - 1){
      imageName='dp_fert_channel_last';
    }else{
      imageName='dp_fert_channel_center';
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      case 3:
        imageName += '.png';
        break;
      default:
        imageName += '_r.png';
    }

    return Image.asset('assets/images/$imageName');

  }

}


