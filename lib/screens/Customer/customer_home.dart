import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/MqttPayloadModel.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../Models/CustomerSite.dart';
import '../../Models/node_model.dart';
import '../../constants/http_service.dart';
import '../../constants/mqtt_web_client.dart';
import '../../constants/theme.dart';
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
  List<CustomerSite> customerSiteList = <CustomerSite>[];
  List<List<DashboardNode>> usedNodeList = <List<DashboardNode>>[];
  List<ProgramList> programList =[];
  int selectedTabIndex = 0;
  bool visibleLoading = false;

  //late MqttPayloadProviderModel mqttProvider;

  @override
  void initState() {
    super.initState();
    //mqttProvider = MqttPayloadProviderModel();
    indicatorViewShow();
    getCustomerSite();

    Future.delayed(const Duration(milliseconds: 100), () async {
      //MqttWebClient().onSubscribed('FirmwareToApp/E8FB1C3501D1');
    });
  }

  Future<void> getCustomerSite() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      customerSiteList.clear();
      usedNodeList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          customerSiteList.add(CustomerSite.fromJson(cntList[i]));
          final nodeList = cntList[i]['nodeList'] as List;
          usedNodeList.add([]);
          for (int j=0; j < nodeList.length; j++) {
            usedNodeList[i].add(DashboardNode.fromJson(nodeList[j]));
          }
        }
        getProgramList(customerSiteList[0].controllerId ?? 0);
        indicatorViewHide();
      }
      setState(() {
        customerSiteList;
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
    var provider = Provider.of<MqttPayloadProviderModel>(context,listen: true);
    print('payload:${provider.payload}');
    final mediaQuery = MediaQuery.of(context);
    if(widget.type==0){
      return visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 100, 0, mediaQuery.size.width/2 - 100, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ) :
      DefaultTabController(
        length: customerSiteList.length, // Set the number of tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('DASHBOARD'),
            backgroundColor: myTheme.primaryColor,
            actions: [
              IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () async {
                //getControllerDashboardDetails(0, ddSelection);
              }),
              const SizedBox(width: 5,),
              IconButton(tooltip: 'Manual Mode', icon: const Icon(Icons.touch_app_outlined), onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByManual(siteID: customerSiteList[0].siteId, siteName: customerSiteList[0].siteName, controllerID: customerSiteList[0].controllerId, customerID: widget.customerID, imeiNo: customerSiteList[0].deviceId, programList: programList,)),);
              }),
              const SizedBox(width: 5,),
              IconButton(tooltip: 'Planing', icon: const Icon(Icons.list_alt), onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProgramSchedule(customerID: widget.customerID, controllerID: customerSiteList[0].controllerId, siteName: customerSiteList[0].siteName, imeiNumber: customerSiteList[0].deviceId, userId:  widget.customerID,)),);
              }),
              const SizedBox(width: 10,),
            ],// Set the background color of the tabs
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: customerSiteList.length,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                                isScrollable: true,
                                tabs: [
                                  for (var i = 0; i < customerSiteList.length; i++)
                                    Tab(text: customerSiteList[i].siteName ?? '',),
                                ],
                                onTap: (index) {
                                  getProgramList(customerSiteList[index].controllerId ?? 0 );
                                  selectedTabIndex = index;
                                },
                              ),
                            ),
                            IconButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  FarmSettings(siteID: customerSiteList[selectedTabIndex].siteId, siteName: customerSiteList[selectedTabIndex].siteName, controllerID: customerSiteList[selectedTabIndex].controllerId, customerID: widget.customerID, imeiNo: customerSiteList[selectedTabIndex].deviceId, userId: widget.userID,)),);
                            }, icon: const Icon(Icons.settings_outlined),),
                            const SizedBox(width: 10,),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height-105,
                          child: TabBarView(
                            children: [
                              for (int i = 0; i < customerSiteList.length; i++)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex :1,
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
                                                  //Text(customerSiteList[i].categoryName),
                                                  const SizedBox(height: 3,),
                                                  Text('modelDescription', style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  Text(customerSiteList[i].modelName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5, bottom: 5),
                                            child: VerticalDivider(),
                                          ),
                                          const Flexible(
                                            flex :1,
                                            child: Padding(
                                              padding: EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.network_wifi_1_bar),
                                                  SizedBox(height: 3,),
                                                  Text('20 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                                  SizedBox(height: 10,),
                                                  Icon(Icons.signal_cellular_alt),
                                                  SizedBox(height: 5,),
                                                  Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                                  SizedBox(height: 10,),
                                                  Icon(Icons.battery_3_bar_rounded),
                                                  SizedBox(height: 5,),
                                                  Text('50 %', style: TextStyle(fontWeight: FontWeight.normal),),
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
                                                  const Text('IMEI Number'),
                                                  SizedBox(height: 3,),
                                                  Text('${customerSiteList[i].deviceId}', style: TextStyle(fontWeight: FontWeight.normal),),
                                                  const SizedBox(height: 10,),
                                                  const Text('Controller Sim Number'),
                                                  const SizedBox(height: 5,),
                                                  Text('+91 7584744578', style: TextStyle(fontWeight: FontWeight.normal),),
                                                  const SizedBox(height: 10,),
                                                  const Text('Manufacturing Date'),
                                                  SizedBox(height: 5,),
                                                  Text('modelDescription', style: TextStyle(fontWeight: FontWeight.normal),),
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
                                                        height: 95,
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
                                                              child: Text(programList[pIdx].programName),
                                                            ),
                                                            SizedBox(
                                                              height: 65,
                                                              child: DataTable2(
                                                                columnSpacing: 12,
                                                                horizontalMargin: 12,
                                                                minWidth: 550,
                                                                dataRowHeight: 40.0,
                                                                headingRowHeight: 25.0,
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
                                                                  DataCell(Text(programList[pIdx].firstSequence, style: const TextStyle(fontWeight: FontWeight.normal))),
                                                                  DataCell(Center(child: Text('1/${programList[pIdx].sequenceCount}'))),
                                                                  DataCell(Center(child: programList[pIdx].scheduleType == 'NO SCHEDULE' ? const Text('---') :
                                                                  Text('${programList[pIdx].startDate.split(' ').first}'))),
                                                                  DataCell(Center(child: Text(programList[pIdx].startTime))),
                                                                  DataCell(Center(child: Text(programList[pIdx].duration))),
                                                                ])),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: customerSiteList[i].siteId, siteName: customerSiteList[i].siteName, controllerID: customerSiteList[i].controllerId, customerID: widget.customerID, imeiNo: customerSiteList[i].deviceId, programId: programList[pIdx].programId,)),);
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
                          rows: List<DataRow>.generate(usedNodeList[0].length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.normal),))),
                            DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor: Colors.green.shade200,))),
                            DataCell(Center(child: Text('${usedNodeList[0][index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal)))),
                            DataCell(Text(usedNodeList[0][index].categoryName, style: TextStyle(fontWeight: FontWeight.normal)),),
                            DataCell(Center(child: IconButton(icon: Icon(Icons.info_outline, color: myTheme.primaryColor,),onPressed: (){},iconSize: 20,))),
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.customerName)),
      body: Container(
        color: myTheme.primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: customerSiteList.length,
            itemBuilder: (context, siteIndex) {
              return InkWell(
                child: Card(
                  key: ValueKey([siteIndex]),
                  elevation: 1,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Container(
                    height: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Container(height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(customerSiteList[siteIndex].siteName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal,),),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          height: 200,
                          child: Row(
                            children: [
                              Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 50,
                                        backgroundImage: AssetImage('assets/images/oro_gem.png'),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(height: 5,),
                                      //Text(customerSiteList[siteIndex].categoryName),
                                      const SizedBox(height: 3,),
                                      Text('modelDescription', style: const TextStyle(fontWeight: FontWeight.normal),),
                                      Text(customerSiteList[siteIndex].modelName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              const Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.network_wifi_1_bar),
                                      SizedBox(height: 3,),
                                      Text('20 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                      SizedBox(height: 10,),
                                      Icon(Icons.signal_cellular_alt),
                                      SizedBox(height: 5,),
                                      Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                      SizedBox(height: 10,),
                                      Icon(Icons.battery_3_bar_rounded),
                                      SizedBox(height: 5,),
                                      Text('50 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              Flexible(
                                flex :1,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('IMEI Number'),
                                      SizedBox(height: 3,),
                                      Text('${customerSiteList[siteIndex].deviceId}', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(height: 10,),
                                      const Text('Controller Sim Number'),
                                      const SizedBox(height: 5,),
                                      Text('+91 7584744578', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(height: 10,),
                                      const Text('Manufacturing Date'),
                                      SizedBox(height: 5,),
                                      Text('modelDescription', style: TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              const Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Irrigation'),
                                      SizedBox(height: 3,),
                                      Text('Running', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.green),),
                                      SizedBox(height: 10,),
                                      Text('Fertilization'),
                                      SizedBox(height: 5,),
                                      Text('Idle', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.orange),),
                                      SizedBox(height: 10,),
                                      Text('Backwash'),
                                      SizedBox(height: 5,),
                                      Text('Idle', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.orange),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.sizeOf(context).width-165,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: usedNodeList[siteIndex].length,
                                    itemBuilder: (context, siteNodeIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO SWITCH'
                                                    || usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO SENSE'?
                                                AssetImage('assets/images/oro_switch.png'):
                                                usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO LEVEL'?
                                                AssetImage('assets/images/oro_sense.png'):
                                                AssetImage('assets/images/oro_rtu.png'),
                                                backgroundColor: Colors.transparent,
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(usedNodeList[siteIndex][siteNodeIndex].categoryName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                  Text('${'usedNodeList[siteIndex][siteNodeIndex].productDescription'}\n'
                                                      'IMEi : ${usedNodeList[siteIndex][siteNodeIndex].deviceId}',
                                                    style: const TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              )
                                            ]
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: customerSiteList[siteIndex].siteId, siteName: customerSiteList[siteIndex].siteName, controllerID: customerSiteList[siteIndex].controllerId, customerID: widget.customerID, imeiNo: customerSiteList[siteIndex].deviceId, programId: 0,)),);
                },
              );
            }),
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
class Person {
  String name;
  int age;

  Person(this.name, this.age);

  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age};
  }
}

