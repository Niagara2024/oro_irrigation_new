import 'dart:async';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/NextSchedule.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/UpcomingProgram.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/CurrentSchedule.dart';
import 'Dashboard/MainLine.dart';
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
    Future.delayed(const Duration(milliseconds: 1000), () {
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
        //print(response.body);
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
          lastSyncData = getCurrentDateAndTime();
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
                                child: MainLine(siteData: widget.siteData),
                              ),
                              SizedBox(
                                child: CurrentSchedule(siteData: widget.siteData),
                              ),
                              SizedBox(
                                child: NextSchedule(siteData: widget.siteData, userID: widget.userID, customerID: widget.customerID),
                              ),
                              SizedBox(
                                child: UpcomingProgram(siteData: widget.siteData),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Container(
                          width: 345,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [myTheme.primaryColor, myTheme.primaryColorDark],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Image.asset('assets/images/oro_gem.png'),
                                    ),
                                  ),
                                  Expanded(child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.siteData.deviceName, style: const TextStyle(color: Colors.white,fontSize: 12)),
                                      Text('${widget.siteData.categoryName} - Last sync : $lastSyncData', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10, color: Colors.white,),),
                                    ],
                                  ))
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: myTheme.primaryColorDark
                                    ),
                                    width: 45,
                                    height: 45,
                                    child: IconButton(
                                      tooltip: '$wifiStrength %',
                                      icon: Icon(wifiStrength == 0? Icons.wifi_off:
                                      wifiStrength >= 1 && wifiStrength <= 20 ? Icons.network_wifi_1_bar_outlined:
                                      wifiStrength >= 21 && wifiStrength <= 40 ? Icons.network_wifi_2_bar_outlined:
                                      wifiStrength >= 41 && wifiStrength <= 60 ? Icons.network_wifi_3_bar_outlined:
                                      wifiStrength >= 61 && wifiStrength <= 80 ? Icons.network_wifi_outlined:
                                      Icons.wifi, color: Colors.white,),
                                      onPressed: null,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: myTheme.primaryColorDark
                                    ),
                                    width: 45,
                                    height: 45,
                                    child: RotationTransition(
                                      turns: rotationAnimation,
                                      child: IconButton(
                                        tooltip: 'refresh',
                                        icon: const Icon(Icons.refresh, color: Colors.white,),
                                        onPressed: onRefreshClicked,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: myTheme.primaryColorDark
                                    ),
                                    width: 45,
                                    height: 45,
                                    child: IconButton(tooltip:'View all Node details', onPressed: (){
                                      showNodeDetailsBottomSheet(context);
                                    }, icon: const Icon(Icons.grid_view, color: Colors.white)),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: myTheme.primaryColorDark
                                    ),
                                    width: 45,
                                    height: 45,
                                    child: IconButton(
                                      tooltip: 'Manual Mode',
                                      icon: const Icon(Icons.touch_app_outlined, color: Colors.white,),
                                      onPressed: () async {
                                        /*showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return RunByManual(siteID: widget.siteData.siteId,
                                                siteName: widget.siteData.siteName,
                                                controllerID: widget.siteData.controllerId,
                                                customerID: widget.customerID,
                                                imeiNo: widget.siteData.deviceId,
                                                programList: programList, callbackFunction: callbackFunction);
                                          },
                                        );*/

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RunByManual(siteID: widget.siteData.siteId,
                                                siteName: widget.siteData.siteName,
                                                controllerID: widget.siteData.controllerId,
                                                customerID: widget.customerID,
                                                imeiNo: widget.siteData.deviceId,
                                                programList: programList, callbackFunction: callbackFunction),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: myTheme.primaryColorDark
                                    ),
                                    width: 45,
                                    height: 45,
                                    child: IconButton(
                                      tooltip: 'Planning',
                                      icon: const Icon(Icons.list_alt, color: Colors.white,),
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
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          width: 345,
                          height: widget.siteLength > 1? MediaQuery.sizeOf(context).height-234 : MediaQuery.sizeOf(context).height-186,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [myTheme.primaryColor, myTheme.primaryColorDark],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(width: 5),
                                                CircleAvatar(radius: 5, backgroundColor: Colors.green,),
                                                SizedBox(width: 5),
                                                Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white))
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 5),
                                                CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                                                SizedBox(width: 5),
                                                Text('No Communication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white))
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(width: 10),
                                                CircleAvatar(radius: 5, backgroundColor: Colors.redAccent,),
                                                SizedBox(width: 5),
                                                Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white))
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 10),
                                                CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                                                SizedBox(width: 5),
                                                Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white))
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                            tooltip: 'Set serial for all Nodes',
                                            icon: const Icon(Icons.format_list_numbered, color: Colors.white),
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
                                  headingRowColor: MaterialStateProperty.all<Color>(primaryColorLight.withOpacity(0.3)),
                                  columns: const [
                                    DataColumn2(
                                        label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.white),)),
                                        fixedWidth: 35
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.white),)),
                                      fixedWidth: 55,
                                    ),
                                    DataColumn2(
                                      label: Center(child: Text('Rf.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.white),)),
                                      fixedWidth: 45,
                                    ),
                                    DataColumn2(
                                      label: Text('Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.white),),
                                      size: ColumnSize.M,
                                      numeric: true,
                                    ),
                                    DataColumn2(
                                      label: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.white),),
                                      fixedWidth: 40,
                                    ),
                                  ],
                                  rows: List<DataRow>.generate(widget.siteData.nodeList.length, (index) => DataRow(cells: [
                                    DataCell(Center(child: Text('${widget.siteData.nodeList[index].serialNumber}', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white),))),
                                    DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                                    widget.siteData.nodeList[index].status == 1 ? Colors.green.shade400:
                                    widget.siteData.nodeList[index].status == 2 ? Colors.grey :
                                    widget.siteData.nodeList[index].status == 3 ? Colors.redAccent :
                                    widget.siteData.nodeList[index].status == 4 ? Colors.yellow :
                                    Colors.grey,
                                    ))),
                                    DataCell(Center(child: Text('${widget.siteData.nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white)))),
                                    DataCell(Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(widget.siteData.nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
                                        Text(widget.siteData.nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.white)),
                                      ],
                                    )),
                                    DataCell(Center(child: IconButton(tooltip: 'View Relay status',
                                      icon: widget.siteData.nodeList[index].rlyStatus.any((rly) => rly.status == 2 || rly.status == 3)? const Icon(Icons.warning, color: Colors.orangeAccent):
                                      const Icon(Icons.info_outline, color: Colors.white), // Icon to display
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
                      ],
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

  String getCurrentDateAndTime() {
    var nowDT = DateTime.now();
    return '${DateFormat('MMMM dd, yyyy').format(nowDT)}-${DateFormat('hh:mm:ss').format(nowDT)}';
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
                                  }, icon: const Icon(Icons.fact_check_outlined))
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: widget.siteData.nodeList[i].rlyStatus.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: widget.siteData.nodeList[i].rlyStatus[index].name.contains("VL") ? const AssetImage('assets/images/valve.png') : const AssetImage('assets/images/irrigation_pump.png'),
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
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: widget.siteData.nodeList[i].sensor.length,
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
                                              backgroundColor: widget.siteData.nodeList[i].sensor[index].status==0 ? Colors.grey :
                                              widget.siteData.nodeList[i].sensor[index].status==1 ? Colors.green :
                                              widget.siteData.nodeList[i].sensor[index].status==2 ? Colors.orange :
                                              widget.siteData.nodeList[i].sensor[index].status==3 ? Colors.redAccent : Colors.black12,
                                            ),
                                            const SizedBox(width: 3),
                                            Text('${widget.siteData.nodeList[i].rlyStatus[index].name}(${widget.siteData.nodeList[i].rlyStatus[index].rlyNo})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                )
                              ],
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
