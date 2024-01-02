import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import '../../../Models/Customer/Dashboard/DashBoardValve.dart';
import '../../../Models/Customer/Dashboard/DashboardDataProvider.dart';
import '../../../Models/Customer/Dashboard/LineOrSequence.dart';
import '../../../constants/http_service.dart';
import 'DisplayCentralFertilizerSite.dart';
import 'DisplayCentralFilterSite.dart';
import 'DisplayIrrigationPump.dart';
import 'DisplayMainValve.dart';
import 'DisplaySourcePump.dart';


class DashboardByProgram extends StatefulWidget {
  const DashboardByProgram({Key? key, required this.customerID, required this.siteID, required this.siteName, required this.controllerID, required this.imeiNo, required this.programId}) : super(key: key);
  final int customerID, siteID, controllerID, programId;
  final String siteName, imeiNo;

  @override
  State<DashboardByProgram> createState() => _DashboardByProgramState();
}

class _DashboardByProgramState extends State<DashboardByProgram>
{
  late List<DashboardDataProvider> dashBoardData = [];
  bool visibleLoading = false;

  @override
  void initState() {
    super.initState();
    getControllerDashboardDetails(widget.programId);
  }

  Future<void> getControllerDashboardDetails(int id) async
  {
    indicatorViewShow();
    try {
      dashBoardData = await fetchControllerData(id);
      setState(() {
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<DashboardDataProvider>> fetchControllerData(int id) async
  {
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID, "programId": id};
    final response = await HttpService().postRequest("getCustomerDashboardByProgram", body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      indicatorViewHide();
      print(jsonResponse);
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
  Widget build(BuildContext context)
  {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Text(widget.siteName),
        actions: [
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () async {
            getControllerDashboardDetails(widget.programId);
          }),
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
                            dashBoardData[0].sourcePump.isNotEmpty?
                            Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Source Pump'),
                                    ),
                                    SizedBox(
                                      height: (dashBoardData[0].sourcePump.length % 5 == 0
                                          ? dashBoardData[0].sourcePump.length ~/ 5 * 70
                                          : (dashBoardData[0].sourcePump.length ~/ 5 + 1) * 70),
                                      child: DisplaySourcePump(sourcePump: dashBoardData[0].sourcePump, type: 0,),
                                    ),
                                    const Divider(height: 0),
                                  ],
                                ):
                            Container(),
                          if (dashBoardData.isNotEmpty)
                            dashBoardData[0].irrigationPump.isNotEmpty?
                            Column(
                              children: [
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
                              ],
                            ):
                            Container(),
                          if (dashBoardData.isNotEmpty)
                            dashBoardData[0].mainValve.isNotEmpty?
                            Column(
                              children: [
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
                              ],
                            ):
                            Container(),
                          if (dashBoardData.isNotEmpty)
                            dashBoardData[0].centralFilterSite.isNotEmpty?
                            Column(
                              children: [
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
                              ],
                            ):
                            Container(),
                          if (dashBoardData.isNotEmpty)
                            dashBoardData[0].centralFertilizerSite.isNotEmpty?
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Central Fertilizer Site'),
                                ),
                                SizedBox(
                                  height: dashBoardData[0].centralFertilizerSite.length * 170,
                                  child: DisplayCentralFertilizerSite(centralFertilizationSite: dashBoardData[0].centralFertilizerSite,),
                                ),
                                const Divider(height: 0),
                              ],
                            ):
                            Container(),
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
                    child: DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : [], prgId: widget.programId,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.programId==0 ? BottomAppBar(
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
                        tooltip: 'run again',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon:  const Icon(
                          Icons.settings_backup_restore,
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
      ) : null,
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
  const DisplayLineOrSequence({super.key, required this.lineOrSequence, required this.prgId});
  final List<LineOrSequence> lineOrSequence;
  final int prgId;

  @override
  State<DisplayLineOrSequence> createState() => _DisplayLineOrSequenceState();
}

class _DisplayLineOrSequenceState extends State<DisplayLineOrSequence> {
  String selectedValue = 'Single';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RTC ON Time : 10:00 AM', style: TextStyle(fontSize: 15),),
              Text('RTC OFF Time : 05:00 PM', style: TextStyle(fontSize: 15)),
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
                //Map<String, List<Sensor>> sensors = groupSensorByLocation(line.sensor);
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
                              Padding(
                                padding: const EdgeInsets.only(top: 3,bottom: 3),
                                child: VerticalDivider(color: myTheme.primaryColor.withOpacity(0.1)),
                              ),
                              SizedBox(
                                width: 220,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('Start at 09:00 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
                                          const SizedBox(width: 3,),
                                          Text('Duration(HH:MM) : ${line.time}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                      const SizedBox(width: 10,)
                                    ],
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
                                      'Valve Status',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  fixedWidth: 120,
                                ),
                              ],
                              rows: List<DataRow>.generate(groupedValves[valveLocation]!.length, (index) => DataRow(cells: [
                                DataCell(Center(child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.normal)))),
                                DataCell(Center(child: Text(groupedValves[valveLocation]![index].id, style: TextStyle(fontWeight: FontWeight.normal)))),
                                DataCell(Center(child: Text(groupedValves[valveLocation]![index].location, style: TextStyle(fontWeight: FontWeight.normal)))),
                                DataCell(Center(child: Text(groupedValves[valveLocation]![index].name, style: TextStyle(fontWeight: FontWeight.normal)))),
                                DataCell(Center(child: Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.normal),))),
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

  /*Map<String, List<Sensor>> groupSensorByLocation(List<Sensor> sensors) {
    Map<String, List<Sensor>> groupedSensor = {};
    for (var sensor in sensors) {
      if (!groupedSensor.containsKey(sensor.location)) {
        groupedSensor[sensor.location] = [];
      }
      groupedSensor[sensor.location]!.add(sensor);
    }
    return groupedSensor;
  }*/

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