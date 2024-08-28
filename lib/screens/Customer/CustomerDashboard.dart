import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/NextSchedule.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/ScheduledProgramList.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/MyFunction.dart';
import '../../constants/snack_bar.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/CurrentSchedule.dart';
import 'Dashboard/DisplayAllLine.dart';
import 'Dashboard/PumpLineCentral.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key, required this.userID, required this.customerID, required this.type, required this.customerName, required this.mobileNo, required this.siteData, required this.masterInx, required this.lineIdx}) : super(key: key);
  final int userID, customerID, type, masterInx, lineIdx;
  final String customerName, mobileNo;
  final DashboardModel siteData;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late IrrigationLine crrIrrLine;
  int wifiStrength = 0, siteIndex = 0;
  List<RelayStatus> rlyStatusList = [];
  bool showNoHwCm = false;

  @override
  void initState() {
    super.initState();
    liveSync();
  }

  void liveSync(){
    Future.delayed(const Duration(seconds: 2), () {
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[widget.masterInx].deviceId}');
    });
  }

  int? getIrrigationPauseFlag(String line, List<dynamic> payload2408) {
    for (var data in payload2408) {
      if (data["Line"] == line) {
        return data["IrrigationPauseFlag"];
      }
    }
    return null;
  }

  String getContentByCode(int code) {
    return GemLineSSReasonCode.fromCode(code).content;
  }


  @override
  Widget build(BuildContext context) {

    if(widget.siteData.master[widget.masterInx].irrigationLine.isNotEmpty){
      crrIrrLine = widget.siteData.master[widget.masterInx].irrigationLine[widget.lineIdx];
    }else{
      print('irrigation line empty');
    }

    if(widget.siteData.master[widget.masterInx].irrigationLine.isNotEmpty){
      var screenWidth = MediaQuery.of(context).size.width;
      final provider = Provider.of<MqttPayloadProvider>(context);

      var liveSync = provider.liveSync;
      Duration lastCommunication = provider.lastCommunication;

      try{
        for (var items in provider.nodeList) {
          if (items is Map<String, dynamic>){
            try {
              int position = getNodePositionInNodeList(widget.masterInx, items['DeviceId']);
              if (position != -1) {
                List<dynamic> rlyStatuses = items['RlyStatus'];
                Map<int, int> statusMap = {};
                try{
                  statusMap = {for (var item in rlyStatuses) item['S_No']:item['Status']};
                }catch(e){
                  statusMap = {for (var item in rlyStatuses) item.S_No:item.Status};
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
          crrIrrLine;
        });
      }
      catch(e){
        print(e);
      }

      if(widget.siteData.master[widget.masterInx].irrigationLine[widget.lineIdx].sNo==0){
        return Column(
          children: [
            lastCommunication.inMinutes >= 10? lostCommunication():
            const SizedBox(),
            liveSync? stoppedAnimation(): const SizedBox(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    DisplayAllLine(currentMaster: (widget.siteData.master[widget.masterInx]), provider: provider,),
                    provider.currentSchedule.isNotEmpty? CurrentSchedule(siteData: widget.siteData, customerID: widget.customerID, currentSchedule: provider.currentSchedule,):
                    const SizedBox(),
                    provider.programQueue.isNotEmpty? NextSchedule(siteData: widget.siteData, userID: widget.userID, customerID: widget.customerID, programQueue: provider.programQueue,):
                    const SizedBox(),
                    provider.scheduledProgram.isNotEmpty? ScheduledProgramList(siteData: widget.siteData, customerId: widget.customerID, scheduledPrograms: provider.scheduledProgram, masterInx: widget.masterInx,):
                    const SizedBox(),
                    const SizedBox(height: 8,),
                  ],
                ),
              ),
            ),
          ],
        );
      }else{
        int? irrigationPauseFlag = 0;
        final filteredScheduledPrograms = filterProgramsByCategory(Provider.of<MqttPayloadProvider>(context).scheduledProgram, crrIrrLine.id);
        final filteredProgramsQueue = filterProgramsQueueByCategory(Provider.of<MqttPayloadProvider>(context).programQueue, crrIrrLine.id);
        final filteredCurrentSchedule = filterCurrentScheduleByCategory(Provider.of<MqttPayloadProvider>(context).currentSchedule, crrIrrLine.id);
        filteredCurrentSchedule.insertAll(0, filterCurrentScheduleByProgramName(Provider.of<MqttPayloadProvider>(context).currentSchedule, 'StandAlone - Manual'));
        if(Provider.of<MqttPayloadProvider>(context).payload2408.isNotEmpty){
          irrigationPauseFlag = getIrrigationPauseFlag(crrIrrLine.id, Provider.of<MqttPayloadProvider>(context).payload2408);
        }

        return Column(
          children: [
            lastCommunication.inMinutes >= 10? lostCommunication():
            const SizedBox(),

            irrigationPauseFlag !=0? Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(03),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(child: Text(getContentByCode(irrigationPauseFlag!).toUpperCase(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black54),)),
                ),
              ),
            ):
            const SizedBox(),

            liveSync? stoppedAnimation(): const SizedBox(),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    screenWidth > 600 ? buildWideLayout(provider):
                    buildNarrowLayout(provider),
                    filteredCurrentSchedule.isNotEmpty? CurrentSchedule(siteData: widget.siteData, customerID: widget.customerID, currentSchedule: filteredCurrentSchedule,):
                    const SizedBox(),
                    filteredProgramsQueue.isNotEmpty? NextSchedule(siteData: widget.siteData, userID: widget.userID, customerID: widget.customerID, programQueue: filteredProgramsQueue,):
                    const SizedBox(),
                    filteredScheduledPrograms.isNotEmpty? ScheduledProgramList(siteData: widget.siteData, customerId: widget.customerID, scheduledPrograms: filteredScheduledPrograms, masterInx: widget.masterInx,):
                    const SizedBox(),
                    const SizedBox(height: 8,),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    }
    else{
      return const Center(child: Text('Site not configure'));
    }
  }

  Widget lostCommunication() {
    return Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(03),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(child: Text('No communication from controller, Please check your controller connection...'.toUpperCase(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.white70),)),
        ),
      ),
    );
  }

  Widget stoppedAnimation() {
    return Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: LinearProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        backgroundColor: Colors.grey[200],
        minHeight: 4,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget buildNarrowLayout(provider) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Card(
                  surfaceTintColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3,top: 3, bottom: 3),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: provider.irrigationPump.isNotEmpty? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //src pump
                              provider.sourcePump.isNotEmpty? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: DisplaySourcePump(deviceId: widget.siteData.master[widget.masterInx].deviceId, currentLineId: crrIrrLine.id, spList: provider.sourcePump,),
                              ):
                              const SizedBox(),

                              //sump
                              provider.irrigationPump.isNotEmpty? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: SizedBox(
                                  width: 52.50,
                                  height: 70,
                                  child : Stack(
                                    children: [
                                      provider.sourcePump.isNotEmpty? Image.asset('assets/images/dp_sump_src.png'):
                                      Image.asset('assets/images/dp_sump.png'),
                                    ],
                                  ),
                                ),
                              ):
                              const SizedBox(),

                              //i pump
                              provider.irrigationPump.isNotEmpty? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: DisplayIrrigationPump(currentLineId: crrIrrLine.id, deviceId: widget.siteData.master[widget.masterInx].deviceId, ipList: provider.irrigationPump,),
                              ):
                              const SizedBox(),

                              //sensor
                              for(int i=0; i<provider.payload2408.length; i++)
                                provider.payload2408.isNotEmpty?  Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: provider.payload2408[i]['Line'].contains(crrIrrLine.id)? DisplaySensor(crInx: i):null,
                                ) : const SizedBox(),

                              //filter
                              provider.filtersCentral.isNotEmpty? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: DisplayFilter(currentLineId: crrIrrLine.id, filtersSites: provider.filtersCentral,),
                              ): const SizedBox(),
                            ],
                          ):
                          const SizedBox(height: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('PUMP STATION',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7,),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  surfaceTintColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3,top: 3, bottom: 3),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7, right: 5),
                            child: provider.irrigationPump.isNotEmpty? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //fertilizer Central
                                provider.fertilizerCentral.isNotEmpty? DisplayCentralFertilizer(currentLineId: crrIrrLine.id,): const SizedBox(),

                                //local
                                provider.irrigationPump.isNotEmpty? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        (provider.fertilizerCentral.isNotEmpty || provider.filtersCentral.isNotEmpty) && provider.fertilizerLocal.isNotEmpty? SizedBox(
                                          width: 4.5,
                                          height: 150,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 42),
                                                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                                              ),
                                              const SizedBox(width: 4.5,),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 45),
                                                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
                                              ),
                                            ],
                                          ),
                                        ):
                                        const SizedBox(),
                                        provider.filtersLocal.isNotEmpty? Padding(
                                          padding: EdgeInsets.only(top: provider.fertilizerLocal.isNotEmpty?38.4:0),
                                          child: LocalFilter(currentLineId: crrIrrLine.id, filtersSites: provider.filtersLocal,),
                                        ):
                                        const SizedBox(),
                                        provider.fertilizerLocal.isNotEmpty? DisplayLocalFertilizer(currentLineId: crrIrrLine.id,):
                                        const SizedBox(),
                                      ],
                                    ),
                                  ],
                                ):
                                const SizedBox(height: 20)
                              ],
                            ):
                            const SizedBox(height: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('FERTILIZER STATION',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7,),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  surfaceTintColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                  elevation: 5,
                  child: DisplayIrrigationLine(irrigationLine: crrIrrLine, currentLineId: crrIrrLine.id, currentMaster: widget.siteData.master[widget.masterInx], rWidth: 0,),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('IRRIGATION LINE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWideLayout(MqttPayloadProvider provider) {

    if(provider.filtersCentral.isEmpty && provider.filtersLocal.isEmpty
        && provider.fertilizerCentral.isEmpty && provider.fertilizerLocal.isEmpty){

      int? irrigationPauseFlag = getIrrigationPauseFlag(crrIrrLine.id, Provider.of<MqttPayloadProvider>(context).payload2408);
      int rdWidth = 0;
      if(irrigationPauseFlag !=2){
        rdWidth = (provider.irrigationPump.length+provider.sourcePump.length+1)*70+175;
      }else{
        rdWidth = (provider.irrigationPump.length+provider.sourcePump.length+1)*70;
      }

      return Padding(
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
          child: Padding(
            padding: const EdgeInsets.only(top: 9, left: 5, right: 5),
            child: provider.irrigationPump.isNotEmpty? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                provider.sourcePump.isNotEmpty? Padding(
                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                  child: DisplaySourcePump(deviceId: widget.siteData.master[widget.masterInx].deviceId, currentLineId: crrIrrLine.id, spList: provider.sourcePump,),
                ):
                const SizedBox(),
                provider.irrigationPump.isNotEmpty? Padding(
                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                  child: SizedBox(
                    width: 52.50,
                    height: 70,
                    child : Stack(
                      children: [
                        provider.sourcePump.isNotEmpty? Image.asset('assets/images/dp_sump_src.png'):
                        Image.asset('assets/images/dp_sump.png'),
                      ],
                    ),
                  ),
                ):
                const SizedBox(),
                provider.irrigationPump.isNotEmpty? Padding(
                  padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                  child: DisplayIrrigationPump(currentLineId: crrIrrLine.id, deviceId: widget.siteData.master[widget.masterInx].deviceId, ipList: provider.irrigationPump,),
                ):
                const SizedBox(),

                if(provider.filtersCentral.isEmpty)
                  for(int i=0; i<provider.payload2408.length; i++)
                    provider.payload2408.isNotEmpty?  Padding(
                      padding: EdgeInsets.only(top: provider.fertilizerCentral.isNotEmpty || provider.fertilizerLocal.isNotEmpty? 38.4:0),
                      child: provider.payload2408[i]['Line'].contains(crrIrrLine.id)? DisplaySensor(crInx: i):null,
                    ) :
                    const SizedBox(),

                Expanded(
                  child: Column(
                    children: [
                      Divider(height: 5, color: Colors.grey.shade300),
                      Container(height: 3, color: Colors.white24),
                      Divider(height: 0, color: Colors.grey.shade300),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: DisplayIrrigationLine(irrigationLine: crrIrrLine, currentLineId: crrIrrLine.id, currentMaster: widget.siteData.master[widget.masterInx], rWidth: rdWidth,)),
                          irrigationPauseFlag !=2 ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextButton(
                              onPressed: () {
                                int prFlag = 0;
                                List<dynamic> records = provider.payload2408;
                                int sNoToCheck = crrIrrLine.sNo;
                                var record = records.firstWhere(
                                      (record) => record['S_No'] == sNoToCheck,
                                  orElse: () => null,
                                );
                                if (record != null) {
                                  bool isIrrigationPauseFlagZero = record['IrrigationPauseFlag'] == 0;
                                  if (isIrrigationPauseFlagZero) {
                                    prFlag = 1;
                                  } else {
                                    prFlag = 0;
                                  }
                                  String payLoadFinal = jsonEncode({
                                    "4900": [
                                      {
                                        "4901": "$sNoToCheck, $prFlag",
                                      }
                                    ]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[widget.masterInx].deviceId}');
                                } else {
                                  const GlobalSnackBar(code: 200, message: 'Controller connection lost...');
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(irrigationPauseFlag == 1 ? Colors.green : Colors.orange),
                                shape: WidgetStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  irrigationPauseFlag == 1
                                      ? const Icon(Icons.play_arrow_outlined, color: Colors.white)
                                      : const Icon(Icons.pause, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(
                                    irrigationPauseFlag == 1 ? 'RESUME THE LINE' : 'PAUSE THE LINE',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ):
                          const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ):
            const SizedBox(height: 20),
          ),
        ),
      );
    }

    return Padding(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PumpLineCentral(currentSiteData: widget.siteData, crrIrrLine:crrIrrLine, masterIdx: widget.masterInx, provider: provider,),
                  Divider(height: 0, color: Colors.grey.shade300),
                  Container(height: 4, color: Colors.white24),
                  Divider(height: 0, color: Colors.grey.shade300),
                  DisplayIrrigationLine(irrigationLine: crrIrrLine, currentLineId: crrIrrLine.id, currentMaster: widget.siteData.master[widget.masterInx], rWidth: 0,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  String getCurrentDateAndTime() {
    var nowDT = DateTime.now();
    return '${DateFormat('MMMM dd, yyyy').format(nowDT)}-${DateFormat('hh:mm:ss').format(nowDT)}';
  }

  int getNodePositionInNodeList(int mIndex, String decId) {
    for (int i = 0; i < widget.siteData.master[mIndex].gemLive[0].nodeList.length; i++) {
      if (widget.siteData.master[mIndex].gemLive[0].nodeList[i].deviceId == decId) {
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

  List<CurrentScheduleModel> filterCurrentScheduleByProgramName(List<CurrentScheduleModel> cs, String category) {
    return cs.where((cs) => cs.programName.contains(category)).toList();
  }

}


class DisplayIrrigationLine extends StatefulWidget {
  const DisplayIrrigationLine({Key? key, required this.irrigationLine, required this.currentLineId, required this.currentMaster, required this.rWidth}) : super(key: key);
  final MasterData currentMaster;
  final IrrigationLine irrigationLine;
  final String currentLineId;
  final int rWidth;

  @override
  State<DisplayIrrigationLine> createState() => _DisplayIrrigationLineState();
}

class _DisplayIrrigationLineState extends State<DisplayIrrigationLine> {


  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width-widget.rWidth;

    final List<Widget> valveWidgets;

    if(widget.currentLineId=='all'){
      valveWidgets = [
        for (var line in widget.currentMaster.irrigationLine) ...[
          ...line.mainValve.map((mv) => MainValveWidget(mv: mv, status: mv.status)).toList(),
          ...line.valve.map((vl) => ValveWidget(vl: vl, status: vl.status)).toList(),
        ]
      ];
    }else{
      valveWidgets = [
        ...widget.irrigationLine.mainValve.map((mv) => MainValveWidget(mv: mv, status: mv.status,)).toList(),
        ...widget.irrigationLine.valve.map((vl) => ValveWidget(vl: vl, status: vl.status,)).toList(),
      ];
    }

    int crossAxisCount = (screenWidth / 105).floor().clamp(1, double.infinity).toInt();
    int rowCount = (valveWidgets.length / crossAxisCount).ceil();
    double itemHeight = 72;
    double gridHeight = rowCount * (itemHeight + 5);

    return screenWidth>600? SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: gridHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.32,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
          ),
          itemCount: valveWidgets.length,
          itemBuilder: (context, index) {
            return Container(color: Colors.white, child: valveWidgets[index]);
          },
        ),
      ),
    ):
    SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: (valveWidgets.length / 5).ceil() * 70.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
          ),
          itemCount: valveWidgets.length,
          itemBuilder: (context, index) {
            return Container(child: valveWidgets[index]);
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          screenWidth>600? const SizedBox(
            width: 150,
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
          ):
          const SizedBox(),
          Image.asset(
            width: 35,
            height: 35,
            status == 0 ? 'assets/images/dp_main_valve_not_open.png':
            status == 1? 'assets/images/dp_main_valve_open.png':
            status == 2? 'assets/images/dp_main_valve_wait.png':
            'assets/images/dp_main_valve_closed.png',
          ),
          const SizedBox(height: 5),
          Text(mv.name.isNotEmpty? mv.name:mv.id, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          screenWidth>600? const SizedBox(
            width: 150,
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
          ):
          const SizedBox(),
          Image.asset(
            width: 35,
            height: 35,
            status == 0? 'assets/images/valve_gray.png':
            status == 1? 'assets/images/valve_green.png':
            status == 2? 'assets/images/valve_orange.png':
            'assets/images/valve_red.png',
          ),
          const SizedBox(height: 4),
          Text(vl.name.isNotEmpty? vl.name:vl.id, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10),),
        ],
      ),
    );
  }
}
