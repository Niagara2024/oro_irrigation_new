import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/Customer/Dashboard/DashBoardValve.dart';
import '../../../Models/Customer/Dashboard/DashboardDataProvider.dart';
import '../../../Models/Customer/Dashboard/LineOrSequence.dart';
import '../../../Models/Customer/Dashboard/ProgramList.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';

enum SegmentWithFlow {manual, duration, flow}

class RunByManual extends StatefulWidget {
  const RunByManual({Key? key, required this.customerID, required this.siteID, required this.controllerID, required this.siteName, required this.imeiNo, required this.callbackFunction}) : super(key: key);
  final int customerID, siteID, controllerID;
  final String siteName, imeiNo;
  final void Function(String msg) callbackFunction;

  @override
  State<RunByManual> createState() => _RunByManualState();
}

class _RunByManualState extends State<RunByManual>  with SingleTickerProviderStateMixin{

  late List<DashboardDataProvider> dashBoardData = [];
  List<ProgramList> programList = [];
  bool visibleLoading = false;
  int ddCurrentPosition = 0;
  int programId = 0;
  int standAloneMethod = 0;
  int startFlag = 0;
  String strFlow = '0';
  String strDuration = '00:00:00';
  String strProgramName = '';
  String strSelectedLineOfProgram = '0';

  late List<Map<String, dynamic>> standaloneSelection  = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    indicatorViewShow();
    getProgramList();
  }

  Future<void> getProgramList() async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(response.body);
        List<dynamic> programsJson = jsonResponse['data'];
        programList = [...programsJson.map((programJson) => ProgramList.fromJson(programJson)).toList()];

        ProgramList defaultProgram = ProgramList(
          programId: 0,
          serialNumber: 0,
          programName: 'Default',
          defaultProgramName: '',
          programType: '',
          priority: '',
          startDate: '',
          startTime: '',
          sequenceCount: 0,
          scheduleType: '',
          firstSequence: '',
          duration: '',
          programCategory: '',
        );

        bool programWithNameExists = false;
        for (ProgramList program in programList) {
          if (program.programName == 'Default') {
            programWithNameExists = true;
            break;
          }
        }

        if (!programWithNameExists) {
          programList.insert(0, defaultProgram);
        } else {
          print('Program with name \'Default\' already exists in widget.programList.');
        }
        getExitManualOperation();

      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> segmentSelectionCallbackFunction(segIndex, value, sldIrLine) async
  {
    if (value.contains(':')) {
      strDuration = value;
    } else {
      strFlow = value;
    }
    strSelectedLineOfProgram = sldIrLine;
    print('segIndex=$segIndex');
    setState(() {
      if(segIndex==0){
        standAloneMethod = 3;
      }else{
        standAloneMethod = segIndex;
      }
    });
  }

  Future<void> scheduleSectionCallbackMethod(programId, selection) async
  {
    ddCurrentPosition = selection;
    try {
      dashBoardData = await fetchControllerData(programId);
      indicatorViewHide();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getExitManualOperation() async
  {
    indicatorViewShow();
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID};
    final response = await HttpService().postRequest("getUserManualOperation", body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse['data'] != null){
        try{
          dynamic data = jsonResponse['data'];
          startFlag = data['startFlag'];
          programId = data['programId'].runtimeType==int?data['programId']:0;
          strProgramName = data['programName'];
          try {
            standAloneMethod = data['method'];
            if (standAloneMethod == 0){
              standAloneMethod = 3;
            }
          } catch (e) {
            print('Error: $e');
          }
          //print(programId);
          //print(widget.controllerID);
          strFlow = data['flow'];
          strDuration = data['time'];

          int position = findPositionByName(strProgramName, programList);
          if (position != -1) {
            ddCurrentPosition = position;
          }else {
            print("'$strProgramName' not found in the list.");
          }
          await Future.delayed(const Duration(milliseconds: 500));
          scheduleSectionCallbackMethod(programId, ddCurrentPosition);
        }catch(e){
          print(e);
        }
      } else {
        throw Exception('Invalid response format: "data" is null');
        indicatorViewHide();
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  int findPositionByName(String name, List<ProgramList> programList) {
    for (int i = 0; i < programList.length; i++) {
      if (programList[i].programName == name) {
        return i;
      }
    }
    return -1;
  }

  Future<List<DashboardDataProvider>>fetchControllerData(id) async
  {
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID, "programId": id};
    final response = await HttpService().postRequest("getCustomerDashboardByManual", body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      //print(response.body);
      if (jsonResponse['data'] != null) {
        dynamic data = jsonResponse['data'];
        if (data is Map<String, dynamic>) {
          return [DashboardDataProvider.fromJson(data)];
        } else {
          throw Exception('Invalid response format: "data" is not a Map');
        }
      } else {
        throw Exception('Invalid response format: "data" is null');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Row(
          children: [
            Text(screenWidth>600?widget.siteName:''),
            const Spacer(),
            const Text('Manual Operation'),
            const Spacer(),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () async {
            scheduleSectionCallbackMethod(programId, ddCurrentPosition);
          }),
          const SizedBox(width: 10),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            onPressed:() {
              standaloneSelection.clear();
              if(ddCurrentPosition==0){
                List<String> allRelaySrlNo = [];
                String strSldValveOrLineSrlNo = '';
                String strSldSourcePumpSrlNo ='',strSldIrrigationPumpSrlNo ='',strSldMainValveSrlNo ='',strSldCtrlFilterSrlNo ='',strSldLocFilterSrlNo =''
                ,strSldCrlFetFilterSrlNo ='',strSldLocFetFilterSrlNo ='', strSldAgitatorSrlNo ='', strSldFanSrlNo ='', strSldFoggerSrlNo =''
                , strSldBoosterPumpSrlNo ='', strSldSelectorSrlNo ='';

                if(dashBoardData[0].sourcePump.isNotEmpty){
                  strSldSourcePumpSrlNo = getSelectedRelaySrlNo(dashBoardData[0].sourcePump);
                }
                if(dashBoardData[0].irrigationPump.isNotEmpty){
                  strSldIrrigationPumpSrlNo = getSelectedRelaySrlNo(dashBoardData[0].irrigationPump);
                }
                if(dashBoardData[0].mainValve.isNotEmpty){
                  strSldMainValveSrlNo = getSelectedRelaySrlNo(dashBoardData[0].mainValve);
                }
                if(dashBoardData[0].centralFilterSite.isNotEmpty){
                  for(int i=0; i<dashBoardData[0].centralFilterSite.length; i++){
                    String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].centralFilterSite[i].filter);
                    if(concatenatedString.isNotEmpty){
                      strSldCtrlFilterSrlNo += '${concatenatedString}_';
                    }
                  }
                  if (strSldCtrlFilterSrlNo.isNotEmpty && strSldCtrlFilterSrlNo.endsWith('_')) {
                    strSldCtrlFilterSrlNo = strSldCtrlFilterSrlNo.replaceRange(strSldCtrlFilterSrlNo.length - 1, strSldCtrlFilterSrlNo.length, '');
                  }
                }
                if(dashBoardData[0].localFilterSite.isNotEmpty){
                  for(int i=0; i<dashBoardData[0].localFilterSite.length; i++){
                    String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].localFilterSite[i].filter);
                    if(concatenatedString.isNotEmpty){
                      strSldLocFilterSrlNo += '${concatenatedString}_';
                    }
                  }
                  if (strSldLocFilterSrlNo.isNotEmpty && strSldLocFilterSrlNo.endsWith('_')) {
                    strSldLocFilterSrlNo = strSldLocFilterSrlNo.replaceRange(strSldLocFilterSrlNo.length - 1, strSldLocFilterSrlNo.length, '');
                  }
                }
                if(dashBoardData[0].centralFertilizerSite.isNotEmpty){
                  for(int i=0; i<dashBoardData[0].centralFertilizerSite.length; i++){
                    String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].centralFertilizerSite[i].fertilizer);
                    if(concatenatedString.isNotEmpty){
                      strSldCrlFetFilterSrlNo += '${concatenatedString}_';
                    }
                  }
                  if (strSldCrlFetFilterSrlNo.isNotEmpty && strSldCrlFetFilterSrlNo.endsWith('_')) {
                    strSldCrlFetFilterSrlNo = strSldCrlFetFilterSrlNo.replaceRange(strSldCrlFetFilterSrlNo.length - 1, strSldCrlFetFilterSrlNo.length, '');
                  }
                }
                if(dashBoardData[0].localFertilizerSite.isNotEmpty){
                  for(int i=0; i<dashBoardData[0].localFertilizerSite.length; i++){
                    String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].localFertilizerSite[i].fertilizer);
                    if(concatenatedString.isNotEmpty){
                      strSldLocFetFilterSrlNo += '${concatenatedString}_';
                    }
                  }
                  if (strSldLocFetFilterSrlNo.isNotEmpty && strSldLocFetFilterSrlNo.endsWith('_')) {
                    strSldLocFetFilterSrlNo = strSldLocFetFilterSrlNo.replaceRange(strSldLocFetFilterSrlNo.length - 1, strSldLocFetFilterSrlNo.length, '');
                  }
                }
                if(dashBoardData[0].agitator.isNotEmpty){
                  strSldAgitatorSrlNo = getSelectedRelaySrlNo(dashBoardData[0].agitator);
                }
                if(dashBoardData[0].fan.isNotEmpty){
                  strSldFanSrlNo = getSelectedRelaySrlNo(dashBoardData[0].fan);
                }
                if(dashBoardData[0].fogger.isNotEmpty){
                  strSldFoggerSrlNo = getSelectedRelaySrlNo(dashBoardData[0].fogger);
                }
                if(dashBoardData[0].boosterPump.isNotEmpty){
                  strSldBoosterPumpSrlNo = getSelectedRelaySrlNo(dashBoardData[0].boosterPump);
                }
                if(dashBoardData[0].selector.isNotEmpty){
                  strSldSelectorSrlNo = getSelectedRelaySrlNo(dashBoardData[0].selector);
                }

                Map<String, List<DashBoardValve>> groupedValves = {};
                for (var line in dashBoardData[0].lineOrSequence) {
                  groupedValves = groupValvesByLocation(line.valves);
                  groupedValves.forEach((location, valves) {
                    for (int j = 0; j < valves.length; j++) {
                      if (valves[j].isOn) {
                        strSldValveOrLineSrlNo += '${valves[j].sNo}_';
                        standaloneSelection.add({
                          'id': valves[j].id,
                          'sNo': valves[j].sNo,
                          'name': valves[j].name,
                          'location': valves[j].location,
                          'selected': valves[j].isOn,
                        });
                      }
                    }
                  });
                }

                strSldValveOrLineSrlNo = strSldValveOrLineSrlNo.isNotEmpty ? strSldValveOrLineSrlNo.substring(0, strSldValveOrLineSrlNo.length - 1) : '';
                allRelaySrlNo = [
                  strSldSourcePumpSrlNo,
                  strSldIrrigationPumpSrlNo,
                  strSldMainValveSrlNo,
                  strSldCtrlFilterSrlNo,
                  strSldValveOrLineSrlNo,
                  strSldLocFilterSrlNo,
                  strSldCrlFetFilterSrlNo,
                  strSldLocFetFilterSrlNo,
                  strSldAgitatorSrlNo,
                  strSldFanSrlNo,
                  strSldFoggerSrlNo,
                  strSldBoosterPumpSrlNo,
                  strSldSelectorSrlNo,
                ];

                if (strSldIrrigationPumpSrlNo.isNotEmpty && strSldValveOrLineSrlNo.isEmpty) {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext dgContext) => AlertDialog(
                        title: const Text('StandAlone'),
                        content: const Text('Valve is not open! Are you sure! You want to Start the Selected Pump?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(dgContext, 'Cancel'),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              startByStandaloneDefault(allRelaySrlNo);
                              Navigator.pop(dgContext, 'OK');
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      )
                  );
                }else{
                  startByStandaloneDefault(allRelaySrlNo);
                }

              }
              else{
                Map<String, List<DashBoardValve>> groupedValves = {};
                String strSldSqnNo = '';
                //String strSldSqnLocation = '';

                String strSldIrrigationPumpId = '';
                if(dashBoardData[0].irrigationPump.isNotEmpty){
                  strSldIrrigationPumpId = getSelectedRelayId(dashBoardData[0].irrigationPump);
                }

                String strSldMainValveId = '';
                if(dashBoardData[0].mainValve.isNotEmpty){
                  strSldMainValveId = getSelectedRelayId(dashBoardData[0].mainValve);
                }

                String strSldCtrlFilterId = '';
                String sldCtrlFilterRelayOnOffStatus = '';
                if(dashBoardData[0].centralFilterSite.isNotEmpty){
                  for(int i=0; i<dashBoardData[0].centralFilterSite.length; i++){
                    String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].centralFilterSite[i].filter);
                    if(concatenatedString.isNotEmpty){
                      strSldCtrlFilterId += '${dashBoardData[0].centralFilterSite[i].id};';
                      sldCtrlFilterRelayOnOffStatus += '${getRelayOnOffStatus(dashBoardData[0].centralFilterSite[i].filter)};';
                    }
                  }
                  if (strSldCtrlFilterId.isNotEmpty && strSldCtrlFilterId.endsWith(';')) {
                    strSldCtrlFilterId = strSldCtrlFilterId.replaceRange(strSldCtrlFilterId.length - 1, strSldCtrlFilterId.length, '');
                  }
                  if (sldCtrlFilterRelayOnOffStatus.isNotEmpty && sldCtrlFilterRelayOnOffStatus.endsWith(';')) {
                    sldCtrlFilterRelayOnOffStatus = sldCtrlFilterRelayOnOffStatus.replaceRange(sldCtrlFilterRelayOnOffStatus.length - 1, sldCtrlFilterRelayOnOffStatus.length, '');
                  }
                }

                String strSldLocFilterId = '';
                String sldLocFilterRelayOnOffStatus = '';
                if(dashBoardData[0].localFilterSite.isNotEmpty){
                  for(int i=0; i<dashBoardData[0].localFilterSite.length; i++){
                    String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].localFilterSite[i].filter);
                    if(concatenatedString.isNotEmpty){
                      strSldLocFilterId += '${dashBoardData[0].localFilterSite[i].id};';
                      sldLocFilterRelayOnOffStatus += '${getRelayOnOffStatus(dashBoardData[0].localFilterSite[i].filter)};';
                    }
                  }
                  if (strSldLocFilterId.isNotEmpty && strSldLocFilterId.endsWith(';')) {
                    strSldLocFilterId = strSldLocFilterId.replaceRange(strSldLocFilterId.length - 1, strSldLocFilterId.length, '');
                  }
                  if (sldLocFilterRelayOnOffStatus.isNotEmpty && sldLocFilterRelayOnOffStatus.endsWith(';')) {
                    sldLocFilterRelayOnOffStatus = sldLocFilterRelayOnOffStatus.replaceRange(sldLocFilterRelayOnOffStatus.length - 1, sldLocFilterRelayOnOffStatus.length, '');
                  }
                }

                String  strSldFanId = '';
                if(dashBoardData[0].fan.isNotEmpty){
                  strSldFanId = getSelectedRelayId(dashBoardData[0].fan);
                }

                String  strSldFgrId = '';
                if(dashBoardData[0].fogger.isNotEmpty){
                  strSldFgrId = getSelectedRelayId(dashBoardData[0].fogger);
                }

                for (var lineOrSq in dashBoardData[0].lineOrSequence) {
                  if(lineOrSq.selected){
                    strSldSqnNo = lineOrSq.sNo;
                    standaloneSelection.add({
                      'id': lineOrSq.id,
                      'sNo': lineOrSq.sNo,
                      'name': lineOrSq.name,
                      'location': lineOrSq.location,
                      'selected': lineOrSq.selected,
                    });
                    break;
                  }
                }

                if (strSldSqnNo.isEmpty) {
                  displayAlert(context, 'You must select an zone.');
                }else if (strSldIrrigationPumpId.isEmpty) {
                  displayAlert(context, 'You must select an irrigation pump.');
                }else{
                  sendCommandToControllerAndMqttProgram(dashBoardData[0].headUnits,strSldSqnNo,strSldIrrigationPumpId,strSldMainValveId,strSldCtrlFilterId,
                      sldCtrlFilterRelayOnOffStatus,strSldLocFilterId,sldLocFilterRelayOnOffStatus,strSldFanId,strSldFgrId);
                }
              }
            },
            child: const Text('Start'),
          ),
          const SizedBox(width: 10),
          MaterialButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed:() async {
              if(programList[ddCurrentPosition].programName=='Default'){
                String payload = '0,0,0,0';
                String payLoadFinal = jsonEncode({
                  "800": [{"801": payload}]
                });
                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');
                sentManualModeToServer(programList[ddCurrentPosition].serialNumber, 0, standAloneMethod, '00:00:00', '0', []);
              }
              else{

                for (var lineOrSq in dashBoardData[0].lineOrSequence) {
                  if(lineOrSq.selected){
                    standaloneSelection.add({
                      'id': lineOrSq.id,
                      'sNo': lineOrSq.sNo,
                      'name': lineOrSq.name,
                      'location': lineOrSq.location,
                      'selected': lineOrSq.selected,
                    });
                    break;
                  }
                }

                String payLoadFinal = jsonEncode({
                  "3900": [{"3901": '0,${programList[ddCurrentPosition].programCategory},${programList[ddCurrentPosition].serialNumber},'
                      '${standaloneSelection.isNotEmpty?standaloneSelection[0]['sNo']:''},,,,,,,,,0,'}]
                });
                standaloneSelection.clear();

                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');
                sentManualModeToServer(programList[ddCurrentPosition].serialNumber, 0, standAloneMethod, '00:00:00', '0', []);

              }
            },
            child: const Text('Stop'),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: visibleLoading? Center(
        child: Visibility(
          visible: visibleLoading,
          child: Container(
            padding: EdgeInsets.fromLTRB(screenWidth/2 - 25, 0, screenWidth/2 - 25, 0),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ),
      ) :
      screenWidth>600?Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 380,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].sourcePump.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Source Pump'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].sourcePump.length * 65,
                                  child : ListView.builder(
                                    itemCount: dashBoardData[0].sourcePump.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].sourcePump[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].sourcePump[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/source_pump.png'),
                                            value: dashBoardData[0].sourcePump[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].sourcePump[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ):
                          Container(),

                        if (dashBoardData.isNotEmpty)
                          dashBoardData[0].irrigationPump.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Irrigation Pump'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].irrigationPump.length * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].irrigationPump.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].irrigationPump[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].irrigationPump[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/irrigation_pump.png'),
                                            value: dashBoardData[0].irrigationPump[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].irrigationPump[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),

                        if (dashBoardData.isNotEmpty)
                          dashBoardData[0].mainValve.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Main Valve'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].mainValve.length  * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].mainValve.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].mainValve[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].mainValve[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/dp_main_valve.png'),
                                            value: dashBoardData[0].mainValve[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].mainValve[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (dashBoardData.isNotEmpty)
                          dashBoardData[0].centralFilterSite.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Central Filter Site'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].centralFilterSite.length * 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: dashBoardData[0].centralFilterSite.length,
                                    itemBuilder: (context, index) {
                                      List<FilterList> fertilizers = dashBoardData[0].centralFilterSite[index].filter;
                                      return Card(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Image.asset('assets/images/central_filtration.png'),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(dashBoardData[0].centralFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text(dashBoardData[0].centralFilterSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text('Location : ${dashBoardData[0].centralFilterSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                    child: Text('filter', style: TextStyle(fontSize: 11),),
                                                  ),

                                                  SizedBox(
                                                      width: MediaQuery.sizeOf(context).width-740,
                                                      height: 46,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.only(left: 5, right: 5),
                                                            child: Divider(),
                                                          ),
                                                          SizedBox(
                                                            width: 310,
                                                            height: 30,
                                                            child: ListView.builder(
                                                              scrollDirection: Axis.horizontal,
                                                              itemCount: fertilizers.length,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: Column(
                                                                        children: [
                                                                          InkWell(
                                                                            child: CircleAvatar(
                                                                              radius: 15,
                                                                              backgroundColor: fertilizers[index].selected ? Colors.green : Colors.grey,
                                                                              child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                            ),
                                                                            onTap: (){
                                                                              setState(() {
                                                                                fertilizers[index].selected = !fertilizers[index].selected;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ):
                          Container(),

                        if (dashBoardData.isNotEmpty)
                          dashBoardData[0].localFilterSite.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Local Filter Site'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].localFilterSite.length * 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: dashBoardData[0].localFilterSite.length,
                                    itemBuilder: (context, index) {
                                      List<FilterList> fertilizers = dashBoardData[0].localFilterSite[index].filter;
                                      return Card(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Image.asset('assets/images/filter.png'),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(dashBoardData[0].localFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text(dashBoardData[0].localFilterSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text('Location : ${dashBoardData[0].localFilterSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                    child: Text('filter', style: TextStyle(fontSize: 11),),
                                                  ),

                                                  SizedBox(
                                                      width: MediaQuery.sizeOf(context).width-740,
                                                      height: 46,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.only(left: 5, right: 5),
                                                            child: Divider(),
                                                          ),
                                                          SizedBox(
                                                            width: 310,
                                                            height: 30,
                                                            child: ListView.builder(
                                                              scrollDirection: Axis.horizontal,
                                                              itemCount: fertilizers.length,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: Column(
                                                                        children: [
                                                                          InkWell(
                                                                            child: CircleAvatar(
                                                                              radius: 15,
                                                                              backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                              child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                            ),
                                                                            onTap: (){
                                                                              setState(() {
                                                                                fertilizers[index].selected = !fertilizers[index].selected;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ):
                          Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].centralFertilizerSite.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Central Fertilizer Site'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].centralFertilizerSite.length * 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: dashBoardData[0].centralFertilizerSite.length,
                                    itemBuilder: (context, index) {
                                      List<FertilizerChanel> fertilizers = dashBoardData[0].centralFertilizerSite[index].fertilizer;
                                      return Card(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Image.asset('assets/images/central_dosing.png'),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(dashBoardData[0].centralFertilizerSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text(dashBoardData[0].centralFertilizerSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text('Location : ${dashBoardData[0].centralFertilizerSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                    child: Text('Chanel', style: TextStyle(fontSize: 11),),
                                                  ),

                                                  SizedBox(
                                                      width: MediaQuery.sizeOf(context).width-740,
                                                      height: 46,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.only(left: 5, right: 5),
                                                            child: Divider(),
                                                          ),
                                                          SizedBox(
                                                            width: 310,
                                                            height: 30,
                                                            child: ListView.builder(
                                                              scrollDirection: Axis.horizontal,
                                                              itemCount: fertilizers.length,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: Column(
                                                                        children: [
                                                                          InkWell(
                                                                            child: CircleAvatar(
                                                                              radius: 15,
                                                                              backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                              child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                            ),
                                                                            onTap: (){
                                                                              setState(() {
                                                                                fertilizers[index].selected = !fertilizers[index].selected;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].localFertilizerSite.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Local Fertilizer Site'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].localFertilizerSite.length * 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: dashBoardData[0].localFertilizerSite.length,
                                    itemBuilder: (context, index) {
                                      List<FertilizerChanel> fertilizers = dashBoardData[0].localFertilizerSite[index].fertilizer;
                                      return Card(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8),
                                                      child: Image.asset('assets/images/central_dosing.png'),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(dashBoardData[0].localFertilizerSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text(dashBoardData[0].localFertilizerSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      Text('Location : ${dashBoardData[0].localFertilizerSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                    child: Text('Chanel', style: TextStyle(fontSize: 11),),
                                                  ),

                                                  SizedBox(
                                                      width: MediaQuery.sizeOf(context).width-740,
                                                      height: 46,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.only(left: 5, right: 5),
                                                            child: Divider(),
                                                          ),
                                                          SizedBox(
                                                            width: 310,
                                                            height: 30,
                                                            child: ListView.builder(
                                                              scrollDirection: Axis.horizontal,
                                                              itemCount: fertilizers.length,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: Column(
                                                                        children: [
                                                                          InkWell(
                                                                            child: CircleAvatar(
                                                                              radius: 15,
                                                                              backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                              child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                            ),
                                                                            onTap: (){
                                                                              setState(() {
                                                                                fertilizers[index].selected = !fertilizers[index].selected;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].agitator.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Agitator'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].agitator.length  * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].agitator.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].agitator[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].agitator[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/agitator.png'),
                                            value: dashBoardData[0].agitator[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].agitator[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].fan.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Fan'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].fan.length  * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].fan.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].fan[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].fan[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/fan.png'),
                                            value: dashBoardData[0].fan[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].fan[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].fogger.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Fogger'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].fogger.length  * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].fogger.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].fogger[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].fogger[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/fogger.png'),
                                            value: dashBoardData[0].fogger[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].fogger[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].boosterPump.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Booster Pump'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].boosterPump.length  * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].boosterPump.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].boosterPump[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].boosterPump[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/booster_pump.png'),
                                            value: dashBoardData[0].boosterPump[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].boosterPump[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),

                        if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                          dashBoardData[0].selector.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text('Selector'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].selector.length  * 65,
                                  child: ListView.builder(
                                    itemCount: dashBoardData[0].selector.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            title: Text(dashBoardData[0].selector[index].name),
                                            subtitle: Text('Location : ${dashBoardData[0].selector[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                            secondary: Image.asset('assets/images/selector.png'),
                                            value: dashBoardData[0].selector[index].selected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                dashBoardData[0].selector[index].selected = newValue!;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ): Container(),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 5),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : [], programList: programList, programSelectionCallback: scheduleSectionCallbackMethod, ddCurrentPosition: ddCurrentPosition, duration: dashBoardData[0].time, flow: dashBoardData[0].flow, segmentSelectionCallbackFunction: segmentSelectionCallbackFunction, method: dashBoardData[0].method,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ):
      Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.teal,
            tabs: const [
              Tab(text: 'Main line'),
              Tab(text: 'Line'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                        dashBoardData[0].sourcePump.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Source Pump'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].sourcePump.length * 65,
                                child : ListView.builder(
                                  itemCount: dashBoardData[0].sourcePump.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].sourcePump[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].sourcePump[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/source_pump.png'),
                                          value: dashBoardData[0].sourcePump[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].sourcePump[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ):
                        Container(),

                      if (dashBoardData.isNotEmpty)
                        dashBoardData[0].irrigationPump.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Irrigation Pump'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].irrigationPump.length * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].irrigationPump.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].irrigationPump[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].irrigationPump[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/irrigation_pump.png'),
                                          value: dashBoardData[0].irrigationPump[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].irrigationPump[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ):Container(),

                      if (dashBoardData.isNotEmpty)
                        dashBoardData[0].mainValve.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Main Valve'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].mainValve.length  * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].mainValve.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].mainValve[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].mainValve[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/dp_main_valve.png'),
                                          value: dashBoardData[0].mainValve[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].mainValve[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (dashBoardData.isNotEmpty)
                        dashBoardData[0].centralFilterSite.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Central Filter Site'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].centralFilterSite.length * 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: dashBoardData[0].centralFilterSite.length,
                                  itemBuilder: (context, index) {
                                    List<FilterList> fertilizers = dashBoardData[0].centralFilterSite[index].filter;
                                    return Card(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Image.asset('assets/images/central_filtration.png'),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(dashBoardData[0].centralFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text(dashBoardData[0].centralFilterSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text('Location : ${dashBoardData[0].centralFilterSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                  child: Text('filter', style: TextStyle(fontSize: 11),),
                                                ),

                                                SizedBox(
                                                    width: MediaQuery.sizeOf(context).width-740,
                                                    height: 46,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 5, right: 5),
                                                          child: Divider(),
                                                        ),
                                                        SizedBox(
                                                          width: 310,
                                                          height: 30,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: fertilizers.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 5),
                                                                    child: Column(
                                                                      children: [
                                                                        InkWell(
                                                                          child: CircleAvatar(
                                                                            radius: 15,
                                                                            backgroundColor: fertilizers[index].selected ? Colors.green : Colors.grey,
                                                                            child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                          ),
                                                                          onTap: (){
                                                                            setState(() {
                                                                              fertilizers[index].selected = !fertilizers[index].selected;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ):
                        Container(),

                      if (dashBoardData.isNotEmpty)
                        dashBoardData[0].localFilterSite.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Local Filter Site'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].localFilterSite.length * 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: dashBoardData[0].localFilterSite.length,
                                  itemBuilder: (context, index) {
                                    List<FilterList> fertilizers = dashBoardData[0].localFilterSite[index].filter;
                                    return Card(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Image.asset('assets/images/filter.png'),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(dashBoardData[0].localFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text(dashBoardData[0].localFilterSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text('Location : ${dashBoardData[0].localFilterSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                  child: Text('filter', style: TextStyle(fontSize: 11),),
                                                ),

                                                SizedBox(
                                                    width: MediaQuery.sizeOf(context).width-740,
                                                    height: 46,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 5, right: 5),
                                                          child: Divider(),
                                                        ),
                                                        SizedBox(
                                                          width: 310,
                                                          height: 30,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: fertilizers.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 5),
                                                                    child: Column(
                                                                      children: [
                                                                        InkWell(
                                                                          child: CircleAvatar(
                                                                            radius: 15,
                                                                            backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                            child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                          ),
                                                                          onTap: (){
                                                                            setState(() {
                                                                              fertilizers[index].selected = !fertilizers[index].selected;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ):
                        Container(),

                      if (dashBoardData.isNotEmpty)
                        dashBoardData[0].centralFertilizerSite.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Central Fertilizer Site'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].centralFertilizerSite.length * 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: dashBoardData[0].centralFertilizerSite.length,
                                  itemBuilder: (context, index) {
                                    List<FertilizerChanel> fertilizers = dashBoardData[0].centralFertilizerSite[index].fertilizer;
                                    return Card(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Image.asset('assets/images/central_dosing.png'),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(dashBoardData[0].centralFertilizerSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text(dashBoardData[0].centralFertilizerSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text('Location : ${dashBoardData[0].centralFertilizerSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                  child: Text('Chanel', style: TextStyle(fontSize: 11),),
                                                ),

                                                SizedBox(
                                                    width: MediaQuery.sizeOf(context).width-740,
                                                    height: 46,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 5, right: 5),
                                                          child: Divider(),
                                                        ),
                                                        SizedBox(
                                                          width: 310,
                                                          height: 30,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: fertilizers.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 5),
                                                                    child: Column(
                                                                      children: [
                                                                        InkWell(
                                                                          child: CircleAvatar(
                                                                            radius: 15,
                                                                            backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                            child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                          ),
                                                                          onTap: (){
                                                                            setState(() {
                                                                              fertilizers[index].selected = !fertilizers[index].selected;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (dashBoardData.isNotEmpty)
                        dashBoardData[0].localFertilizerSite.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Local Fertilizer Site'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].localFertilizerSite.length * 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: dashBoardData[0].localFertilizerSite.length,
                                  itemBuilder: (context, index) {
                                    List<FertilizerChanel> fertilizers = dashBoardData[0].localFertilizerSite[index].fertilizer;
                                    return Card(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Image.asset('assets/images/central_dosing.png'),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(dashBoardData[0].localFertilizerSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text(dashBoardData[0].localFertilizerSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                    Text('Location : ${dashBoardData[0].localFertilizerSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(right: 8, left: 5, top: 3),
                                                  child: Text('Chanel', style: TextStyle(fontSize: 11),),
                                                ),

                                                SizedBox(
                                                    width: MediaQuery.sizeOf(context).width-740,
                                                    height: 46,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 5, right: 5),
                                                          child: Divider(),
                                                        ),
                                                        SizedBox(
                                                          width: 310,
                                                          height: 30,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: fertilizers.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 5),
                                                                    child: Column(
                                                                      children: [
                                                                        InkWell(
                                                                          child: CircleAvatar(
                                                                            radius: 15,
                                                                            backgroundColor: fertilizers[index].selected? Colors.green : Colors.grey,
                                                                            child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
                                                                          ),
                                                                          onTap: (){
                                                                            setState(() {
                                                                              fertilizers[index].selected = !fertilizers[index].selected;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                        dashBoardData[0].agitator.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Agitator'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].agitator.length  * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].agitator.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].agitator[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].agitator[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/agitator.png'),
                                          value: dashBoardData[0].agitator[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].agitator[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                        dashBoardData[0].fan.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Fan'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].fan.length  * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].fan.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].fan[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].fan[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/fan.png'),
                                          value: dashBoardData[0].fan[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].fan[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                        dashBoardData[0].fogger.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Fogger'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].fogger.length  * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].fogger.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].fogger[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].fogger[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/fogger.png'),
                                          value: dashBoardData[0].fogger[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].fogger[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                        dashBoardData[0].boosterPump.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Booster Pump'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].boosterPump.length  * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].boosterPump.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].boosterPump[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].boosterPump[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/booster_pump.png'),
                                          value: dashBoardData[0].boosterPump[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].boosterPump[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),

                      if (ddCurrentPosition==0 && dashBoardData.isNotEmpty)
                        dashBoardData[0].selector.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text('Selector'),
                              ),
                              SizedBox(
                                height: dashBoardData[0].selector.length  * 65,
                                child: ListView.builder(
                                  itemCount: dashBoardData[0].selector.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(dashBoardData[0].selector[index].name),
                                          subtitle: Text('Location : ${dashBoardData[0].selector[index].location}',style: const TextStyle(fontWeight: FontWeight.normal),),
                                          secondary: Image.asset('assets/images/selector.png'),
                                          value: dashBoardData[0].selector[index].selected,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              dashBoardData[0].selector[index].selected = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ): Container(),
                    ],
                  ),
                ),
                DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : [], programList: programList, programSelectionCallback: scheduleSectionCallbackMethod, ddCurrentPosition: ddCurrentPosition, duration: dashBoardData[0].time, flow: dashBoardData[0].flow, segmentSelectionCallbackFunction: segmentSelectionCallbackFunction, method: dashBoardData[0].method,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void displayAlert(BuildContext context, String msg){
    showDialog<String>(
        context: context,
        builder: (BuildContext dgContext) => AlertDialog(
          title: const Text('Stand Alone'),
          content: Text(msg), // Removed '${}' around msg
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dgContext, 'OK');
              },
              child: const Text('Ok'),
            ),
          ],
        )
    );
  }

  void displaySnackBar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3), // Not const
      ),
    );
  }

  void startByStandaloneDefault(List<String> allRelaySrlNo){
    String finalResult = allRelaySrlNo.where((s) => s.isNotEmpty).join('_');
    String payload = '';
    String payLoadFinal = '';

    if(standAloneMethod==1 && strDuration=='00:00:00'){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Duration input'),
          duration: Duration(seconds: 3),
        ),
      );
    }else{
      payload = '${finalResult==''?0:1},${finalResult==''?0:finalResult},${standAloneMethod},${standAloneMethod==3?'0':standAloneMethod==1?strDuration:strFlow}';
      payLoadFinal = jsonEncode({
        "800": [{"801": payload}]
      });

      print(payLoadFinal);

      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');
      sentManualModeToServer(0, 1, standAloneMethod, strDuration, strFlow, standaloneSelection);
    }
  }

  Future<void> sendCommandToControllerAndMqttProgram(String strSldSqnLocation,String strSldSqnNo,String strSldIrrigationPumpId,String strSldMainValveId
      ,String strSldCtrlFilterId,String sldCtrlFilterRelayOnOffStatus,String strSldLocFilterId,String sldLocFilterRelayOnOffStatus,
      String strSldFanId,String strSldFgrId) async {

    String payload = '';
    String payLoadFinal = '';
    if(standAloneMethod==1 && strDuration=='00:00:00'){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Duration input'),
          duration: Duration(seconds: 3),
        ),
      );
    }else if(standAloneMethod==2 && (strFlow.isEmpty || strFlow=='0')){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Liter'),
          duration: Duration(seconds: 3),
        ),
      );
    }else{
      payload = '${1},$strSldSqnLocation,${programList[ddCurrentPosition].serialNumber},'
          '$strSldSqnNo,$strSldIrrigationPumpId,$strSldMainValveId,$strSldCtrlFilterId,'
          '$sldCtrlFilterRelayOnOffStatus,$strSldLocFilterId,$sldLocFilterRelayOnOffStatus,'
          '$strSldFanId,$strSldFgrId,$standAloneMethod,${standAloneMethod==3?'0':standAloneMethod==1?strDuration:strFlow};';

      payLoadFinal = jsonEncode({
        "3900": [{"3901": payload}]
      });

      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');
      sentManualModeToServer(programList[ddCurrentPosition].serialNumber, 1, standAloneMethod,strDuration, strFlow, standaloneSelection);
    }

  }

  Future<void>sentManualModeToServer(int sNo, int sFlag, int method, String dur, String flow, List<Map<String, dynamic>> selection) async {
    try {
      final body = {
        "userId": widget.customerID,
        "controllerId": widget.controllerID,
        "serialNumber": sNo,
        "startFlag": 0,
        "method": method,
        "duration": '00:00:00',
        "flow": '0',
        "selection": selection,
        "createUser": widget.customerID,
      };
      final response = await HttpService().postRequest("createUserManualOperation", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        standaloneSelection.clear();
        widget.callbackFunction(jsonResponse['message']);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Map<String, List<DashBoardValve>> groupValvesByLocation(List<DashBoardValve> valves) {
    Map<String, List<DashBoardValve>> groupedValves = {};
    for (var valve in valves) {
      if (!groupedValves.containsKey(valve.location)) {
        groupedValves[valve.location] = [];
      }
      groupedValves[valve.location]!.add(valve);
    }
    return groupedValves;
  }

  void indicatorViewShow() {
    setState(() {
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

  String getSelectedRelaySrlNo(itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].selected) {
        result += '${itemList[i].sNo}_';
        standaloneSelection.add({
          'id': itemList[i].id,
          'sNo': itemList[i].sNo,
          'name': itemList[i].name,
          'location': itemList[i].location,
          'selected': itemList[i].selected,
        });
      }
    }
    return result.isNotEmpty ? result.substring(0, result.length - 1) : '';
  }

  String getSelectedRelayId(itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].selected) {
        if (itemList[i].id.contains('MVL')) {
          result += '${itemList[i].hid}_';
        }else{
          result += '${itemList[i].id}_';
        }

        standaloneSelection.add({
          'id': itemList[i].id,
          'sNo': itemList[i].sNo,
          'name': itemList[i].name,
          'location': itemList[i].location,
          'selected': itemList[i].selected,
        });

      }
    }
    return result.isNotEmpty ? result.substring(0, result.length - 1) : '';
  }

  String getRelayOnOffStatus(itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].selected) {
        result += '1_';
      }else{
        result += '0_';
      }
    }
    return result.isNotEmpty ? result.substring(0, result.length - 1) : '';
  }


}

class DisplayLineOrSequence extends StatefulWidget {
  const DisplayLineOrSequence({super.key, required this.lineOrSequence, required this.programList, required this.programSelectionCallback, required this.ddCurrentPosition, required this.duration, required this.flow, required this.segmentSelectionCallbackFunction, required this.method});
  final List<LineOrSequence> lineOrSequence;
  final List<ProgramList> programList;
  final int ddCurrentPosition, method;
  final String duration, flow;
  final void Function(int, int) programSelectionCallback;
  final void Function(int, String, String) segmentSelectionCallbackFunction;

  @override
  State<DisplayLineOrSequence> createState() => _DisplayLineOrSequenceState();
}

class _DisplayLineOrSequenceState extends State<DisplayLineOrSequence> {

  SegmentWithFlow _segmentWithFlow = SegmentWithFlow.manual;
  String durationValue = '00:00:00';
  String selectedIrLine = '0';

  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  final TextEditingController _flowLiter = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(widget.method == 3){
      _segmentWithFlow = SegmentWithFlow.manual;
    }else if(widget.method == 1){
      _segmentWithFlow = SegmentWithFlow.duration;
    }else{
      _segmentWithFlow = SegmentWithFlow.flow;
    }

    int count = widget.duration.split(':').length - 1;
    if(count>1){
      durationValue = widget.duration;
    }else{
      durationValue = '${widget.duration}:00';
    }

    _flowLiter.text = widget.flow;

  }

  @override
  Widget build(BuildContext context)
  {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: screenWidth>600? 50: 90,
            child: screenWidth>600? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: widget.ddCurrentPosition!=0? SegmentedButton<SegmentWithFlow>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                      iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                    ),
                    segments: const <ButtonSegment<SegmentWithFlow>>[
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.manual,
                          label: Text('Manual'),
                          icon: Icon(Icons.pan_tool_alt_outlined)),
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.duration,
                          label: Text('Duration'),
                          icon: Icon(Icons.timer_outlined)),
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.flow,
                          label: Text('Flow-Liters'),
                          icon: Icon(Icons.water_drop_outlined)),
                    ],
                    selected: <SegmentWithFlow>{_segmentWithFlow},
                    onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                      setState(() {
                        _segmentWithFlow = newSelection.first;
                        widget.segmentSelectionCallbackFunction(_segmentWithFlow.index, durationValue, selectedIrLine);
                      });
                    },
                  ) :
                  SegmentedButton<SegmentWithFlow>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                      iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                    ),
                    segments: const <ButtonSegment<SegmentWithFlow>>[
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.manual,
                          label: Text('Manual'),
                          icon: Icon(Icons.pan_tool_alt_outlined)),
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.duration,
                          label: Text('Duration'),
                          icon: Icon(Icons.timer_outlined)),
                    ],
                    selected: <SegmentWithFlow>{_segmentWithFlow},
                    onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                      setState(() {
                        _segmentWithFlow = newSelection.first;
                        widget.segmentSelectionCallbackFunction(_segmentWithFlow.index, durationValue, selectedIrLine);
                      });
                    },
                  ),
                ),
                widget.programList.length>1 ? const SizedBox(
                  width: 110,
                  height: 50,
                  child: Center(child: Text('Schedule By')),
                ):
                Container(),
                widget.programList.length>1 ? SizedBox(
                  width: 220,
                  height: 50,
                  child: DropdownButtonFormField(
                    value: widget.programList.isNotEmpty ? widget.programList[widget.ddCurrentPosition] : null,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    ),
                    focusColor: Colors.transparent,
                    items: widget.programList.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.programName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      widget.programSelectionCallback(value!.programId, widget.programList.indexOf(value),);
                    },
                  ),
                ):
                Container(),
              ],
            ):
            Column(
              children: [
                const SizedBox(height: 5,),
                SizedBox(
                  width: screenWidth,
                  height: 35,
                  child: widget.ddCurrentPosition!=0? SegmentedButton<SegmentWithFlow>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                      iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                    ),
                    segments: const <ButtonSegment<SegmentWithFlow>>[
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.manual,
                          label: Text('Manual'),
                          icon: Icon(Icons.pan_tool_alt_outlined)),
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.duration,
                          label: Text('Duration'),
                          icon: Icon(Icons.timer_outlined)),
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.flow,
                          label: Text('Flow-Liters'),
                          icon: Icon(Icons.water_drop_outlined)),
                    ],
                    selected: <SegmentWithFlow>{_segmentWithFlow},
                    onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                      setState(() {
                        _segmentWithFlow = newSelection.first;
                        widget.segmentSelectionCallbackFunction(_segmentWithFlow.index, durationValue, selectedIrLine);
                      });
                    },
                  ) :
                  SegmentedButton<SegmentWithFlow>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                      iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                    ),
                    segments: const <ButtonSegment<SegmentWithFlow>>[
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.manual,
                          label: Text('Manual'),
                          icon: Icon(Icons.pan_tool_alt_outlined)),
                      ButtonSegment<SegmentWithFlow>(
                          value: SegmentWithFlow.duration,
                          label: Text('Duration'),
                          icon: Icon(Icons.timer_outlined)),
                    ],
                    selected: <SegmentWithFlow>{_segmentWithFlow},
                    onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                      setState(() {
                        _segmentWithFlow = newSelection.first;
                        widget.segmentSelectionCallbackFunction(_segmentWithFlow.index, durationValue, selectedIrLine);
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.programList.length>1 ? const SizedBox(
                      width: 110,
                      height: 50,
                      child: Center(child: Text('Schedule By')),
                    ):
                    Container(),
                    widget.programList.length>1 ? SizedBox(
                      width: 220,
                      height: 50,
                      child: DropdownButtonFormField(
                        value: widget.programList.isNotEmpty ? widget.programList[widget.ddCurrentPosition] : null,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        ),
                        focusColor: Colors.transparent,
                        items: widget.programList.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.programName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          widget.programSelectionCallback(value!.programId, widget.programList.indexOf(value),);
                        },
                      ),
                    ):
                    Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
        _segmentWithFlow.index == 1 ? SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: const Text('Set Duration(HH:MM:SS)'),
            trailing: SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _showDurationInputDialog(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(myTheme.primaryColor.withOpacity(0.2)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    child: Text(durationValue, style: const TextStyle(color: Colors.black, fontSize: 17)),
                  ),
                ],
              ),
            ),
          ),
        ) :
        Container(),
        _segmentWithFlow.index == 2 ? SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: const Text('Set Flow(Liters)'),
            trailing: SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      width: 100,
                      child: TextField(
                        maxLength: 7,
                        controller: _flowLiter,
                        onChanged: (value) {
                          setState(() {
                            widget.segmentSelectionCallbackFunction(_segmentWithFlow.index, value, selectedIrLine);
                          });
                        },
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Liters',
                          counterText: '',
                        ),
                      ),
                  )
                ],
              ),
            ),
          ),
        ):
        Container(),
        Expanded(
          child: ListView.builder(
            itemCount: widget.lineOrSequence.length,
            itemBuilder: (context, index) {
              LineOrSequence line = widget.lineOrSequence[index];
              Map<String, List<DashBoardValve>> groupedValves = groupValvesByLocation(line.valves);
              return Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0), // Adjust the value as needed
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: screenWidth>600? MediaQuery.of(context).size.width-400: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: myTheme.primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 10),
                                child: Text(line.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                              ),
                            ),

                            if (widget.ddCurrentPosition!=0)
                              VerticalDivider(color: myTheme.primaryColor.withOpacity(0.1)),

                            if(widget.ddCurrentPosition!=0)
                              Center(
                                child: SizedBox(
                                  width: 60,
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: line.selected,
                                      onChanged: (value) {
                                        setState(() {
                                          for (var line in widget.lineOrSequence) {
                                            line.selected = false;
                                          }
                                          line.selected = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      for (var valveLocation in groupedValves.keys)
                        SizedBox(
                          height: (groupedValves[valveLocation]!.length * 40)+40,
                          width: screenWidth>600?MediaQuery.sizeOf(context).width-380:MediaQuery.sizeOf(context).width,
                          child: widget.ddCurrentPosition==0? DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                            columns: const [
                              DataColumn2(
                                  label: Center(child: Text('', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 30
                              ),
                              DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
                              ),
                              DataColumn2(
                                  label: Center(child: Text('Rf.No', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                  label: Center(child: Text('Valve Id', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                  label: Center(
                                    child: Text(
                                      'Name',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(
                                  child: Text(
                                    'Valve Status',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                fixedWidth: 100,
                              ),
                            ],
                            rows: List<DataRow>.generate(groupedValves[valveLocation]!.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Image.asset('assets/images/valve_gray.png',width: 25, height: 25,))),
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text('${groupedValves[valveLocation]![index].sNo}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Transform.scale(
                                scale: 0.7,
                                child: Tooltip(
                                  message: groupedValves[valveLocation]![index].isOn? 'Close' : 'Open',
                                  child: Switch(
                                    hoverColor: Colors.pink.shade100,
                                    value: groupedValves[valveLocation]![index].isOn,
                                    onChanged: (value) {
                                      setState(() {
                                        groupedValves[valveLocation]![index].isOn = value;
                                      });
                                    },
                                  ),
                                ),
                              ))),
                            ])),
                          ) :
                          DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                            columns: const [
                              DataColumn2(
                                  label: Center(child: Text('', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 30
                              ),
                              DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
                              ),
                              DataColumn2(
                                  label: Center(child: Text('Rf.No', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                  label: Center(child: Text('Valve Id', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(child: Text('Location', style: TextStyle(fontSize: 14),)),
                                fixedWidth: 100,
                              ),
                              DataColumn2(
                                  label: Center(
                                    child: Text(
                                      'Name',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  size: ColumnSize.M
                              ),
                            ],
                            rows: List<DataRow>.generate(groupedValves[valveLocation]!.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Image.asset('assets/images/valve_gray.png',width: 25, height: 25,))),
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text('${groupedValves[valveLocation]![index].sNo}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].location, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: TextStyle(fontWeight: FontWeight.normal)))),
                            ])),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDurationInputDialog(BuildContext context) {

    List<String> timeParts = durationValue.split(':');
    _hoursController.text = timeParts[0];
    _minutesController.text = timeParts[1];
    _secondsController.text = timeParts[2];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Duration'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                  decoration: const InputDecoration(
                    labelText: 'Seconds',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateTime(_hoursController.text, 'hours') &&
                    _validateTime(_minutesController.text, 'minutes') &&
                    _validateTime(_secondsController.text, 'seconds')) {
                  setState(() {
                    durationValue = '${_hoursController.text}:${_minutesController.text}:${_secondsController.text}';
                  });
                  widget.segmentSelectionCallbackFunction(_segmentWithFlow.index, durationValue , selectedIrLine);
                  Navigator.of(context).pop();
                }
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid time formed'),
                        content: const Text('Please fill correct time format and try again.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _validateTime(String value, String fieldType) {
    if (value.isEmpty) {
      return false;
    }
    int intValue = int.tryParse(value) ?? -1;
    if (intValue < 0) {
      return false;
    }
    switch (fieldType) {
      case 'hours':
        return intValue >= 0 && intValue <= 23;
      case 'minutes':
      case 'seconds':
        return intValue >= 0 && intValue <= 59;
      default:
        return false;
    }
  }


  Map<String, List<DashBoardValve>> groupValvesByLocation(List<DashBoardValve> valves) {
    Map<String, List<DashBoardValve>> groupedValves = {};
    for (var valve in valves) {
      if (!groupedValves.containsKey(valve.location)) {
        groupedValves[valve.location] = [];
      }
      groupedValves[valve.location]!.add(valve);
    }
    return groupedValves;
  }

}
