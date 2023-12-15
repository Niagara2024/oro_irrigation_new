import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/Models/Customer/Dashboard/DashboardDataProvider.dart';
import '../../../Models/Customer/Dashboard/DashBoardValve.dart';
import '../../../Models/Customer/Dashboard/LineOrSequence.dart';
import '../../../Models/Customer/Dashboard/ProgramList.dart';
import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import 'DisplayCentralFertilizerSite.dart';
import 'DisplayCentralFilterSite.dart';
import 'DisplayIrrigationPump.dart';
import 'DisplayMainValve.dart';
import 'DisplaySourcePump.dart';

enum Calendar {manual, duration, flow}

class DashboardByManual extends StatefulWidget {
  const DashboardByManual({Key? key, required this.customerID, required this.siteID, required this.controllerID, required this.siteName, required this.imeiNo, required this.programList}) : super(key: key);
  final int customerID, siteID, controllerID;
  final String siteName, imeiNo;
  final List<ProgramList> programList;

  @override
  State<DashboardByManual> createState() => _DashboardByManualState();
}

class _DashboardByManualState extends State<DashboardByManual> {

  late List<DashboardDataProvider> dashBoardData = [];
  bool visibleLoading = false;
  int ddSelection = 0;

  @override
  void initState() {
    super.initState();

    ProgramList defaultProgram = ProgramList(
      programId: 0,
      serialNumber: 0,
      programName: 'Default',
      defaultProgramName: '',
      programType: '',
      priority: 0,
      startDate: '',
      startTime: '',
      sequenceCount: 0,
      scheduleType: '',
      firstSequence: '',
      duration: '',
    );
    widget.programList.insert(0, defaultProgram);
    getControllerDashboardDetails(0, 0);
  }

  Future<void> getControllerDashboardDetails(id, selection) async
  {
    ddSelection = selection;
    indicatorViewShow();
    try {
      dashBoardData = await fetchControllerData(id);
      setState(() {
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<DashboardDataProvider>> fetchControllerData(id) async
  {
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID, "programId": id};
    final response = await HttpService().postRequest("getCustomerDashboardByManual", body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      //print(jsonResponse);
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
            getControllerDashboardDetails(0, ddSelection);
          }),
          const SizedBox(width: 10,),
          IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings_outlined), onPressed: () async
          {
          }),
          const SizedBox(width: 20,),
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
            child: Row(
              children: [
                SizedBox(
                  width: 350,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Source Pump'),
                            ),
                          SizedBox(
                            height: (dashBoardData[0].sourcePump.length % 5 == 0
                                ? dashBoardData[0].sourcePump.length ~/ 5 * 70
                                : (dashBoardData[0].sourcePump.length ~/ 5 + 1) * 70),
                            child: DisplaySourcePump(sourcePump: dashBoardData[0].sourcePump,),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Irrigation Pump'),
                            ),// Add this condition
                          SizedBox(
                            height: (dashBoardData[0].irrigationPump.length % 5 == 0
                                ? dashBoardData[0].irrigationPump.length ~/ 5 * 70
                                : (dashBoardData[0].irrigationPump.length ~/ 5 + 1) * 70),
                            child: DisplayIrrigationPump(irrigationPump: dashBoardData[0].irrigationPump,),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Main Valve'),
                            ),// Add this condition
                          SizedBox(
                            height: (dashBoardData[0].mainValve.length % 5 == 0
                                ? dashBoardData[0].mainValve.length ~/ 5 * 70
                                : (dashBoardData[0].mainValve.length ~/ 5 + 1) * 70),
                            child: DisplayMainValve(mainValve: dashBoardData[0].mainValve,),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Central Filter Site'),
                            ),
                          SizedBox(
                            height: (dashBoardData[0].centralFilterSite.length % 5 == 0
                                ? dashBoardData[0].centralFilterSite.length ~/ 5 * 70
                                : (dashBoardData[0].centralFilterSite.length ~/ 5 + 1) * 70),
                            child: DisplayCentralFilterSite(centralFilterSite: dashBoardData[0].centralFilterSite,),
                          ),
                          const Divider(height: 0),
                          if (dashBoardData.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Central Fertilizer Site'),
                            ),
                          SizedBox(
                            height: dashBoardData[0].centralFertilizerSite.length * 170,
                            child: DisplayCentralFertilizerSite(centralFertilizationSite: dashBoardData[0].centralFertilizerSite,),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 5),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : [], programList: widget.programList, callback: getControllerDashboardDetails, ddSelectedVal: ddSelection,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: myTheme.primaryColor.withOpacity(0.1),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              IconButton(
                  tooltip: 'list view',
                  onPressed: () {
                    debugPrint("Like button pressed");
                  },
                  icon: const Icon(
                    Icons.list_alt,
                    size: 30,
                    color: Colors.black,
                  )),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  tooltip: 'mapview',
                  onPressed: () {
                    debugPrint("Dislike button pressed");
                  },
                  icon:  const Icon(
                    Icons.map_outlined,
                    size: 30,
                    color: Colors.black,
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        tooltip: 'skip previous',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon: const Icon(
                          Icons.skip_previous_outlined,
                          size: 30,
                          color: Colors.black,
                        )),
                    IconButton(
                        tooltip: 'run',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon: const Icon(
                          Icons.play_circle_outline,
                          size: 30,
                          color: Colors.black,
                        )),
                    IconButton(
                        tooltip: 'skip next',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon: const Icon(
                          Icons.skip_next_outlined,
                          size: 30,
                          color: Colors.black,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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

}


class DisplayLineOrSequence extends StatefulWidget {
  const DisplayLineOrSequence({super.key, required this.lineOrSequence, required this.programList, required this.callback, required this.ddSelectedVal});
  final List<LineOrSequence> lineOrSequence;
  final List<ProgramList> programList;
  final void Function(int, int) callback;
  final int ddSelectedVal;

  @override
  State<DisplayLineOrSequence> createState() => _DisplayLineOrSequenceState();
}

class _DisplayLineOrSequenceState extends State<DisplayLineOrSequence> {
  Calendar calendarView = Calendar.manual;
  String selectedValue = 'Single';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        const SizedBox(height: 10,),
        SizedBox(
          width: MediaQuery.of(context).size.width - 400,
          height: 50,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SegmentedButton<Calendar>(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
                    iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                  ),
                  segments: const <ButtonSegment<Calendar>>[
                    ButtonSegment<Calendar>(
                        value: Calendar.manual,
                        label: Text('Manual base'),
                        icon: Icon(Icons.edit_note)),
                    ButtonSegment<Calendar>(
                        value: Calendar.duration,
                        label: Text('Duration base'),
                        icon: Icon(Icons.timer_outlined)),
                    ButtonSegment<Calendar>(
                        value: Calendar.flow,
                        label: Text('Flow base'),
                        icon: Icon(Icons.gas_meter_outlined)),
                  ],
                  selected: <Calendar>{calendarView},
                  onSelectionChanged: (Set<Calendar> newSelection) {
                    setState(() {
                      calendarView = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 130,
                height: 50,
                child: Center(child: Text('Schedule By')),
              ),
              SizedBox(
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
                    // Handle the selected item
                    print("Selected: ${value?.programName}");
                    widget.callback(value!.programId, widget.programList.indexOf(value));
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          child:
          ListView.builder(
            itemCount: widget.lineOrSequence.length,
            itemBuilder: (context, index) {
              LineOrSequence line = widget.lineOrSequence[index];
              Map<String, List<DashBoardValve>> groupedValves = groupValvesByLocation(line.valves);
              _textController.text = line.flow;

              return Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
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
                            if (calendarView.index == 1) ...[
                              VerticalDivider(color: myTheme.primaryColor.withOpacity(0.1)),
                            ],
                            if (calendarView.index == 1) ...[
                              SizedBox(
                                width: 200,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Duration(HH:MM) :'),
                                      const SizedBox(width: 5,),
                                      InkWell(
                                        onTap: () => _selectTimeDuration(context, TimeOfDay(hour: int.parse(line.time.split(":")[0]), minute: int.parse(line.time.split(":")[1])), line),
                                        child: Text(line.time,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            if (calendarView.index == 2) ...[
                              VerticalDivider(color: myTheme.primaryColor.withOpacity(0.1)),
                            ],
                            if (calendarView.index == 2) ...[
                              SizedBox(
                                width: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: TextField(
                                          controller: _textController,
                                          decoration: const InputDecoration(
                                            hintText: 'Liter',
                                          ),
                                        ),
                                      ),
                                      const Text('/'),
                                      const Text('Lit', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      for (var valveLocation in groupedValves.keys)
                        SizedBox(
                          height: (groupedValves[valveLocation]!.length * 40)+40,
                          width: MediaQuery.sizeOf(context).width-380,
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                            columns: [
                              const DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontSize: 14),)),
                                  fixedWidth: 50
                              ),
                              const DataColumn2(
                                  label: Center(child: Text('Valve Id', style: TextStyle(fontSize: 14),)),
                                  size: ColumnSize.M
                              ),
                              const DataColumn2(
                                label: Center(child: Text('Location', style: TextStyle(fontSize: 14),)),
                                fixedWidth: 100,
                              ),
                              const DataColumn2(
                                  label: Center(
                                    child: Text(
                                      'Valve Name',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(
                                  child: Text(
                                    'On/Off Status',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                fixedWidth: 120,
                              ),
                            ],
                            rows: List<DataRow>.generate(groupedValves[valveLocation]!.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].location, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Center(child: Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: groupedValves[valveLocation]![index].isOn,
                                      onChanged: (value) {
                                        setState(() {
                                          groupedValves[valveLocation]![index].isOn = value;
                                        });
                                      },
                                    ),
                                  ))),
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

  Future<void> _selectTimeDuration(BuildContext context, TimeOfDay time, LineOrSequence lineOrSequence) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
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
        lineOrSequence.time = '$hour:$minute';
      });

    }
  }
}

