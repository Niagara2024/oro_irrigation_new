import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../Models/Customer/Dashboard/DashBoardValve.dart';
import '../../../Models/Customer/Dashboard/DashboardDataProvider.dart';
import '../../../Models/Customer/Dashboard/LineOrSequence.dart';
import '../../../Models/Customer/Dashboard/ProgramList.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';

enum ManualBaseSegment {manual, duration}

class RunByManual extends StatefulWidget {
  const RunByManual({Key? key, required this.customerID, required this.siteID, required this.controllerID, required this.siteName, required this.imeiNo, required this.programList, required this.callbackFunction}) : super(key: key);
  final int customerID, siteID, controllerID;
  final String siteName, imeiNo;
  final List<ProgramList> programList;
  final void Function(String msg) callbackFunction;

  @override
  State<RunByManual> createState() => _RunByManualState();
}

class _RunByManualState extends State<RunByManual> {

  late List<DashboardDataProvider> dashBoardData = [];
  bool visibleLoading = false;
  int ddSelection = 0;
  int ddSelectionId = 0;
  int segmentIndex = 0;
  String strFlow = '0';
  String strDuration = '00:00';
  String strSelectedLineOfProgram = '0';

  late List<Map<String,dynamic>> standaloneSelection  = [];

  @override
  void initState() {
    super.initState();
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
    );

    bool programWithNameExists = false;
    for (ProgramList program in widget.programList) {
      if (program.programName == 'Default') {
        programWithNameExists = true;
        break;
      }
    }

    if (!programWithNameExists) {
      widget.programList.insert(0, defaultProgram);
    } else {
      print('Program with name \'Default\' already exists in widget.programList.');
    }
    getControllerDashboardDetails(ddSelectionId, ddSelection);
  }

  Future<void> payloadCallbackFunction(segIndex, value, sldIrLine) async
  {
    segmentIndex = segIndex;
    if (value.contains(':')) {
      strDuration = value;
    } else {
      strFlow = value;
    }
    strSelectedLineOfProgram = sldIrLine;
  }

  Future<void> getControllerDashboardDetails(programId, selection) async
  {
    print(programId);
    ddSelection = selection;
    indicatorViewShow();
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      dashBoardData = await fetchControllerData(programId);
      setState(() {
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<DashboardDataProvider>>fetchControllerData(id) async
  {
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID, "programId": id};
    print(body);
    final response = await HttpService().postRequest("getCustomerDashboardByManual", body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(response.body);
      indicatorViewHide();
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
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Text(widget.siteName),
        actions: [
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () async {
            getControllerDashboardDetails(ddSelectionId, ddSelection);
          }),
          IconButton(
              tooltip: 'Start',
              onPressed: () {
                standaloneSelection.clear();
                String strSldSourcePump = buildSelectedItemsString(dashBoardData[0].sourcePump);
                String strSldIrrigationPump = buildSelectedItemsString(dashBoardData[0].irrigationPump);
                String strSldMainValve = buildSelectedItemsString(dashBoardData[0].mainValve);
                String strSldCtrlFilter = buildSelectedItemsString(dashBoardData[0].centralFilterSite);

                String strSldValveOrLine = '';
                Map<String, List<DashBoardValve>> groupedValves = {};
                for (int i = 0; i < dashBoardData[0].lineOrSequence.length; i++) {
                  LineOrSequence line = dashBoardData[0].lineOrSequence[i];
                  if(ddSelection==0){
                    groupedValves = groupValvesByLocation(line.valves);
                    groupedValves.forEach((location, valves) {
                      for (int j = 0; j < valves.length; j++) {
                        if (valves[j].isOn) {
                          strSldValveOrLine += '${valves[j].sNo}_';

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
                  }else{
                    if (line.selected) {
                      strSldValveOrLine += '${line.id}_';

                      standaloneSelection.add({
                        'id': line.id,
                        'sNo': line.sNo,
                        'name': line.name,
                        'location': line.location,
                        'selected': line.selected,
                      });
                    }
                  }

                }

                strSldValveOrLine = strSldValveOrLine.isNotEmpty ? strSldValveOrLine.substring(0, strSldValveOrLine.length - 1) : '';
                List<String> nonEmptyStrings = [
                  strSldSourcePump,
                  strSldIrrigationPump,
                  strSldMainValve,
                  strSldCtrlFilter,
                  strSldValveOrLine
                ];

                if (strSldIrrigationPump.isNotEmpty && strSldValveOrLine.isEmpty) {
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
                              sendCommandToControllerAndMqtt(nonEmptyStrings);
                              Navigator.pop(dgContext, 'OK');
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      )
                  );
                }else{
                  sendCommandToControllerAndMqtt(nonEmptyStrings);
                }
              },
              icon: const Icon(
                Icons.not_started_outlined,
              )),
          const SizedBox(width: 10,),
        ],
      ),
      body: visibleLoading? Center(
        child: Visibility(
          visible: visibleLoading,
          child: Container(
            padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 25, 0, mediaQuery.size.width/2 - 25, 0),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ),
      ) :
      Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : [], programList: widget.programList, programSelectionCallback: getControllerDashboardDetails, ddSelectedVal: ddSelection, duration: dashBoardData[0].time, flow: dashBoardData[0].flow, callbackFunctionForPayload: payloadCallbackFunction, method: dashBoardData[0].method,),
            ),
          ),
        ],
      ),
    );
  }

  void sendCommandToControllerAndMqtt(List<String> nonEmptyStrings){
    String finalResult = nonEmptyStrings.where((s) => s.isNotEmpty).join('_');

    // 1st position on off = always = 1
    // 2nd position valve based / program based = always = 1/2
    // 3rd position Program Category = 0 valve based = program based its come IL1
    String payload = '${1},${ddSelection+1},${ddSelection==0? 0:finalResult},$finalResult,${0},${segmentIndex==0?3:1},${segmentIndex==0? '0': segmentIndex==1? strDuration : strFlow}';
    String payLoadFinal = jsonEncode({
      "800": [{"801": payload}]
    });
    //print(payLoadFinal);
    //MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');

    if(segmentIndex==0){
      //functionSendPayloadToMqtt(3, '0', finalResult);
    }else{
      //functionSendPayloadToMqtt(1, '$strDuration:00', finalResult);
    }
    Map<String, dynamic> manualOperation = {
      "method": segmentIndex+1,
      "time": strDuration,
      "flow": strFlow,
      "selected": standaloneSelection,
    };
    sentManualModeToServer(manualOperation);
  }

  Future<void>sentManualModeToServer(manualOperation) async {
    try {
      final body = {"userId": widget.customerID, "controllerId": widget.controllerID, "manualOperation": manualOperation, "createUser": widget.customerID};
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

  String buildSelectedItemsString(itemList) {
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

  void functionSendPayloadToMqtt(sgmType, val, relayList) {
    String payload = '${relayList.isEmpty ? 0:1},${ddSelection==0?1:2},${1},${0},${relayList.isNotEmpty ? relayList:0},${0},$sgmType,$val';
    String payLoadFinal = jsonEncode({
      "800": [{"801": payload}]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.imeiNo}');
  }
}

class DisplayLineOrSequence extends StatefulWidget {
  const DisplayLineOrSequence({super.key, required this.lineOrSequence, required this.programList, required this.programSelectionCallback, required this.ddSelectedVal, required this.duration, required this.flow, required this.callbackFunctionForPayload, required this.method});
  final List<LineOrSequence> lineOrSequence;
  final List<ProgramList> programList;
  final int ddSelectedVal, method;
  final String duration, flow;
  final void Function(int, int) programSelectionCallback;
  final void Function(int, String, String) callbackFunctionForPayload;

  @override
  State<DisplayLineOrSequence> createState() => _DisplayLineOrSequenceState();
}

class _DisplayLineOrSequenceState extends State<DisplayLineOrSequence> {

  ManualBaseSegment segmentViewManual = ManualBaseSegment.manual;
  String durationValue = '00:00';
  String selectedIrLine = '0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // String jsonString = jsonEncode(widget.lineOrSequenc);

    if(widget.method == 1){
      segmentViewManual = ManualBaseSegment.manual;
    }else{
      segmentViewManual = ManualBaseSegment.duration;
    }
    durationValue = widget.duration;
  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SegmentedButton<ManualBaseSegment>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                      iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                    ),
                    segments: const <ButtonSegment<ManualBaseSegment>>[
                      ButtonSegment<ManualBaseSegment>(
                          value: ManualBaseSegment.manual,
                          label: Text('Manual'),
                          icon: Icon(Icons.pan_tool_alt_outlined)),
                      ButtonSegment<ManualBaseSegment>(
                          value: ManualBaseSegment.duration,
                          label: Text('Duration'),
                          icon: Icon(Icons.timer_outlined)),
                    ],
                    selected: <ManualBaseSegment>{segmentViewManual},
                    onSelectionChanged: (Set<ManualBaseSegment> newSelection) {
                      setState(() {
                        segmentViewManual = newSelection.first;
                        widget.callbackFunctionForPayload(segmentViewManual.index, durationValue, selectedIrLine);
                      });
                    },
                  ),
                ),
                widget.programList.length>1 ? const SizedBox(
                  width: 130,
                  height: 50,
                  child: Center(child: Text('Schedule By')),
                ):
                Container(),
                widget.programList.length>1 ? SizedBox(
                  width: 200,
                  height: 50,
                  child: DropdownButtonFormField(
                    value: widget.programList.isNotEmpty ? widget.programList[widget.ddSelectedVal] : null,
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
          ),
        ),
        segmentViewManual.index == 1? SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: const Text('Set Duration(HH:MM)'),
            trailing: InkWell(
              onTap: () => _selectTimeDuration(context, TimeOfDay(hour: int.parse(durationValue.split(":")[0]), minute: int.parse(durationValue.split(":")[1]))),
              child: Text(durationValue, style: const TextStyle(fontSize: 15),),
            ),
          ),
        ) :
        Container(),
        Expanded(
          child:
          ListView.builder(
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
                        width: MediaQuery.of(context).size.width-380,
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

                            if (widget.ddSelectedVal!=0)
                              VerticalDivider(color: myTheme.primaryColor.withOpacity(0.1)),

                            if(widget.ddSelectedVal!=0)
                              Center(
                                child: SizedBox(
                                  width: 60,
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: line.selected,
                                      onChanged: (value) {
                                        setState(() {
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
                          width: MediaQuery.sizeOf(context).width-380,
                          child: widget.ddSelectedVal==0? DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                            columns: const [
                              DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
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
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].location, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: TextStyle(fontWeight: FontWeight.normal)))),
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
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
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
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
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


  Future<void> _selectTimeDuration(BuildContext context, TimeOfDay time) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
      helpText: 'Set Duration(HH:MM)',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      //print('Selected time: $selectedTime');
      String hour = selectedTime.hour.toString().padLeft(2, '0');
      String minute = selectedTime.minute.toString().padLeft(2, '0');
      setState(() {
        durationValue = '$hour:$minute';
        widget.callbackFunctionForPayload(segmentViewManual.index, durationValue , selectedIrLine);
      });

    }
  }
}
