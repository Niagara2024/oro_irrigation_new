import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/NextSchedule.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/UpcomingProgram.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/node_model.dart';
import '../../constants/MQTTManager.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/CurrentSchedule.dart';
import 'Dashboard/CustomerHome.dart';
import 'Dashboard/PumpLineCentral.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key, required this.userID, required this.customerID, required this.type, required this.customerName, required this.mobileNo, required this.siteData, required this.crrIrrLine, required this.masterInx, required this.lineIdx}) : super(key: key);
  final int userID, customerID, type, masterInx, lineIdx;
  final String customerName, mobileNo;
  final DashboardModel siteData;
  final IrrigationLine crrIrrLine;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {

  int wifiStrength = 0, siteIndex = 0;

  List<RelayStatus> rlyStatusList = [];

  @override
  void initState() {
    super.initState();
    liveSync();
    print(widget.crrIrrLine.name);
  }

  void liveSync(){
    Future.delayed(const Duration(seconds: 2), () {
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[widget.masterInx].deviceId}');
    });
  }


  @override
  Widget build(BuildContext context) {

    if(widget.siteData.master[widget.masterInx].irrigationLine[widget.lineIdx].sNo==0){
      return CustomerHome(currentMaster: widget.siteData.master[widget.masterInx],);
    }else{
      final filteredScheduledPrograms = filterProgramsByCategory(Provider.of<MqttPayloadProvider>(context).scheduledProgram, widget.crrIrrLine.id);
      final filteredProgramsQueue = filterProgramsQueueByCategory(Provider.of<MqttPayloadProvider>(context).programQueue, widget.crrIrrLine.id);
      final filteredCurrentSchedule = filterCurrentScheduleByCategory(Provider.of<MqttPayloadProvider>(context).currentSchedule, widget.crrIrrLine.id);
      final nodeList = Provider.of<MqttPayloadProvider>(context).nodeList;

      try{
        for (var items in nodeList) {
          if (items is Map<String, dynamic>) {
            try {
              int position = getNodePositionInNodeList(widget.masterInx, items['DeviceId']);
              if (position != -1) {
                List<dynamic> rlyStatuses = items['RlyStatus'];
                Map<int, int> statusMap = {};
                try{
                  statusMap = {for (var item in rlyStatuses) item['S_No']: item['Status']};
                }catch(e){
                  statusMap = {for (var item in rlyStatuses) item.S_No: item.Status};
                }

                for (var line in widget.siteData.master[widget.masterInx].irrigationLine) {
                  // Update mainValves
                  for (var mainValve in line.mainValve) {
                    if (statusMap.containsKey(mainValve.sNo)) {
                      mainValve.status = statusMap[mainValve.sNo]!;
                    }
                  }
                  // Update valves
                  for (var valve in line.valve) {
                    if (statusMap.containsKey(valve.sNo)) {
                      valve.status = statusMap[valve.sNo]!;
                    }
                  }
                }
              }else{
                print('${items['SNo']} The serial number not found');
              }
            } catch (e) {
              print('Error updating node properties: $e');
            }
          }
        }
        setState(() {
          widget.crrIrrLine;
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
                    DisplayIrrigationLine(irrigationLine: widget.crrIrrLine, currentSchedule: filteredCurrentSchedule,),
                  ],
                ),
              ),
            ),
            filteredCurrentSchedule.isNotEmpty? CurrentSchedule(siteData: widget.siteData, customerID: widget.customerID, currentSchedule: filteredCurrentSchedule,):
            const SizedBox(),
            filteredProgramsQueue.isNotEmpty? NextSchedule(siteData: widget.siteData, userID: widget.userID, customerID: widget.customerID, programQueue: filteredProgramsQueue,):
            const SizedBox(),
            filteredScheduledPrograms.isNotEmpty? UpcomingProgram(siteData: widget.siteData, customerId: widget.customerID, scheduledPrograms: filteredScheduledPrograms,):
            const SizedBox(),
            const SizedBox(height: 8,),
          ],
        ),
      );
    }

  }

  String getCurrentDateAndTime() {
    var nowDT = DateTime.now();
    return '${DateFormat('MMMM dd, yyyy').format(nowDT)}-${DateFormat('hh:mm:ss').format(nowDT)}';
  }

  int getNodePositionInNodeList(int mIndex, String decId) {
    for (int i = 0; i < widget.siteData.master[mIndex].liveData[0].nodeList.length; i++) {
      if (widget.siteData.master[mIndex].liveData[0].nodeList[i].deviceId == decId) {
        return i;
      }
    }
    return -1;
  }

  List<ScheduledProgram> filterProgramsByCategory(List<ScheduledProgram> prg, String cat) {
    return prg.where((prg) => prg.progCategory.contains(cat)).toList();
  }

  List<ProgramQueue> filterProgramsQueueByCategory(List<ProgramQueue> prQ, String cat) {
    return prQ.where((prQ) => prQ.programCategory.contains(cat)).toList();
  }

  List<CurrentScheduleModel> filterCurrentScheduleByCategory(List<CurrentScheduleModel> cs, String category) {
    return cs.where((cs) => cs.programCategory.contains(category)).toList();
  }

}


class DisplayIrrigationLine extends StatefulWidget {
  const DisplayIrrigationLine({Key? key, required this.irrigationLine, required this.currentSchedule}) : super(key: key);
  final IrrigationLine irrigationLine;
  final List<CurrentScheduleModel> currentSchedule;

  @override
  State<DisplayIrrigationLine> createState() => _DisplayIrrigationLineState();
}

class _DisplayIrrigationLineState extends State<DisplayIrrigationLine> {


  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> valveWidgets = [
      ...widget.irrigationLine.mainValve.map((mv) => MainValveWidget(mv: mv, status: mv.status,)).toList(),
      ...widget.irrigationLine.valve.map((vl) => ValveWidget(vl: vl, status: vl.status,)).toList(),
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
            status == 0 ? 'assets/images/dp_main_valve_not_open.png':
            status == 1? 'assets/images/dp_main_valve_open.png':
            status == 2? 'assets/images/dp_main_valve_wait.png':
            'assets/images/dp_main_valve_closed.png',
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
            status == 0? 'assets/images/valve_gray.png':
            status == 1? 'assets/images/valve_green.png':
            status == 2? 'assets/images/valve_orange.png':
            'assets/images/valve_red.png',
          ),
          const SizedBox(height: 4),
          Text(vl.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
        ],
      ),
    );
  }
}
