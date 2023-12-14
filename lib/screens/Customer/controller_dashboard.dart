import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../Models/Customer/Dashboard/CentralFertilizerSite.dart';
import '../../Models/Customer/Dashboard/CentralFilterSite.dart';
import '../../Models/Customer/Dashboard/DashBoardValve.dart';
import '../../Models/Customer/Dashboard/FertilizerChanel.dart';
import '../../Models/Customer/Dashboard/IrrigationPump.dart';
import '../../Models/Customer/Dashboard/LineOrSequence.dart';
import '../../Models/Customer/Dashboard/MainValve.dart';
import '../../Models/Customer/Dashboard/Sensor.dart';
import '../../Models/Customer/Dashboard/SourcePump.dart';
import '../../constants/http_service.dart';


enum Calendar {manual, duration, flow}

class ControllerDashboard extends StatefulWidget {
  const ControllerDashboard({Key? key, required this.customerID, required this.siteID, required this.siteName, required this.controllerID, required this.imeiNo, required this.programId}) : super(key: key);
  final int customerID, siteID, controllerID, programId;
  final String siteName, imeiNo;

  @override
  State<ControllerDashboard> createState() => _ControllerDashboardState();
}

class _ControllerDashboardState extends State<ControllerDashboard>
{
  late List<DashboardData> dashBoardData = [];
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

  Future<List<DashboardData>> fetchControllerData(int id) async
  {
    Map<String, Object> body = id == 0 ? {"userId": widget.customerID, "controllerId": widget.controllerID} :
    {"userId": widget.customerID, "controllerId": widget.controllerID, "programId": id};
    final response = await HttpService().postRequest(id == 0? "getCustomerDashboardByManual" : "getCustomerDashboardByProgram", body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      indicatorViewHide();

      if (jsonResponse['data'] != null) {
        dynamic data = jsonResponse['data'];
        if (data is Map<String, dynamic>) {
          return [DashboardData.fromJson(data)];
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
    /*List<int> myList = [data[0].sourcePump.length, data[0].irrigationPump.length, data[0].centralFilterSite.length, data[0].centralFertilizationSite.length];
    int maxValue = myList.reduce((max, current) => current > max ? current : max);

    Map<String, int> locationCounts = {};
    for (var valve in data[0].valve) {
      String location = valve.location;
      locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    }

    int maxCount = 0;
    locationCounts.forEach((location, count) {
      if (count > maxCount) {
        maxCount = count;
      }
    });*/
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

class DashboardData {
  List<SourcePump> sourcePump;
  List<IrrigationPump> irrigationPump;
  List<MainValve> mainValve;
  List<LineOrSequence> lineOrSequence;
  List<CentralFertilizerSite> centralFertilizerSite;
  List<CentralFilterSite> centralFilterSite;

  DashboardData({
    required this.sourcePump,
    required this.irrigationPump,
    required this.mainValve,
    required this.lineOrSequence,
    required this.centralFertilizerSite,
    required this.centralFilterSite,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    List<SourcePump> sourcePumpList = (json['sourcePump'] as List)
        .map((sourcePumpJson) => SourcePump.fromJson(sourcePumpJson))
        .toList();

    List<IrrigationPump> irrigationPump = (json['irrigationPump'] as List)
        .map((sourcePumpJson) => IrrigationPump.fromJson(sourcePumpJson))
        .toList();

    List<MainValve> mainValve = (json['mainValve'] as List)
        .map((sourcePumpJson) => MainValve.fromJson(sourcePumpJson))
        .toList();

    List<LineOrSequence> lineOrSequence = (json['lineOrSequence'] as List)
        .map((irrigationLineJson) => LineOrSequence.fromJson(irrigationLineJson))
        .toList();

    List<CentralFilterSite> centralFilterSite = (json['centralFilterSite'] as List)
        .map((irrigationLineJson) => CentralFilterSite.fromJson(irrigationLineJson))
        .toList();

    List<CentralFertilizerSite> centralFertilizerSite = (json['centralFertilizerSite'] as List)
        .map((irrigationLineJson) => CentralFertilizerSite.fromJson(irrigationLineJson))
        .toList();

    return DashboardData(
      sourcePump: sourcePumpList,
      mainValve: mainValve,
      lineOrSequence: lineOrSequence,
      irrigationPump: irrigationPump,
      centralFertilizerSite: centralFertilizerSite,
      centralFilterSite: centralFilterSite,
    );
  }

}

class Program {
  final int programId;
  final int serialNumber;
  final String programName;
  final String defaultProgramName;
  final String programType;
  final int priority;

  Program({
    required this.programId,
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.priority,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      programId: json['programId'],
      serialNumber: json['serialNumber'],
      programName: json['programName'],
      defaultProgramName: json['defaultProgramName'],
      programType: json['programType'],
      priority: json['priority'],
    );
  }
}

class DisplaySourcePump extends StatelessWidget
{
  const DisplaySourcePump({Key? key, required this.sourcePump}) : super(key: key);
  final List<SourcePump> sourcePump;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: sourcePump.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/source_pump.png'),
              backgroundColor: Colors.transparent,
              child: IconButton(
                  hoverColor: Colors.transparent,
                  tooltip: sourcePump[index].name,
                  onPressed: (){
                  }, icon: const Text('    '),
                  ),
            ),
            Text(sourcePump[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}


class DisplayIrrigationPump extends StatelessWidget
{
  const DisplayIrrigationPump({Key? key, required this.irrigationPump}) : super(key: key);
  final List<IrrigationPump> irrigationPump;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: irrigationPump.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/irrigation_pump.png'),
              backgroundColor: Colors.transparent,
              child: IconButton(
                  hoverColor: Colors.transparent,
                  tooltip: '${irrigationPump[index].name}\n${irrigationPump[index].location}',
                  onPressed: (){},
                  icon: const Text('      ')
              ),
            ),
            Text(irrigationPump[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: irrigationPump.length,
      itemBuilder: (context, index) {
        return Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/images/irrigation_pump.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(irrigationPump[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                    Text(irrigationPump[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                    Text('Location : ${irrigationPump[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DisplayMainValve extends StatelessWidget
{
  const DisplayMainValve({Key? key, required this.mainValve}) : super(key: key);
  final List<MainValve> mainValve;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: mainValve.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/main_valve.png'),
              backgroundColor: Colors.transparent,
            ),
            Text(mainValve[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}

class DisplayCentralFertilizerSite extends StatelessWidget
{
  const DisplayCentralFertilizerSite({super.key, required this.centralFertilizationSite});
  final List<CentralFertilizerSite> centralFertilizationSite;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: centralFertilizationSite.length,
      itemBuilder: (context, index) {

        List<FertilizerChanel> fertilizers = centralFertilizationSite[index].fertilizer;

        return Card(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(centralFertilizationSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
                        Text(centralFertilizationSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
                        Text('Location : ${centralFertilizationSite[index].location}', style: const TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.sizeOf(context).width-1070,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
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
                                          const VerticalDivider(),
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.grey,
                                            child: Text('${index+1}', style: const TextStyle(fontSize: 13, color: Colors.white),),
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
    );
  }

  Map<String, List<FertilizerChanel>> groupFertilizerChanelByLocation(List<FertilizerChanel> fertChanel) {
    Map<String, List<FertilizerChanel>> groupedFertChanel = {};
    for (var fertChanel in fertChanel) {
      if (!groupedFertChanel.containsKey(fertChanel.location)) {
        groupedFertChanel[fertChanel.location] = [];
      }
      groupedFertChanel[fertChanel.location]!.add(fertChanel);
    }
    return groupedFertChanel;
  }
}

class DisplayCentralFilterSite extends StatelessWidget
{
  const DisplayCentralFilterSite({super.key, required this.centralFilterSite});
  final List<CentralFilterSite> centralFilterSite;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 3.0, // Spacing between columns
        mainAxisSpacing: 3.0, // Spacing between rows
      ),
      itemCount: centralFilterSite.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: const AssetImage('assets/images/central_filtration.png'),
              backgroundColor: Colors.transparent,
              child: IconButton(
                  hoverColor: Colors.transparent,
                  tooltip: '${centralFilterSite[index].name}\n${centralFilterSite[index].location}',
                  onPressed: (){},
                  icon: const Text('      ')
              ),
            ),
            Text(centralFilterSite[index].id, style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
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
  Calendar calendarView = Calendar.manual;
  String selectedValue = 'Single';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        widget.prgId ==0 ? const SizedBox(height: 10,): 
        Container(),
        widget.prgId ==0 ? SizedBox(
          width: MediaQuery.of(context).size.width-550,
          height: 35,
          child: SegmentedButton<Calendar>(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.05)),
              iconColor: MaterialStateProperty.all(myTheme.primaryColor),
            ),
            segments: const <ButtonSegment<Calendar>>[
              ButtonSegment<Calendar>(
                  value: Calendar.manual,
                  label: Text('Default'),
                  icon: Icon(Icons.edit_note)),
              ButtonSegment<Calendar>(
                  value: Calendar.duration,
                  label: Text('Duration'),
                  icon: Icon(Icons.timer_outlined)),
              ButtonSegment<Calendar>(
                  value: Calendar.flow,
                  label: Text('Flow'),
                  icon: Icon(Icons.gas_meter_outlined)),
            ],
            selected: <Calendar>{calendarView},
            onSelectionChanged: (Set<Calendar> newSelection) {
              setState(() {
                calendarView = newSelection.first;
              });
            },
          ),
        ) : 
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
                Map<String, List<Sensor>> sensors = groupSensorByLocation(line.sensor);
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
                          child: widget.prgId ==0 ? Row(
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
                          ) :
                          Row(
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
                                  label: widget.prgId ==0? const Center(
                                    child: Text(
                                      'On/Off Status',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.right,
                                    ),
                                  ):
                                  const Center(
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
                                DataCell(Center(
                                    child: widget.prgId ==0? Transform.scale(
                                      scale: 0.7,
                                      child: Switch(
                                        value: groupedValves[valveLocation]![index].isOn,
                                        onChanged: (value) {
                                          setState(() {
                                            groupedValves[valveLocation]![index].isOn = value;
                                          });
                                        },
                                      ),
                                    ):
                                    Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.normal),))
                                ),
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

  Map<String, List<Sensor>> groupSensorByLocation(List<Sensor> sensors) {
    Map<String, List<Sensor>> groupedSensor = {};
    for (var sensor in sensors) {
      if (!groupedSensor.containsKey(sensor.location)) {
        groupedSensor[sensor.location] = [];
      }
      groupedSensor[sensor.location]!.add(sensor);
    }
    return groupedSensor;
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
      print('Selected time: $selectedTime');
      String hour = selectedTime.hour.toString().padLeft(2, '0');
      String minute = selectedTime.minute.toString().padLeft(2, '0');

      setState(() {
        lineOrSequence.time = '$hour:$minute';
      });

    }
  }
}