import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/DashboardByManual.dart';
import 'Dashboard/DashboardByProgram.dart';
import 'Dashboard/FarmSettings.dart';
import 'ProgramSchedule.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.type, required this.customerName, required this.userID}) : super(key: key);
  final int userID, customerID, type;
  final String customerName;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
{
  List<DashboardModel> siteList = [];
  int siteIndex = 0;

  List<ProgramList> programList =[];
  bool visibleLoading = false;
  int wifiStrength = 0;
  final double _progressValue = 0.35;


  @override
  void initState() {
    super.initState();
    indicatorViewShow();
    getCustomerSite();
  }


  Future<void> getCustomerSite() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      siteList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        //print(cntList);
        try {
          siteList = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          getProgramList(siteList[siteIndex].controllerId ?? 0);
          MQTTManager().subscribeToTopic('FirmwareToApp/${siteList[siteIndex].deviceId}');
        } catch (e) {
          print('Error: $e');
        }

        indicatorViewHide();
      }
      setState(() {
        siteList;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getProgramList(int controllerId) async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> programsJson = jsonResponse['data'];
        setState(() {
          programList = [
            ...programsJson.map((programJson) => ProgramList.fromJson(programJson)).toList(),
          ];
        });
        indicatorViewHide();
      }
    } catch (e) {
      print('Error: $e');
    }

  }


  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MqttPayloadProvider>(context, listen: true);
    wifiStrength = provider.receivedWifiStrength;
    List<dynamic> list2401 = provider.receivedNodeStatus;
    for (var item in list2401) {
      Map<String, dynamic> entry = item as Map<String, dynamic>;
      setState(() {
        try{
          //siteList[siteIndex].nodeList[int.parse(entry['SNo'])-1].nodeStatus.Status = entry['Status'];
        }catch(e){
          print(e);
        }
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if(widget.type==0){
      return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
      DefaultTabController(
        length: siteList.length, // Set the number of tabs
        child: Scaffold(
          appBar: buildAppBar('DASHBOARD', context),
          body: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: siteList.length,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                                isScrollable: true,
                                tabs: [
                                  for (var i = 0; i < siteList.length; i++)
                                    Tab(text: siteList[i].siteName ?? '',),
                                ],
                                onTap: (index) {
                                  getProgramList(siteList[index].controllerId ?? 0 );
                                  siteIndex = index;
                                },
                              ),
                            ),
                            IconButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  FarmSettings(siteID: siteList[siteIndex].siteId, siteName: siteList[siteIndex].siteName, controllerID: siteList[siteIndex].controllerId, customerID: widget.customerID, imeiNo: siteList[siteIndex].deviceId, userId: widget.userID,)),);
                            }, icon: const Icon(Icons.settings_outlined),),
                            const SizedBox(width: 10,),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height-105,
                          child: TabBarView(
                            children: [
                              for (int i = 0; i < siteList.length; i++)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 50,
                                                    backgroundImage: AssetImage('assets/images/oro_gem.png'),
                                                    backgroundColor: Colors.transparent,
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Text(siteList[i].deviceName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  SizedBox(
                                                    height: 43,
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Icon(wifiStrength == 0 ? Icons.wifi_off:
                                                            wifiStrength > 1 && wifiStrength < 20 ? Icons.wifi_1_bar:
                                                            wifiStrength > 20 && wifiStrength < 50 ? Icons.wifi_2_bar : Icons.wifi),
                                                            Text('$wifiStrength %', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                          ],
                                                        ),
                                                        const SizedBox(width: 20,),
                                                        const Column(
                                                          children: [
                                                            Icon(Icons.battery_3_bar_rounded),
                                                            Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5, bottom: 5),
                                            child: VerticalDivider(),
                                          ),
                                          Flexible(
                                            flex :1,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 0),
                                    SizedBox(
                                      height: MediaQuery.sizeOf(context).height-305,
                                      width: MediaQuery.sizeOf(context).width-550,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Divider(height: 0,),
                                          SizedBox(
                                            height: MediaQuery.sizeOf(context).height-305,
                                            width: MediaQuery.sizeOf(context).width-550,
                                            child: programList.isNotEmpty? ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                itemCount: programList.length,
                                                itemBuilder: (context, pIdx) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 5, top: 5),
                                                    child: InkWell(
                                                      child: Container(
                                                        height: 105,
                                                        decoration: BoxDecoration(
                                                          color: myTheme.primaryColor.withOpacity(0.1),
                                                          border: Border.all(
                                                            color: Colors.black12, // Set the border color
                                                            width: 1.0,         // Set the border width
                                                          ),
                                                          borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 4),
                                                              child: Row(
                                                                children: [
                                                                  Text(programList[pIdx].programName),
                                                                  const Expanded(child: Text('')),
                                                                  SizedBox(width: 100,
                                                                    child: LinearProgressIndicator(
                                                                      backgroundColor: myTheme.primaryColor.withOpacity(0.3),
                                                                      color: myTheme.primaryColor,
                                                                      minHeight: 5,
                                                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                      value: _progressValue, // Update this value to reflect loading progress
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 5),
                                                                  const Text('35%'),
                                                                  const SizedBox(width: 10),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 75,
                                                              child: DataTable2(
                                                                columnSpacing: 12,
                                                                horizontalMargin: 12,
                                                                minWidth: 550,
                                                                dataRowHeight: 40.0,
                                                                headingRowHeight: 35.0,
                                                                //headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                                                                border: TableBorder.all(color: Colors.black12),
                                                                columns: const [
                                                                  DataColumn2(
                                                                      label: Text('Name', style: TextStyle(fontSize: 13),),
                                                                      size: ColumnSize.M
                                                                  ),
                                                                  DataColumn2(
                                                                      label: Center(child: Text('Schedule', style: TextStyle(fontSize: 13),)),
                                                                      fixedWidth: 100
                                                                  ),
                                                                  DataColumn2(
                                                                      label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                                                                      fixedWidth: 100
                                                                  ),
                                                                  DataColumn2(
                                                                      label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                                                                      fixedWidth: 100
                                                                  ),
                                                                  DataColumn2(
                                                                      label: Center(child: Text('Duration', style: TextStyle(fontSize: 13),)),
                                                                      fixedWidth: 100
                                                                  ),
                                                                ],
                                                                rows: List<DataRow>.generate(1, (index) => DataRow(cells: [
                                                                  DataCell(Text(programList[pIdx].firstSequence)),
                                                                  DataCell(Center(child: Text('1/${programList[pIdx].sequenceCount}'))),
                                                                  DataCell(Center(child: programList[pIdx].scheduleType == 'NO SCHEDULE' ? const Text('---') :
                                                                  Text(programList[pIdx].startDate.split(' ').first))),
                                                                  DataCell(Center(child: Text(programList[pIdx].startTime))),
                                                                  DataCell(Center(child: Text(programList[pIdx].duration))),
                                                                ])),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: siteList[i].siteId, siteName: siteList[i].siteName, controllerID: siteList[i].controllerId, customerID: widget.customerID, imeiNo: siteList[i].deviceId, programId: programList[pIdx].programId,)),);
                                                      },
                                                    ),
                                                  );
                                                }) :
                                            const Center(child: Text('Program Not found')),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(),
                SizedBox(
                  width: 325,
                  height: MediaQuery.sizeOf(context).height,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade200,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    height: 30,
                                    width: 100,
                                    child: const Center(child: Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      height: 30,
                                      width: 85,
                                      child: const Center(child: Text('Disabled', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      height: 30,
                                      width: 65,
                                      child: const Center(child: Text('Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      height: 30,
                                      width: 60,
                                      child: const Center(child: Text('OK', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 325,
                        height: MediaQuery.sizeOf(context).height-110,
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 325,
                          dataRowHeight: 35.0,
                          headingRowHeight: 30.0,
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
                          rows: List<DataRow>.generate(siteList[siteIndex].nodeList.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal),))),
                            DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                              siteList[siteIndex].nodeList[index].Status == 1 ? Colors.green.shade400:
                              siteList[siteIndex].nodeList[index].Status == 2 ? Colors.red.shade400:
                              siteList[siteIndex].nodeList[index].Status == 3 ? Colors.grey:
                              Colors.yellow,
                            ))),
                            DataCell(Center(child: Text('${siteList[siteIndex].nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal)))),
                            DataCell(Text(siteList[siteIndex].nodeList[index].categoryName, style: TextStyle(fontWeight: FontWeight.normal)),),
                            DataCell(Center(child: PopupMenuButton(
                              icon: Icon(Icons.info_outline, color: myTheme.primaryColor),
                              tooltip: 'View details',
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(siteList[siteIndex].nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                        const Divider(),
                                        Text('Battery voltage : ${siteList[siteIndex].nodeList[index].BatVolt}'),
                                        Text('Solar voltage : ${siteList[siteIndex].nodeList[index].SVolt}'),
                                        Text('Sensor : ${siteList[siteIndex].nodeList[index].Sensor}'),
                                        Text('Relay Status : ${siteList[siteIndex].nodeList[index].RlyStatus}'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ))),
                          ])),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
    DefaultTabController(
      length: siteList.length, // Set the number of tabs
      child: Scaffold(
        appBar: buildAppBar('${widget.customerName} - DASHBOARD', context),
        body: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              Expanded(
                child: DefaultTabController(
                  length: siteList.length,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TabBar(
                              indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                              isScrollable: true,
                              tabs: [
                                for (var i = 0; i < siteList.length; i++)
                                  Tab(text: siteList[i].siteName ?? '',),
                              ],
                              onTap: (index) {
                                getProgramList(siteList[index].controllerId ?? 0 );
                                siteIndex = index;
                              },
                            ),
                          ),
                          IconButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  FarmSettings(siteID: siteList[siteIndex].siteId, siteName: siteList[siteIndex].siteName, controllerID: siteList[siteIndex].controllerId, customerID: widget.customerID, imeiNo: siteList[siteIndex].deviceId, userId: widget.userID,)),);
                          }, icon: const Icon(Icons.settings_outlined),),
                          const SizedBox(width: 10,),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height-105,
                        child: TabBarView(
                          children: [
                            for (int i = 0; i < siteList.length; i++)
                              Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage: AssetImage('assets/images/oro_gem.png'),
                                                  backgroundColor: Colors.transparent,
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(siteList[i].deviceName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                SizedBox(
                                                  height: 43,
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Icon(wifiStrength == 0 ? Icons.wifi_off:
                                                          wifiStrength > 1 && wifiStrength < 20 ? Icons.wifi_1_bar:
                                                          wifiStrength > 20 && wifiStrength < 50 ? Icons.wifi_2_bar : Icons.wifi),
                                                          Text('$wifiStrength %', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 20,),
                                                      const Column(
                                                        children: [
                                                          Icon(Icons.battery_3_bar_rounded),
                                                          Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          child: VerticalDivider(),
                                        ),
                                        Flexible(
                                          flex :1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 0),
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height-305,
                                    width: MediaQuery.sizeOf(context).width-550,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Divider(height: 0,),
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context).height-305,
                                          width: MediaQuery.sizeOf(context).width-550,
                                          child: programList.isNotEmpty? ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: programList.length,
                                              itemBuilder: (context, pIdx) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 5, top: 5),
                                                  child: InkWell(
                                                    child: Container(
                                                      height: 105,
                                                      decoration: BoxDecoration(
                                                        color: myTheme.primaryColor.withOpacity(0.1),
                                                        border: Border.all(
                                                          color: Colors.black12, // Set the border color
                                                          width: 1.0,         // Set the border width
                                                        ),
                                                        borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 4),
                                                            child: Row(
                                                              children: [
                                                                Text(programList[pIdx].programName),
                                                                const Expanded(child: Text('')),
                                                                SizedBox(width: 100,
                                                                  child: LinearProgressIndicator(
                                                                    backgroundColor: myTheme.primaryColor.withOpacity(0.3),
                                                                    color: myTheme.primaryColor,
                                                                    minHeight: 5,
                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                    value: _progressValue, // Update this value to reflect loading progress
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 5),
                                                                const Text('35%'),
                                                                const SizedBox(width: 10),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 75,
                                                            child: DataTable2(
                                                              columnSpacing: 12,
                                                              horizontalMargin: 12,
                                                              minWidth: 550,
                                                              dataRowHeight: 40.0,
                                                              headingRowHeight: 35.0,
                                                              //headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                                                              border: TableBorder.all(color: Colors.black12),
                                                              columns: const [
                                                                DataColumn2(
                                                                    label: Text('Name', style: TextStyle(fontSize: 13),),
                                                                    size: ColumnSize.M
                                                                ),
                                                                DataColumn2(
                                                                    label: Center(child: Text('Schedule', style: TextStyle(fontSize: 13),)),
                                                                    fixedWidth: 100
                                                                ),
                                                                DataColumn2(
                                                                    label: Center(child: Text('Start Date', style: TextStyle(fontSize: 13),)),
                                                                    fixedWidth: 100
                                                                ),
                                                                DataColumn2(
                                                                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                                                                    fixedWidth: 100
                                                                ),
                                                                DataColumn2(
                                                                    label: Center(child: Text('Duration', style: TextStyle(fontSize: 13),)),
                                                                    fixedWidth: 100
                                                                ),
                                                              ],
                                                              rows: List<DataRow>.generate(1, (index) => DataRow(cells: [
                                                                DataCell(Text(programList[pIdx].firstSequence)),
                                                                DataCell(Center(child: Text('1/${programList[pIdx].sequenceCount}'))),
                                                                DataCell(Center(child: programList[pIdx].scheduleType == 'NO SCHEDULE' ? const Text('---') :
                                                                Text(programList[pIdx].startDate.split(' ').first))),
                                                                DataCell(Center(child: Text(programList[pIdx].startTime))),
                                                                DataCell(Center(child: Text(programList[pIdx].duration))),
                                                              ])),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: (){
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: siteList[i].siteId, siteName: siteList[i].siteName, controllerID: siteList[i].controllerId, customerID: widget.customerID, imeiNo: siteList[i].deviceId, programId: programList[pIdx].programId,)),);
                                                    },
                                                  ),
                                                );
                                              }) :
                                          const Center(child: Text('Program Not found')),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(),
              SizedBox(
                width: 325,
                height: MediaQuery.sizeOf(context).height,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade200,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  height: 30,
                                  width: 100,
                                  child: const Center(child: Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    height: 30,
                                    width: 85,
                                    child: const Center(child: Text('Disabled', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    height: 30,
                                    width: 65,
                                    child: const Center(child: Text('Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    height: 30,
                                    width: 60,
                                    child: const Center(child: Text('OK', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 325,
                      height: MediaQuery.sizeOf(context).height-110,
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 325,
                        dataRowHeight: 35.0,
                        headingRowHeight: 30.0,
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
                        rows: List<DataRow>.generate(siteList[siteIndex].nodeList.length, (index) => DataRow(cells: [
                          DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal),))),
                          DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                          siteList[siteIndex].nodeList[index].Status == 1 ? Colors.green.shade400:
                          siteList[siteIndex].nodeList[index].Status == 2 ? Colors.red.shade400:
                          siteList[siteIndex].nodeList[index].Status == 3 ? Colors.grey:
                          Colors.yellow,
                          ))),
                          DataCell(Center(child: Text('${siteList[siteIndex].nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal)))),
                          DataCell(Text(siteList[siteIndex].nodeList[index].categoryName, style: TextStyle(fontWeight: FontWeight.normal)),),
                          DataCell(Center(child: PopupMenuButton(
                            icon: Icon(Icons.info_outline, color: myTheme.primaryColor),
                            tooltip: 'View details',
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(siteList[siteIndex].nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                      const Divider(),
                                      Text('Battery voltage : ${siteList[siteIndex].nodeList[index].BatVolt}'),
                                      Text('Solar voltage : ${siteList[siteIndex].nodeList[index].SVolt}'),
                                      Text('Sensor : ${siteList[siteIndex].nodeList[index].Sensor}'),
                                      Text('Relay Status : ${siteList[siteIndex].nodeList[index].RlyStatus}'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ))),
                        ])),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }

  AppBar buildAppBar(String title, BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: myTheme.primaryColor,
      actions: [
        IconButton(
          tooltip: 'Set serial for all Nodes',
          icon: const Icon(Icons.format_list_numbered),
          onPressed: () async {
            String payLoadFinal = jsonEncode({
              "2300": [
                {"2301": ""},
              ]
            });
             MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteList[siteIndex].deviceId}');
          },
        ),
        const SizedBox(width: 5,),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            // getControllerDashboardDetails(0, ddSelection);
          },
        ),
        const SizedBox(width: 5,),
        IconButton(
          tooltip: 'Manual Mode',
          icon: const Icon(Icons.touch_app_outlined),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardByManual(
                  siteID: siteList[siteIndex].siteId,
                  siteName: siteList[siteIndex].siteName,
                  controllerID: siteList[siteIndex].controllerId,
                  customerID: widget.customerID,
                  imeiNo: siteList[siteIndex].deviceId,
                  programList: programList,
                ),
              ),
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
                  controllerID: siteList[siteIndex].controllerId,
                  siteName: siteList[siteIndex].siteName,
                  imeiNumber: siteList[siteIndex].deviceId,
                  userId: widget.customerID,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10,),
      ],
    );
  }

  void indicatorViewShow() {
    setState((){
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

}

class Person {
  String name;
  int age;
  Person(this.name, this.age);
  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age};
  }
}