import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/CurrentSchedule.dart';
import 'Dashboard/RunByManual.dart';
import 'ProgramSchedule.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key, required this.userID, required this.customerID, required this.type, required this.customerName, required this.mobileNo, required this.siteData, required this.siteLength}) : super(key: key);
  final int userID, customerID, type, siteLength;
  final String customerName, mobileNo;
  final DashboardModel siteData;

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> with SingleTickerProviderStateMixin {

  int wifiStrength = 0, siteIndex = 0;
  String lastSyncData = '';

  late AnimationController animationController;
  late Animation<double> rotationAnimation;
  List<ProgramList> programList = [];

  @override
  void initState() {
    super.initState();
    //call live
    String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
    initRotationAnimation();
    getProgramList();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void onRefreshClicked() {
    animationController.repeat();
    Future.delayed(const Duration(milliseconds: 500), () {
      animationController.stop();
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
    });
  }

  Future<void> getProgramList() async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.siteData.controllerId};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> programsJson = jsonResponse['data'];
        setState(() {
          programList = [
            ...programsJson.map((programJson) => ProgramList.fromJson(programJson)).toList(),
          ];
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void callbackFunction(message)
  {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });
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
          lastSyncData = '${getCurrentDate()}-${getCurrentTime()}';
        }
        if (data['2400'][0].containsKey('2401')) {
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
        }

      });
    }
    catch(e){
      print(e);
    }

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Card(
            elevation: 2,
            surfaceTintColor: Colors.white,
            shape: const RoundedRectangleBorder(),
            margin: EdgeInsets.zero,
            child: ListTile(
              tileColor: Colors.transparent,
              leading: Image.asset('assets/images/oro_gem.png'),
              title: Text(widget.siteData.deviceName),
              subtitle: Text('${widget.siteData.categoryName} - Last sync : $lastSyncData', style: const TextStyle(fontWeight: FontWeight.normal),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(wifiStrength == 0? Icons.wifi_off:
                  wifiStrength >= 1 && wifiStrength <= 20 ? Icons.network_wifi_1_bar_outlined:
                  wifiStrength >= 21 && wifiStrength <= 40 ? Icons.network_wifi_2_bar_outlined:
                  wifiStrength >= 41 && wifiStrength <= 60 ? Icons.network_wifi_3_bar_outlined:
                  wifiStrength >= 61 && wifiStrength <= 80 ? Icons.network_wifi_outlined:
                  Icons.wifi),
                  const SizedBox(width: 5,),
                  Text('$wifiStrength %', style: const TextStyle(fontWeight: FontWeight.normal),),
                  const SizedBox(width: 5,),
                  RotationTransition(
                    turns: rotationAnimation,
                    child: IconButton(
                      tooltip: 'refresh',
                      icon: const Icon(Icons.refresh),
                      onPressed: onRefreshClicked,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  IconButton(
                    tooltip: 'Manual Mode',
                    icon: const Icon(Icons.touch_app_outlined),
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return RunByManual(siteID: widget.siteData.siteId,
                              siteName: widget.siteData.siteName,
                              controllerID: widget.siteData.controllerId,
                              customerID: widget.customerID,
                              imeiNo: widget.siteData.deviceId,
                              programList: programList, callbackFunction: callbackFunction);
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 5,),
                  IconButton(
                    tooltip: 'Planning',
                    icon: const Icon(Icons.list_alt),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgramSchedule(
                            customerID: widget.customerID,
                            controllerID: widget.siteData.controllerId,
                            siteName: widget.siteData.siteName,
                            imeiNumber: widget.siteData.deviceId,
                            userId: widget.customerID,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // make it circular
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 220,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 400,
                                      child: Column(
                                        children: [
                                          const ListTile(
                                            title: Text('Main Line'),
                                          ),
                                          widget.siteData.irrigationPump.isNotEmpty
                                              ||widget.siteData.centralFilterSite.isNotEmpty
                                              ||widget.siteData.mainValve.isNotEmpty?
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 49.5,
                                                  height: 145,
                                                  child: ListView.builder(
                                                    itemCount: widget.siteData.irrigationPump.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      if (index < widget.siteData.irrigationPump.length) {
                                                        return Column(
                                                          children: [
                                                            PopupMenuButton(
                                                              tooltip: 'Details',
                                                              itemBuilder: (context) {
                                                                return [
                                                                  PopupMenuItem(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        Text(widget.siteData.irrigationPump[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                        const Divider(),
                                                                        Text('ID : ${widget.siteData.irrigationPump[index].id}'),
                                                                        Text('Location : ${widget.siteData.irrigationPump[index].location}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ];
                                                              },
                                                              child: widget.siteData.irrigationPump.length ==1?
                                                              Image.asset('assets/images/dp_irr_pump.png'):
                                                              widget.siteData.irrigationPump.length==2 && index==0?
                                                              Image.asset('assets/images/dp_irr_pump_1.png'):
                                                              widget.siteData.irrigationPump.length==2 && index==1?
                                                              Image.asset('assets/images/dp_irr_pump_3.png'):
                                                              widget.siteData.irrigationPump.length==3 && index==0?
                                                              Image.asset('assets/images/dp_irr_pump_1.png'):
                                                              widget.siteData.irrigationPump.length==3 && index==1?
                                                              Image.asset('assets/images/dp_irr_pump_2.png'):
                                                              Image.asset('assets/images/dp_irr_pump_3.png'),
                                                            ),
                                                          ],
                                                        ); // Replace 'yourKey' with the key from your API response
                                                      } else {
                                                        return Text('Out of range'); // or any placeholder/error message
                                                      }
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 49.5,
                                                  height: 145,
                                                  child: ListView.builder(
                                                    itemCount: 1,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return Column(
                                                        children: [
                                                          PopupMenuButton(
                                                            tooltip: 'Details',
                                                            itemBuilder: (context) {
                                                              return [
                                                                const PopupMenuItem(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Text('Pressure Sensor', style: TextStyle(fontWeight: FontWeight.bold),),
                                                                      Divider(),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ];
                                                            },
                                                            child: Image.asset('assets/images/dp_prs_sensor.png',),
                                                          ),
                                                          const Text('Prs In',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                                                          const Text('7.0 bar',style: TextStyle(fontSize: 10),),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 49.5,
                                                  height: 145,
                                                  child: ListView.builder(
                                                    itemCount: 1,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      if (index < widget.siteData.centralFilterSite.length) {
                                                        return Column(
                                                          children: [
                                                            PopupMenuButton(
                                                              tooltip: 'Details',
                                                              itemBuilder: (context) {
                                                                return [
                                                                  PopupMenuItem(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        Text(widget.siteData.centralFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                        const Divider(),
                                                                        Text('ID : ${widget.siteData.centralFilterSite[index].id}'),
                                                                        Text('Location : ${widget.siteData.centralFilterSite[index].location}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ];
                                                              },
                                                              child: Image.asset('assets/images/dp_filter.png',),
                                                            ),
                                                          ],
                                                        ); // Replace 'yourKey' with the key from your API response
                                                      } else {
                                                        return const Text('Out of range'); // or any placeholder/error message
                                                      }
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 49.5,
                                                  height: 145,
                                                  child: ListView.builder(
                                                    itemCount: 1,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return Column(
                                                        children: [
                                                          PopupMenuButton(
                                                            tooltip: 'Details',
                                                            itemBuilder: (context) {
                                                              return [
                                                                const PopupMenuItem(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Text('Pressure Sensor', style: TextStyle(fontWeight: FontWeight.bold),),
                                                                      Divider(),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ];
                                                            },
                                                            child: Image.asset('assets/images/dp_prs_sensor.png',),
                                                          ),
                                                          const Text('Prs Out',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                                                          const Text('6.2 bar',style: TextStyle(fontSize: 10),),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 49.5,
                                                  height: 145,
                                                  child: ListView.builder(
                                                    itemCount: widget.siteData.mainValve.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      if (index < widget.siteData.mainValve.length) {
                                                        return Column(
                                                          children: [
                                                            PopupMenuButton(
                                                              tooltip: 'Details',
                                                              itemBuilder: (context) {
                                                                return [
                                                                  PopupMenuItem(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        Text(widget.siteData.mainValve[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                        const Divider(),
                                                                        Text('ID : ${widget.siteData.mainValve[index].id}'),
                                                                        Text('Location : ${widget.siteData.mainValve[index].location}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ];
                                                              },
                                                              child: Image.asset('assets/images/db_valve.png',),
                                                            ),
                                                          ],
                                                        ); // Replace 'yourKey' with the key from your API response
                                                      } else {
                                                        return Text('Out of range'); // or any placeholder/error message
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ):
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 50,),
                                              Text('No Device Available'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(width: 0),
                                    Expanded(
                                      flex :1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const ListTile(
                                            title: Text('Dosing Recipes - NPK1'),
                                          ),
                                          SizedBox(
                                            height: 40,
                                            child: Row(
                                              children: [
                                                const SizedBox(width : 40, child: Icon(Icons.account_tree_rounded)),
                                                const SizedBox(width: 10,),
                                                const Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('EC',style: TextStyle(fontSize: 10)),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text('Actual:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                                          Text('00.0',style: TextStyle(fontSize: 10)),
                                                          SizedBox(width: 5,),
                                                          Text('Target:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                                          Text('00.0',style: TextStyle(fontSize: 10)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text('PH',style: TextStyle(fontSize: 10)),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Text('Actual:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                                          Text('00.0',style: TextStyle(fontSize: 10)),
                                                          SizedBox(width: 5,),
                                                          Text('Target:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                                                          Text('00.0',style: TextStyle(fontSize: 10)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width : 40, child: Image.asset('assets/images/injector.png',)),
                                              ],),
                                          ),
                                          Flexible(
                                              flex: 2,
                                              child: DataTable2(
                                                columnSpacing: 12,
                                                horizontalMargin: 12,
                                                minWidth: 400,
                                                dataRowHeight: 20.0,
                                                headingRowHeight: 20,
                                                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                                                columns: const [
                                                  DataColumn2(
                                                      label: Center(child: Text('Channel', style: TextStyle(fontSize: 10),)),
                                                      size: ColumnSize.M
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('1', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('2', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('3', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('4', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('5', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('6', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('7', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 37
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('8', style: TextStyle(fontSize: 10),)),
                                                      fixedWidth: 30
                                                  ),
                                                ],
                                                rows: List<DataRow>.generate(5, (index) => DataRow(cells: [
                                                  DataCell(Center(child: Text(index==0? 'Open(%)':index==1?'Flow(l/h)':index==2?'Qty Delivered': index==3?'Time Delivered':'Set Point',
                                                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                  DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                                                ])),
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 0),
                              SizedBox(
                                child: CurrentSchedule(userID: widget.userID, customerID: widget.customerID, siteData: widget.siteData),
                              ),
                              const Divider(height: 0),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      const ListTile(
                                        tileColor: Colors.white,
                                        title: Text('NEXT SCHEDULE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                      const Divider(height: 0),
                                      Container(
                                        color: Colors.white,
                                        height: widget.siteData.nextProgram.isNotEmpty? (widget.siteData.nextProgram.length * 50) +35 : 50,
                                        child: widget.siteData.nextProgram.isNotEmpty? ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: widget.siteData.nextProgram.length,
                                            itemBuilder: (context, cpInx) {
                                              return SizedBox(
                                                height: 100,
                                                child: DataTable2(
                                                  columnSpacing: 12,
                                                  horizontalMargin: 12,
                                                  minWidth: 550,
                                                  dataRowHeight: 50.0,
                                                  headingRowHeight: 35.0,
                                                  headingRowColor: MaterialStateProperty.all<Color>(Colors.green.withOpacity(0.1)),
                                                  //border: TableBorder.all(),
                                                  columns: const [
                                                    DataColumn2(
                                                        label: Text('Name', style: TextStyle(fontSize: 13),),
                                                        size: ColumnSize.M
                                                    ),
                                                    DataColumn2(
                                                        label: Center(child: Text('Shift', style: TextStyle(fontSize: 13),)),
                                                        fixedWidth: 100
                                                    ),
                                                    DataColumn2(
                                                        label: Center(child: Text('Cycle', style: TextStyle(fontSize: 13),)),
                                                        fixedWidth: 100
                                                    ),
                                                    DataColumn2(
                                                        label: Center(child: Text('Duration', style: TextStyle(fontSize: 13),)),
                                                        fixedWidth: 100
                                                    ),
                                                    DataColumn2(
                                                        label: Center(child: Text('Valve', style: TextStyle(fontSize: 13),)),
                                                        fixedWidth: 100
                                                    ),
                                                    DataColumn2(
                                                        label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
                                                        fixedWidth: 110
                                                    ),
                                                  ],
                                                  rows: List<DataRow>.generate(1, (index) => DataRow(cells: [
                                                    DataCell(Text('Manual')),
                                                    DataCell(Center(child: Text('---'))),
                                                    DataCell(Center(child: Text('---'))),
                                                    DataCell(Center(child: Text('---'))),
                                                    DataCell(Center(child: Text('----'))),
                                                    DataCell(Center(child: Row(
                                                      children: [
                                                        IconButton(tooltip:'Pause',onPressed: (){}, icon: Icon(Icons.pause_circle_outline_sharp)),
                                                        IconButton(tooltip:'Stop',onPressed: (){
                                                          String payload = '${programList[index].serialNumber}, 0';
                                                          String payLoadFinal = jsonEncode({
                                                            "2900": [{"2901": payload}]
                                                          });
                                                          MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                                        }, icon: Icon(Icons.stop_circle_outlined, color: Colors.red,)),
                                                        PopupMenuButton<String>(
                                                          tooltip: 'Show more option',
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              value: 'Replay 30 sec',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.replay_30), // Leading icon
                                                                  SizedBox(width: 8), // Padding between icon and text
                                                                  Text('Replay 30 sec'), // Menu item text
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'Forward 30 sec',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.forward_30), // Leading icon
                                                                  SizedBox(width: 8), // Padding between icon and text
                                                                  Text('Forward 30 sec'), // Menu item text
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'Skip',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.skip_next_outlined), // Leading icon
                                                                  SizedBox(width: 8), // Padding between icon and text
                                                                  Text('Skip'), // Menu item text
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                          onSelected: (value) {
                                                            // Handle the selection here
                                                            print('Selected: $value');
                                                          },
                                                          child: Icon(Icons.more_vert),
                                                        ),
                                                      ],
                                                    ))),
                                                  ])),
                                                ),
                                              );
                                            }) :
                                        const Center(child: Text('Next Schedule not Available')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 0),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      const ListTile(
                                        tileColor: Colors.white,
                                        title: Text('UPCOMING PROGRAM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                      const Divider(height: 0),
                                      SizedBox(
                                        height: programList.isNotEmpty? (programList.length * 50) + 35 : 50,
                                        child: programList.isNotEmpty? DataTable2(
                                          columnSpacing: 12,
                                          horizontalMargin: 12,
                                          minWidth: 600,
                                          dataRowHeight: 45.0,
                                          headingRowHeight: 35.0,
                                          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                                          columns: const [
                                            DataColumn2(
                                                label: Text('Name', style: TextStyle(fontSize: 13),),
                                                fixedWidth: 110
                                            ),
                                            DataColumn2(
                                                label: Text('Category', style: TextStyle(fontSize: 13),),
                                                size: ColumnSize.M
                                            ),
                                            DataColumn2(
                                                label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                                                fixedWidth: 50
                                            ),
                                            DataColumn2(
                                                label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                                                fixedWidth: 100
                                            ),
                                            DataColumn2(
                                                label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                                                fixedWidth: 80
                                            ),
                                            DataColumn2(
                                                label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
                                                fixedWidth: 87
                                            ),
                                          ],
                                          rows: List<DataRow>.generate(programList.length, (index) => DataRow(cells: [
                                            DataCell(Text(programList[index].programName)),
                                            DataCell(Text(programList[index].programName == 'Default'? '----' : programList[index].scheduleType)),
                                            DataCell(Center(child: Text('${programList[index].sequenceCount}'))),
                                            DataCell(Center(child: Text(programList[index].programName == 'Default'? '----':programList[index].startDate.split(' ').first))),
                                            DataCell(Center(child: Text(programList[index].programName == 'Default'? '----': programList[index].startTime))),
                                            DataCell(Center(child: Row(
                                              children: [
                                                IconButton(tooltip:'Start',onPressed: (){
                                                  String payload = '${programList[index].serialNumber},1';
                                                  String payLoadFinal = jsonEncode({
                                                    "2900": [{"2901": payload}]
                                                  });
                                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                                }, icon: const Icon(Icons.start, color: Colors.green,)),
                                                IconButton(tooltip:'Stop',onPressed: (){
                                                  String payload = '${programList[index].serialNumber}, 0';
                                                  String payLoadFinal = jsonEncode({
                                                    "2900": [{"2901": payload}]
                                                  });
                                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                                }, icon: const Icon(Icons.stop_circle_outlined, color: Colors.red)),
                                              ],
                                            ))),
                                          ])),
                                        ) :
                                        const Center(child: Text('Upcoming Program not Available')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 5,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // make it circular
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: 345,
                        height: widget.siteLength > 1? MediaQuery.sizeOf(context).height-197 : MediaQuery.sizeOf(context).height-145,
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 5),
                                              CircleAvatar(radius: 5, backgroundColor: Colors.green,),
                                              SizedBox(width: 5),
                                              Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 5),
                                              CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                                              SizedBox(width: 5),
                                              Text('No Communication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 10),
                                              CircleAvatar(radius: 5, backgroundColor: Colors.redAccent,),
                                              SizedBox(width: 5),
                                              Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 10),
                                              CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                                              SizedBox(width: 5),
                                              Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 40,
                                        child: IconButton(tooltip:'View all Node details', onPressed: (){
                                          showNodeDetailsBottomSheet(context);
                                        }, icon: const Icon(Icons.format_list_bulleted_outlined)),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: IconButton(
                                          tooltip: 'Set serial for all Nodes',
                                          icon: const Icon(Icons.format_list_numbered),
                                          onPressed: () async {
                                            String payLoadFinal = jsonEncode({
                                              "2300": [
                                                {"2301": ""},
                                              ]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: DataTable2(
                                columnSpacing: 12,
                                horizontalMargin: 12,
                                minWidth: 325,
                                dataRowHeight: 40.0,
                                headingRowHeight: 35.0,
                                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                                columns: const [
                                  DataColumn2(
                                      label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),)),
                                      fixedWidth: 35
                                  ),
                                  DataColumn2(
                                    label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),)),
                                    fixedWidth: 55,
                                  ),
                                  DataColumn2(
                                    label: Center(child: Text('Rf.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),)),
                                    fixedWidth: 45,
                                  ),
                                  DataColumn2(
                                    label: Text('Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),),
                                    size: ColumnSize.M,
                                    numeric: true,
                                  ),
                                  DataColumn2(
                                    label: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),),
                                    fixedWidth: 40,
                                  ),
                                ],
                                rows: List<DataRow>.generate(widget.siteData.nodeList.length, (index) => DataRow(cells: [
                                  DataCell(Center(child: Text('${widget.siteData.nodeList[index].serialNumber}', style: const TextStyle(fontWeight: FontWeight.normal),))),
                                  DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                                  widget.siteData.nodeList[index].status == 1 ? Colors.green.shade400:
                                  widget.siteData.nodeList[index].status == 3 ? Colors.red.shade400:
                                  widget.siteData.nodeList[index].status == 2 ? Colors.grey :
                                  widget.siteData.nodeList[index].status == 4 ? Colors.yellow :
                                  Colors.grey,
                                  ))),
                                  DataCell(Center(child: Text('${widget.siteData.nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal)))),
                                  DataCell(Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(widget.siteData.nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.normal)),
                                      Text(widget.siteData.nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11)),
                                    ],
                                  )),
                                  DataCell(Center(child: IconButton(tooltip: 'View Relay status',
                                    icon: const Icon(Icons.receipt_long), // Icon to display
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            height: widget.siteData.nodeList[index].rlyStatus.length > 8? 275 : 200,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  tileColor: myTheme.primaryColor,
                                                  textColor: Colors.white,
                                                  leading: const Icon(Icons.developer_board_rounded, color: Colors.white),
                                                  title: Text('${widget.siteData.nodeList[index].categoryName} - ${widget.siteData.nodeList[index].deviceId}'),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.solar_power_outlined, color: Colors.white),
                                                      const SizedBox(width: 5,),
                                                      Text('${widget.siteData.nodeList[index].slrVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      const SizedBox(width: 5,),
                                                      const Icon(Icons.battery_3_bar_rounded, color: Colors.white),
                                                      const SizedBox(width: 5,),
                                                      Text('${widget.siteData.nodeList[index].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                      const SizedBox(width: 5,),
                                                      IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                                        String payLoadFinal = jsonEncode({
                                                          "2300": [
                                                            {"2301": "${widget.siteData.nodeList[index].serialNumber}"},
                                                          ]
                                                        });
                                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                                      }, icon: Icon(Icons.fact_check_outlined, color: Colors.white))
                                                    ],
                                                  ),
                                                ),
                                                const Divider(height: 0),
                                                SizedBox(
                                                  width : double.infinity,
                                                  height : widget.siteData.nodeList[index].rlyStatus.length > 8? 206 : 130,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: widget.siteData.nodeList[index].rlyStatus.isNotEmpty ? Column(
                                                      children: [
                                                        const SizedBox(
                                                          width: double.infinity,
                                                          height : 40,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: 10),
                                                              CircleAvatar(radius: 5,backgroundColor: Colors.green,),
                                                              SizedBox(width: 5),
                                                              Text('ON'),
                                                              SizedBox(width: 20),
                                                              CircleAvatar(radius: 5,backgroundColor: Colors.black45),
                                                              SizedBox(width: 5),
                                                              Text('OFF'),
                                                              SizedBox(width: 20),
                                                              CircleAvatar(radius: 5,backgroundColor: Colors.orange),
                                                              SizedBox(width: 5),
                                                              Text('ON IN OFF'),
                                                              SizedBox(width: 20),
                                                              CircleAvatar(radius: 5,backgroundColor: Colors.redAccent),
                                                              SizedBox(width: 5),
                                                              Text('OFF IN ON'),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: double.infinity,
                                                          height : widget.siteData.nodeList[index].rlyStatus.length > 8? 150 : 70,
                                                          child: GridView.builder(
                                                            itemCount: widget.siteData.nodeList[index].rlyStatus.length, // Number of items in the grid
                                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 8,
                                                              crossAxisSpacing: 10.0,
                                                              mainAxisSpacing: 10.0,
                                                            ),
                                                            itemBuilder: (BuildContext context, int indexGv) {
                                                              return Column(
                                                                children: [
                                                                  CircleAvatar(
                                                                    backgroundColor: widget.siteData.nodeList[index].rlyStatus[indexGv].status==0 ? Colors.grey :
                                                                    widget.siteData.nodeList[index].rlyStatus[indexGv].status==1 ? Colors.green :
                                                                    widget.siteData.nodeList[index].rlyStatus[indexGv].status==2 ? Colors.orange :
                                                                    widget.siteData.nodeList[index].rlyStatus[indexGv].status==3 ? Colors.redAccent : Colors.black12, // Avatar background color
                                                                    child: Text((widget.siteData.nodeList[index].rlyStatus[indexGv].rlyNo).toString(), style: const TextStyle(color: Colors.white)),
                                                                  ),
                                                                  Text((widget.siteData.nodeList[index].rlyStatus[indexGv].name).toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ) :
                                                    const Center(child: Text('Relay Status Not Found')),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ))),
                                ])),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initRotationAnimation(){
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String getCurrentDate() {
    var now = DateTime.now();
    return DateFormat('MMMM dd, yyyy').format(now);
  }

  String getCurrentTime() {
    var now = DateTime.now();
    return DateFormat('hh:mm:ss').format(now);
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


  Future<void>showNodeDetailsBottomSheet(BuildContext context) async{
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return  SizedBox(
          height: 600,
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(),
                surfaceTintColor: Colors.white,
                margin: EdgeInsets.zero,
                child: ListTile(
                  tileColor: myTheme.primaryColor,
                  textColor: Colors.white,
                  title: const Text('Node Details'),
                ),
              ),
              const SizedBox(
                height: 40,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        CircleAvatar(radius: 5,backgroundColor: Colors.green,),
                        SizedBox(width: 5),
                        Text('On - Status : Normal.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                        SizedBox(width: 25),
                        CircleAvatar(radius: 5,backgroundColor: Colors.orange),
                        SizedBox(width: 5),
                        Text('Comment Executed to On but still is off', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        CircleAvatar(radius: 5,backgroundColor: Colors.black45),
                        SizedBox(width: 5),
                        Text('Off - Status : Normal.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                        SizedBox(width: 25),
                        CircleAvatar(radius: 5,backgroundColor: Colors.redAccent),
                        SizedBox(width: 5),
                        Text('Comment Executed to Off but still is on', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: [
                    for (int i = 0; i < widget.siteData.nodeList.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            shape: const RoundedRectangleBorder(),
                            surfaceTintColor: Colors.white,
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              tileColor: myTheme.primaryColor.withOpacity(0.1),
                              title: Text('${widget.siteData.nodeList[i].categoryName} - ${widget.siteData.nodeList[i].deviceId}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.solar_power_outlined),
                                  const SizedBox(width: 5,),
                                  Text('${widget.siteData.nodeList[i].slrVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                  const SizedBox(width: 5,),
                                  const Icon(Icons.battery_3_bar_rounded),
                                  Text('${widget.siteData.nodeList[i].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                  const SizedBox(width: 5,),
                                  IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                    String payLoadFinal = jsonEncode({
                                      "2300": [
                                        {"2301": "${widget.siteData.nodeList[i].serialNumber}"},
                                      ]
                                    });
                                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                                  }, icon: Icon(Icons.fact_check_outlined))
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.siteData.nodeList[i].rlyStatus.length,
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 5,
                                          backgroundColor: widget.siteData.nodeList[i].rlyStatus[index].status==0 ? Colors.grey :
                                          widget.siteData.nodeList[i].rlyStatus[index].status==1 ? Colors.green :
                                          widget.siteData.nodeList[i].rlyStatus[index].status==2 ? Colors.orange :
                                          widget.siteData.nodeList[i].rlyStatus[index].status==3 ? Colors.redAccent : Colors.black12,
                                        ),
                                        const SizedBox(width: 3),
                                        Text('${widget.siteData.nodeList[i].rlyStatus[index].name}(${widget.siteData.nodeList[i].rlyStatus[index].rlyNo})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

}