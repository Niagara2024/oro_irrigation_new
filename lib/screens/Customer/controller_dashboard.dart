import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Customer/conditionscreen.dart';

import '../../constants/http_service.dart';

enum MenuItems { itemOne, itemTwo, itemThree, itemFour, itemFive, itemSix, itemSeven}
const List<String> list = <String>['Manual', 'Program 1', 'Program 2', 'Program 3'];


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
  late List<DashboardData> data = [];

  @override
  void initState() {
    super.initState();
    getControllerDashboardDetails();
  }

  Future<void> getControllerDashboardDetails() async
  {
    try {
      data = await fetchData();
      setState(() {
      });
    } catch (e) {
      print('Error: $e');
    }

  }

  Future<List<DashboardData>> fetchData() async
  {
    Map<String, Object> body = {"userId" : widget.customerID, "controllerId" : widget.controllerID};
    print(body);
    final response = await HttpService().postRequest("getCustomerDashboard", body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['data'] as List<dynamic>)
          .map((item) => DashboardData.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context)
  {
    List<int> myList = [data[0].sourcePump.length, data[0].irrigationPump.length, data[0].centralFilterSite.length, data[0].centralFertilizationSite.length];
    int maxValue = myList.reduce((max, current) => current > max ? current : max);
    print(maxValue);

    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Text(widget.siteName),
        actions: [
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), color: Colors.white, onPressed: () async
          {
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
                if(item.index==3){
                  print('condition selection');
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConditionScreen(userId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNo,)),);
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
                child: Text('Groups'),
              ),
              const PopupMenuItem<MenuItems>(
                value: MenuItems.itemFour,
                child: Text('Conditions'),
              ),
            ],
          ),
          const SizedBox(width: 20,),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: myTheme.primaryColor,
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 10,)
                  ],
                ),
                const Divider(),
                SizedBox(
                  height: maxValue*120,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Source Pump'),
                            const Divider(),
                            SizedBox(
                              height: maxValue*100,
                              child: DisplaySourcePump(sourcePump: data[0].sourcePump,),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Irrigation Pump'),
                            const Divider(),
                            SizedBox(
                              height: maxValue*100,
                              child: DisplayIrrigationPump(irrigationPump: data[0].irrigationPump,),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Central Filter Site'),
                            const Divider(),
                            SizedBox(
                              height: maxValue*100,
                              child: DisplayCentralFilterSite(centralFilterSite: data[0].centralFilterSite,),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Central Fertilization Site'),
                            const Divider(),
                            SizedBox(
                              height: maxValue*100,
                              child: DisplayCentralFertilizationSite(centralFertilizationSite: data[0].centralFertilizationSite,),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height-252,
                        child: DisplayIrrigationLine(irrigationLine: data[0].irrigationLine, valves: data[0].valve,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              // Like button
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
              // Dislike button
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
              // Comment button
              // Bookmark/Save button
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

}

class DisplaySourcePump extends StatelessWidget
{
  const DisplaySourcePump({super.key, required this.sourcePump});
  final List<SourcePump> sourcePump;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical, // Set the direction to horizontal
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
  const DisplayIrrigationPump({super.key, required this.irrigationPump});
  final List<IrrigationPump> irrigationPump;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical, // Set the direction to horizontal
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
      scrollDirection: Axis.vertical, // Set the direction to horizontal
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
      scrollDirection: Axis.vertical, // Set the direction to horizontal
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

class DisplayIrrigationLine extends StatelessWidget
{
  const DisplayIrrigationLine({super.key, required this.irrigationLine, required this.valves});
  final List<IrrigationLine> irrigationLine;
  final List<Valve> valves;

  @override
  Widget build(BuildContext context)
  {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: irrigationLine.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {

        List<Map<String, dynamic>> valvesMapList = valves.map((valve) => valve.toJson())
            .where((valveMap) => valveMap['location'] == irrigationLine[index].id).toList();

        return Row(
          children: [
            SizedBox(
              width: 450,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(irrigationLine[index].name),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: valvesMapList.length,
                      itemBuilder: (context, itemIndex) {
                        Map<String, dynamic> item = valvesMapList[itemIndex];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 70,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)), //here
                              color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0, -3),
                                      blurRadius: 3.0)
                                ],
                            )
                          ),
                        );
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: Wrap(
                              spacing: 10, // space between two icons
                              children: <Widget>[
                                Container(
                                  width: 7,
                                  height: 50,
                                  color: Colors.red,
                                ),
                                const CircleAvatar(child: Icon(Icons.vaccines),),
                              ],
                            ),
                            title: Text(item['name']),
                            subtitle: Text(item['location']),
                            trailing: const Wrap(
                              spacing: 12, // space between two icons
                              children: <Widget>[
                                Column(children: [
                                  Text('Set Time', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text('00:10:00'),
                                ],),
                                VerticalDivider(), // icon-1
                                Column(children: [
                                  Text('Remaining Time', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text('00:03:00'),
                                ],),
                                Icon(Icons.timelapse_outlined),// icon-2
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(),
          ],
        );
      },
    );
  }
}

class DisplayValve extends StatelessWidget
{
  const DisplayValve({super.key, required this.valve});
  final List<Valve> valve;

  @override
  Widget build(BuildContext context)
  {
    return ListView.builder(
      scrollDirection: Axis.vertical, // Set the direction to horizontal
      itemCount: valve.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(valve[index].name, style: const TextStyle(fontWeight: FontWeight.normal),),
              Text(valve[index].id, style: const TextStyle(fontWeight: FontWeight.normal),),
            ],
          ),
        );
      },
    );
  }
}

class DashboardData
{
  final List<SourcePump> sourcePump;
  final List<IrrigationPump> irrigationPump;
  final List<CentralFilterSite> centralFilterSite;
  final List<CentralFertilizationSite> centralFertilizationSite;
  final List<IrrigationLine> irrigationLine;
  final List<Valve> valve;
  final List<MainValve> mainValve;

  DashboardData({
    required this.sourcePump,
    required this.irrigationPump,
    required this.centralFilterSite,
    required this.centralFertilizationSite,
    required this.irrigationLine,
    required this.valve,
    required this.mainValve,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      sourcePump: (json['sourcePump'] as List<dynamic>?)
          ?.map((item) => SourcePump.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      irrigationPump: (json['irrigationPump'] as List<dynamic>?)
          ?.map((item) => IrrigationPump.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      centralFilterSite: (json['centralFilterSite'] as List<dynamic>?)
          ?.map((item) => CentralFilterSite.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      centralFertilizationSite: (json['centralFertilizationSite'] as List<dynamic>?)
          ?.map((item) => CentralFertilizationSite.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      irrigationLine: (json['irrigationLine'] as List<dynamic>?)
          ?.map((item) => IrrigationLine.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      valve: (json['valve'] as List<dynamic>?)
          ?.map((item) => Valve.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      mainValve: (json['mainValve'] as List<dynamic>?)
          ?.map((item) => MainValve.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      // Add other fields here.
    );
  }
}

class SourcePump {
  final int sNo;
  final String id;
  final String location;
  final String name;

  SourcePump({required this.sNo, required this.id, required this.location, required this.name});

  factory SourcePump.fromJson(Map<String, dynamic> json) {
    return SourcePump(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class IrrigationPump {
  final int sNo;
  final String id;
  final String location;
  final String name;

  IrrigationPump({required this.sNo, required this.id, required this.location, required this.name});

  factory IrrigationPump.fromJson(Map<String, dynamic> json) {
    return IrrigationPump(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CentralFilterSite {
  final int sNo;
  final String id;
  final String location;
  final String name;

  CentralFilterSite({required this.sNo, required this.id, required this.location, required this.name});

  factory CentralFilterSite.fromJson(Map<String, dynamic> json) {
    return CentralFilterSite(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CentralFertilizationSite {
  final int sNo;
  final String id;
  final String location;
  final String name;

  CentralFertilizationSite({required this.sNo, required this.id, required this.location, required this.name});

  factory CentralFertilizationSite.fromJson(Map<String, dynamic> json) {
    return CentralFertilizationSite(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class IrrigationLine {
  final int sNo;
  final String id;
  final String location;
  final String name;

  IrrigationLine({required this.sNo, required this.id, required this.location, required this.name});

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    return IrrigationLine(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Valve {
  final int sNo;
  final String id;
  final String location;
  final String name;

  Valve({required this.sNo, required this.id, required this.location, required this.name});

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'id': id,
      'location': location,
      'name': name,
    };
  }
}

class MainValve {
  final int sNo;
  final String id;
  final String location;
  final String name;

  MainValve({required this.sNo, required this.id, required this.location, required this.name});

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'] ?? 0,
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
