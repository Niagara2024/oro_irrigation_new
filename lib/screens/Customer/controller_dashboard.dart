import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/Models/IrrigationModel/irrigation_program_model.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/irrigation_program_main.dart';
import 'package:oro_irrigation_new/screens/Customer/IrrigationProgram/program_library.dart';
import 'package:oro_irrigation_new/screens/Customer/conditionscreen.dart';
import 'package:oro_irrigation_new/screens/Customer/radiationsets.dart';

import '../../constants/http_service.dart';
import 'Group/groupscreen.dart';
import 'frost_productionScreen.dart';

enum MenuItems { itemOne, itemTwo, itemThree, itemFour, itemFive, itemSix, itemSeven, itemEight}
const List<String> list = <String>['Manual', 'Program 1', 'Program 2', 'Program 3'];
enum Calendar { manual, time, flow}

class ControllerDashboard extends StatefulWidget {
  const ControllerDashboard({Key? key, required this.customerID, required this.siteID, required this.siteName, required this.controllerID, required this.imeiNo}) : super(key: key);
  final int customerID, siteID, controllerID;
  final String siteName, imeiNo;

  @override
  State<ControllerDashboard> createState() => _ControllerDashboardState();
}

class _ControllerDashboardState extends State<ControllerDashboard>
{
  MenuItems? selectedMenu;
  String dropdownValue = list.first;
  late List<DashboardData> dashBoardData = [];
  bool visibleLoading = false;

  @override
  void initState() {
    super.initState();
    getControllerDashboardDetails();
  }

  Future<void> getControllerDashboardDetails() async
  {
    indicatorViewShow();
    try {
      dashBoardData = await fetchData();
      setState(() {
      });
    } catch (e) {
      print('Error: $e');
    }

  }

  Future<List<DashboardData>> fetchData() async {
    Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID};
    final response = await HttpService().postRequest("getCustomerDashboardByManual", body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      //print(jsonResponse);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white,),
                focusColor: Colors.transparent,
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.black87),),
                  );
                }).toList(),
              ),
              const SizedBox(width: 10,)
            ],
          ),
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), color: Colors.white, onPressed: () async
          {
            getControllerDashboardDetails();
          }),
          const SizedBox(width: 10,),
          IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings_outlined), color: Colors.white, onPressed: () async
          {
          }),
          const SizedBox(width: 10,),
          PopupMenuButton<MenuItems>(
            color: Colors.white,
            initialValue: selectedMenu,
            onSelected: (MenuItems item) {
              setState(() {
                selectedMenu = item;
                if(item.index==0){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProgramLibraryScreen(userId: widget.customerID, controllerId: widget.controllerID)));
                }
                else if(item.index==3){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  RadiationsetUI(userId: widget.customerID, controllerId: widget.controllerID)),);
                }
                else if(item.index==6){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConditionScreen(userId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNo)),);
                }
                else if(item.index==5){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyGroupScreen(userId: widget.customerID, controllerId: widget.controllerID)),);
                }
                else if(item.index==7){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  FrostMobUI(userId: widget.customerID, controllerId: widget.controllerID)),);
                }


              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItems>>[
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemOne,
                child: Text('Irrigation program'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemTwo,
                child: Text('Water source'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemThree,
                child: Text('Virtual Water Meter'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemFour,
                child: Text('Radiation sets'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemFive,
                child: Text('Satellite'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemSix,
                child: Text('Groups'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemSeven,
                child: Text('Conditions'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemEight,
                child: Text('Frost production & Rain delay'),
              ),

            ],
          ),
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
                Expanded(
                  flex: 10,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (dashBoardData.isNotEmpty) // Add this condition
                            SizedBox(
                              height: 100,
                              child: DisplaySourcePump(sourcePump: dashBoardData[0].sourcePump,),
                            ),
                          const Divider(),
                          if (dashBoardData.isNotEmpty) // Add this condition
                            SizedBox(
                              height: 100,
                              child: DisplayIrrigationPump(irrigationPump: dashBoardData[0].irrigationPump,),
                            ),
                          const Divider(),
                          if (dashBoardData.isNotEmpty) // Add this condition
                            SizedBox(
                              height: 100,
                              child: DisplayCentralFilterSite(centralFilterSite: dashBoardData[0]!.centralFilterSite,),
                            ),
                          const Divider(),
                          if (dashBoardData.isNotEmpty) // Add this condition
                            SizedBox(
                              height: 100,
                              child: DisplayCentralFertilizationSite(centralFertilizationSite: dashBoardData[0].centralFertilizationSite,),
                            ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DisplayLineOrSequence(lineOrSequence: dashBoardData.isNotEmpty ? dashBoardData[0].lineOrSequence : []),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              IconButton(
                  tooltip: 'list view',
                  onPressed: () {
                    debugPrint("Like button pressed");
                  },
                  icon: Icon(
                    Icons.list_alt,
                    size: 30,
                    color: myTheme.primaryColor,
                  )),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  tooltip: 'mapview',
                  onPressed: () {
                    debugPrint("Dislike button pressed");
                  },
                  icon:  Icon(
                    Icons.map_outlined,
                    size: 30,
                    color: myTheme.primaryColor,
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
                        icon: Icon(
                          Icons.skip_previous_outlined,
                          size: 30,
                          color: myTheme.primaryColor,
                        )),
                    IconButton(
                        tooltip: 'run',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon: Icon(
                          Icons.play_circle_outline,
                          size: 30,
                          color: myTheme.primaryColor,
                        )),
                    IconButton(
                        tooltip: 'run again',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon:  Icon(
                          Icons.settings_backup_restore,
                          size: 30,
                          color: myTheme.primaryColor,
                        )),
                    IconButton(
                        tooltip: 'skip next',
                        onPressed: () {
                          debugPrint("Bookmark button pressed");
                        },
                        icon: Icon(
                          Icons.skip_next_outlined,
                          size: 30,
                          color: myTheme.primaryColor,
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

class DashboardData {
  List<SourcePump> sourcePump;
  List<IrrigationPump> irrigationPump;
  List<LineOrSequence> lineOrSequence;
  List<CentralFertilizationSite> centralFertilizationSite;
  List<CentralFilterSite> centralFilterSite;

  DashboardData({
    required this.sourcePump,
    required this.irrigationPump,
    required this.lineOrSequence,
    required this.centralFertilizationSite,
    required this.centralFilterSite,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    List<SourcePump> sourcePumpList = (json['sourcePump'] as List)
        .map((sourcePumpJson) => SourcePump.fromJson(sourcePumpJson))
        .toList();

    List<IrrigationPump> irrigationPump = (json['irrigationPump'] as List)
        .map((sourcePumpJson) => IrrigationPump.fromJson(sourcePumpJson))
        .toList();

    List<LineOrSequence> lineOrSequence = (json['lineOrSequence'] as List)
        .map((irrigationLineJson) => LineOrSequence.fromJson(irrigationLineJson))
        .toList();

    List<CentralFilterSite> centralFilterSite = (json['centralFilterSite'] as List)
        .map((irrigationLineJson) => CentralFilterSite.fromJson(irrigationLineJson))
        .toList();

    List<CentralFertilizationSite> centralFertilizationSite = (json['centralFertilizerSite'] as List)
        .map((irrigationLineJson) => CentralFertilizationSite.fromJson(irrigationLineJson))
        .toList();

    return DashboardData(
      sourcePump: sourcePumpList,
      lineOrSequence: lineOrSequence,
      irrigationPump: irrigationPump,
      centralFertilizationSite: centralFertilizationSite,
      centralFilterSite: centralFilterSite,
    );
  }

}


class SourcePump {
  int sNo;
  String id;
  String name;
  String location;

  SourcePump({required this.sNo, required this.id, required this.name, required this.location});

  factory SourcePump.fromJson(Map<String, dynamic> json) {
    return SourcePump(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class IrrigationPump {
  int sNo;
  String id;
  String name;
  String location;

  IrrigationPump({required this.sNo, required this.id, required this.name, required this.location});

  factory IrrigationPump.fromJson(Map<String, dynamic> json) {
    return IrrigationPump(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class CentralFilterSite {
  int sNo;
  String id;
  String name;
  String location;

  CentralFilterSite({required this.sNo, required this.id, required this.name, required this.location});

  factory CentralFilterSite.fromJson(Map<String, dynamic> json) {
    return CentralFilterSite(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class CentralFertilizationSite {
  int sNo;
  String id;
  String name;
  String location;

  CentralFertilizationSite({required this.sNo, required this.id, required this.name, required this.location});

  factory CentralFertilizationSite.fromJson(Map<String, dynamic> json) {
    return CentralFertilizationSite(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class LineOrSequence {
  int sNo;
  String id;
  String name;
  String location;
  List<Valve> valves;
  List<MainValve> mainValves;
  List<MoistureSensor> moistureSensor;
  List<LevelSensor> levelSensor;


  LineOrSequence({required this.sNo, required this.id, required this.name, required this.location,
    required this.valves, required this.mainValves, required this.moistureSensor, required this.levelSensor});

  factory LineOrSequence.fromJson(Map<String, dynamic> json) {
    var valveList = json['valve'] as List;
    var mainValveList = json['mainValve'] as List;
    var moistureSensorList = json['moistureSensor'] as List;
    var levelSensorList = json['levelSensor'] as List;


    List<Valve> valves = valveList.map((valveJson) => Valve.fromJson(valveJson)).toList();
    List<MainValve> mainValves = mainValveList.map((valveJson) => MainValve.fromJson(valveJson)).toList();
    List<MoistureSensor> moistureSensor = moistureSensorList.map((valveJson) => MoistureSensor.fromJson(valveJson)).toList();
    List<LevelSensor> levelSensor = levelSensorList.map((valveJson) => LevelSensor.fromJson(valveJson)).toList();


    return LineOrSequence(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      valves: valves,
      mainValves: mainValves,
      moistureSensor: moistureSensor,
      levelSensor: levelSensor,
    );
  }
}

class Valve {
  int sNo;
  String id;
  String name;
  String location;

  Valve({required this.sNo, required this.id, required this.name, required this.location});

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class MainValve {
  int sNo;
  String id;
  String name;
  String location;

  MainValve({required this.sNo, required this.id, required this.name, required this.location});

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class MoistureSensor {
  int sNo;
  String id;
  String name;
  String location;

  MoistureSensor({required this.sNo, required this.id, required this.name, required this.location});

  factory MoistureSensor.fromJson(Map<String, dynamic> json) {
    return MoistureSensor(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class LevelSensor {
  int sNo;
  String id;
  String name;
  String location;

  LevelSensor({required this.sNo, required this.id, required this.name, required this.location});

  factory LevelSensor.fromJson(Map<String, dynamic> json) {
    return LevelSensor(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class DisplaySourcePump extends StatelessWidget
{
  const DisplaySourcePump({Key? key, required this.sourcePump}) : super(key: key);
  final List<SourcePump> sourcePump;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: sourcePump.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const CircleAvatar(child: Icon(Icons.account_balance_outlined),),
              Text(sourcePump[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
              Text(sourcePump[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
            ],
          ),
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
    return ListView.builder(
      scrollDirection: Axis.horizontal, // Set the direction to horizontal
      itemCount: irrigationPump.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const CircleAvatar(child: Icon(Icons.account_balance_outlined),),
              Text(irrigationPump[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
              Text(irrigationPump[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
            ],
          ),
        );
      },
    );
  }
}

class DisplayCentralFertilizationSite extends StatelessWidget
{
  const DisplayCentralFertilizationSite({super.key, required this.centralFertilizationSite});
  final List<CentralFertilizationSite> centralFertilizationSite;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal, // Set the direction to horizontal
      itemCount: centralFertilizationSite.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const CircleAvatar(child: Icon(Icons.account_balance_outlined),),
              Text(centralFertilizationSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
              Text(centralFertilizationSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
            ],
          ),
        );
      },
    );
  }
}

class DisplayCentralFilterSite extends StatelessWidget
{
  const DisplayCentralFilterSite({super.key, required this.centralFilterSite});
  final List<CentralFilterSite> centralFilterSite;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal, // Set the direction to horizontal
      itemCount: centralFilterSite.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const CircleAvatar(child: Icon(Icons.account_balance_outlined),),
              Text(centralFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
              Text(centralFilterSite[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
            ],
          ),
        );
      },
    );
  }
}



class DisplayLineOrSequence extends StatefulWidget {
  const DisplayLineOrSequence({super.key, required this.lineOrSequence});
  final List<LineOrSequence> lineOrSequence;

  @override
  State<DisplayLineOrSequence> createState() => _DisplayLineOrSequenceState();
}

class _DisplayLineOrSequenceState extends State<DisplayLineOrSequence> {
  Calendar calendarView = Calendar.manual;

  @override
  Widget build(BuildContext context)
  {

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<Calendar>(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.1)),
                    iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                  ),
                  segments: const <ButtonSegment<Calendar>>[
                    ButtonSegment<Calendar>(
                        value: Calendar.manual,
                        label: Text('Default'),
                        icon: Icon(Icons.edit_note)),
                    ButtonSegment<Calendar>(
                        value: Calendar.time,
                        label: Text('Time'),
                        icon: Icon(Icons.timer_outlined)),
                    ButtonSegment<Calendar>(
                        value: Calendar.flow,
                        label: Text('Flow'),
                        icon: Icon(Icons.gas_meter_outlined)),
                  ],
                  selected: <Calendar>{calendarView},
                  onSelectionChanged: (Set<Calendar> newSelection) {
                    setState(() {
                      // By default there is only a single segment that can be
                      // selected at one time, so its value is always the first
                      // item in the selected set.
                      calendarView = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child:
            ListView.builder(
              itemCount: widget.lineOrSequence.length,
              itemBuilder: (context, index) {
                LineOrSequence line = widget.lineOrSequence[index];
                Map<String, List<Valve>> groupedValves = groupValvesByLocation(line.valves);
                Map<String, List<MainValve>> groupedMainValves = groupMainValvesByLocation(line.mainValves);
                Map<String, List<MoistureSensor>> groupedMoistureSensor = groupMoistureSensorByLocation(line.moistureSensor);
                Map<String, List<LevelSensor>> groupedLevelSensor = groupLevelSensorByLocation(line.levelSensor);

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: myTheme.primaryColor.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            'Location : ${line.name}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Main Valve'),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width-740,
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: groupedMainValves.length,
                              itemBuilder: (BuildContext context, int index) {
                                var mainValveLocation = groupedMainValves.keys.elementAt(index);
                                return Row(
                                  children: [
                                    for (var mainValve in groupedMainValves[mainValveLocation]!)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 22,
                                          child: Text(mainValve.id, style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Moisture Sensor'),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width-740,
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: groupedMoistureSensor.length,
                              itemBuilder: (BuildContext context, int index) {
                                var moistureSensorLocation = groupedMoistureSensor.keys.elementAt(index);
                                return Row(
                                  children: [
                                    for (var moistureSensor in groupedMoistureSensor[moistureSensorLocation]!)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 22,
                                          child: Text(moistureSensor.id, style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Level Sensor'),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width-740,
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: groupedLevelSensor.length,
                              itemBuilder: (BuildContext context, int index) {
                                var levelSensorLocation = groupedLevelSensor.keys.elementAt(index);
                                return Row(
                                  children: [
                                    for (var levelSensor in groupedLevelSensor[levelSensorLocation]!)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 22,
                                          child: Text(levelSensor.id, style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      for (var valveLocation in groupedValves.keys)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var valve in groupedValves[valveLocation]!)
                              Card(
                                elevation: 5,
                                child: ListTile(
                                  title: Text(valve.id),
                                  subtitle: Text(valve.name),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
        ),
      ],
    );
  }

  Map<String, List<Valve>> groupValvesByLocation(List<Valve> valves) {
    Map<String, List<Valve>> groupedValves = {};
    for (var valve in valves) {
      if (!groupedValves.containsKey(valve.location)) {
        groupedValves[valve.location] = [];
      }
      groupedValves[valve.location]!.add(valve);
    }
    return groupedValves;
  }

  Map<String, List<MainValve>> groupMainValvesByLocation(List<MainValve> mainValves) {
    Map<String, List<MainValve>> groupedMainValves = {};
    for (var mainValve in mainValves) {
      if (!groupedMainValves.containsKey(mainValve.location)) {
        groupedMainValves[mainValve.location] = [];
      }
      groupedMainValves[mainValve.location]!.add(mainValve);
    }
    return groupedMainValves;
  }

  Map<String, List<MoistureSensor>> groupMoistureSensorByLocation(List<MoistureSensor> moistureSensor) {
    Map<String, List<MoistureSensor>> groupedMoistureSensor = {};
    for (var moistureSensor in moistureSensor) {
      if (!groupedMoistureSensor.containsKey(moistureSensor.location)) {
        groupedMoistureSensor[moistureSensor.location] = [];
      }
      groupedMoistureSensor[moistureSensor.location]!.add(moistureSensor);
    }
    return groupedMoistureSensor;
  }

  Map<String, List<LevelSensor>> groupLevelSensorByLocation(List<LevelSensor> levelSensor) {
    Map<String, List<LevelSensor>> groupedLevelSensor = {};
    for (var levelSensor in levelSensor) {
      if (!groupedLevelSensor.containsKey(levelSensor.location)) {
        groupedLevelSensor[levelSensor.location] = [];
      }
      groupedLevelSensor[levelSensor.location]!.add(levelSensor);
    }
    return groupedLevelSensor;
  }
}

