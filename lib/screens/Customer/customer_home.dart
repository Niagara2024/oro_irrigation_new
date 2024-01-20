import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../Models/Customer/Dashboard/ProgramServiceDevices.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import 'Dashboard/DashboardByManual.dart';
import 'Dashboard/DashboardByProgram.dart';
import 'ProgramSchedule.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.type, required this.customerName, required this.userID, required this.siteList}) : super(key: key);
  final int userID, customerID, type;
  final String customerName;
  final List<DashboardModel> siteList;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
{
  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  List<ProgramList> programList = [];
  bool visibleLoading = false;
  int wifiStrength = 0;
  final double _progressValue = 0.35;
  ProgramServiceDevices programServiceDevices = ProgramServiceDevices(irrigationPump: [], mainValve: [], centralFertilizerSite: [], centralFertilizer: [], localFertilizer: [], centralFilterSite: [], localFilter: []);

  String standaloneTime = '', standaloneFlow = '';
  int standaloneMethod = 0;

  @override
  void initState() {
    super.initState();
    indicatorViewShow();
    if(widget.type==1){
      getCustomerSite(widget.customerID);
    }else{
      siteListFinal = widget.siteList;
      fetchDashboardData();
    }
  }

  Future<void> getCustomerSite(userId) async
  {
    Map<String, Object> body = {"userId" : userId ?? 0};
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      siteListFinal.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        try {
          siteListFinal = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          fetchDashboardData();
        } catch (e) {
          print('Error: $e');
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  void fetchDashboardData()
  {
    getStandaloneDetails(siteListFinal[siteIndex].controllerId ?? 0);
    getProgramList(siteListFinal[siteIndex].controllerId ?? 0);
    getProgramServiceDevices(siteListFinal[siteIndex].controllerId ?? 0);
    MQTTManager().subscribeToTopic('FirmwareToApp/${siteListFinal[siteIndex].deviceId}');
  }


  Future<void> getProgramList(int controllerId) async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //print(jsonResponse);
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

  Future<void> getStandaloneDetails(int controllerId) async
  {
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserManualOperation", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if(jsonResponse['code']==200){
          standaloneMethod = jsonResponse['data']['method'];
          standaloneTime = jsonResponse['data']['time'];
          standaloneFlow = jsonResponse['data']['flow'];
        }else{
          standaloneMethod = 0;
        }
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getProgramServiceDevices(int controllerId) async {
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getProgramServiceDevices", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //print(jsonResponse);
        if(jsonResponse['code']==200){
          Map<String, dynamic> jsonDataMap = jsonResponse['data'];
          setState((){
            programServiceDevices = ProgramServiceDevices.fromJson(jsonDataMap);
          });
        }else{

        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void callbackFunction(){
    Future.delayed(const Duration(seconds: 02), () {
      getStandaloneDetails(siteListFinal[siteIndex].controllerId ?? 0);
    });

  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MqttPayloadProvider>(context, listen: true);
    try{
      wifiStrength = provider.receivedWifiStrength ?? 0;
      List<dynamic> list2401 = provider.receivedNodeStatus ?? [];
      for (var item in list2401) {
        if (item is Map<String, dynamic>) {
          try {
            //print(item['SNo'].runtimeType);
            int sNo = int.parse(item['SNo'] ?? '0');
            if (sNo >= 1) {
              siteListFinal[siteIndex].nodeList[sNo - 1].Status = int.parse(item['Status']);
              siteListFinal[siteIndex].nodeList[sNo - 1].BatVolt = item['BatVolt'];
              siteListFinal[siteIndex].nodeList[sNo - 1].SVolt = item['SVolt'];
              siteListFinal[siteIndex].nodeList[sNo - 1].RlyStatus = item['RlyStatus'];
              siteListFinal[siteIndex].nodeList[sNo - 1].Sensor = int.parse(item['Sensor']);

            } else {
              print('Invalid index or node list is null');
            }
          } catch (e) {
            print('Error updating node properties: $e');
          }
        }
      }
    }catch(e){
      print(e);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    if(widget.type==0){
      return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
      DefaultTabController(
        length: siteListFinal.length, // Set the number of tabs
        child: Scaffold(
          appBar: buildAppBar('DASHBOARD', context),
          body: buildBodyContent(),
        ),
      );
    }

    return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
    DefaultTabController(
      length: siteListFinal.length, // Set the number of tabs
      child: Scaffold(
        appBar: buildAppBar('${widget.customerName} - DASHBOARD', context),
        body: buildBodyContent(),
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
             MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
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
                  siteID: siteListFinal[siteIndex].siteId,
                  siteName: siteListFinal[siteIndex].siteName,
                  controllerID: siteListFinal[siteIndex].controllerId,
                  customerID: widget.customerID,
                  imeiNo: siteListFinal[siteIndex].deviceId,
                  programList: programList, callbackFunction: callbackFunction,
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
                  controllerID: siteListFinal[siteIndex].controllerId,
                  siteName: siteListFinal[siteIndex].siteName,
                  imeiNumber: siteListFinal[siteIndex].deviceId,
                  userId: widget.customerID,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10,),
      ],
      bottom: siteListFinal.length >1 ?TabBar(
        indicatorColor: const Color.fromARGB(255, 175, 73, 73),
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: [
          for (var i = 0; i < siteListFinal.length; i++)
            Tab(text: siteListFinal[i].siteName ?? '',),
        ],
        onTap: (index) {
          getProgramList(siteListFinal[index].controllerId ?? 0 );
          siteIndex = index;
        },
      ) : null,
    );
  }

  Padding buildBodyContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/oro_gem.png'),
              backgroundColor: Colors.transparent,
            ),
            title: Text(siteListFinal[siteIndex].deviceName),
            subtitle: Text(siteListFinal[siteIndex].categoryName, style: const TextStyle(fontWeight: FontWeight.normal),),
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
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TabBarView(
                      children: [
                        for (int i = 0; i < siteListFinal.length; i++)
                          SingleChildScrollView(
                            child: standaloneMethod !=0? SizedBox(
                              child: Column(
                                children: [
                                  Container(
                                    height: 210,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 260,
                                          child: Column(
                                            children: [
                                              const ListTile(
                                                title: Text('Main Line'),
                                              ),
                                              programServiceDevices.irrigationPump.isNotEmpty
                                                  ||programServiceDevices.centralFilterSite.isNotEmpty
                                                  ||programServiceDevices.mainValve.isNotEmpty?
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 49.5,
                                                      height: 145,
                                                      child: ListView.builder(
                                                        itemCount: programServiceDevices.irrigationPump.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          if (index < programServiceDevices.irrigationPump.length) {
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
                                                                            Text(programServiceDevices.irrigationPump[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                            const Divider(),
                                                                            Text('ID : ${programServiceDevices.irrigationPump[index].id}'),
                                                                            Text('Location : ${programServiceDevices.irrigationPump[index].location}'),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ];
                                                                  },
                                                                  child: programServiceDevices.irrigationPump.length ==1?
                                                                  Image.asset('assets/images/dp_irr_pump.png'):
                                                                  programServiceDevices.irrigationPump.length==2 && index==0?
                                                                  Image.asset('assets/images/dp_irr_pump_1.png'):
                                                                  programServiceDevices.irrigationPump.length==2 && index==1?
                                                                  Image.asset('assets/images/dp_irr_pump_3.png'):
                                                                  programServiceDevices.irrigationPump.length==3 && index==0?
                                                                  Image.asset('assets/images/dp_irr_pump_1.png'):
                                                                  programServiceDevices.irrigationPump.length==3 && index==1?
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
                                                          if (index < programServiceDevices.centralFilterSite.length) {
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
                                                                            Text(programServiceDevices.centralFilterSite[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                            const Divider(),
                                                                            Text('ID : ${programServiceDevices.centralFilterSite[index].id}'),
                                                                            Text('Location : ${programServiceDevices.centralFilterSite[index].location}'),
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
                                                        itemCount: programServiceDevices.mainValve.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          if (index < programServiceDevices.mainValve.length) {
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
                                                                            Text(programServiceDevices.mainValve[index].name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                            const Divider(),
                                                                            Text('ID : ${programServiceDevices.mainValve[index].id}'),
                                                                            Text('Location : ${programServiceDevices.mainValve[index].location}'),
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
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 136,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: const Text('CURRENT PROGRAM'),
                                          subtitle: const Text('Standalone'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset('assets/GiffFile/water_drop_animation.gif'),
                                              IconButton(
                                                  tooltip: 'Stop',
                                                  onPressed: () {
                                                    String payload = '${0},${1},${1},${0},${0},${0},${0},${0}';
                                                    String payLoadFinal = jsonEncode({
                                                      "800": [{"801": payload}]
                                                    });
                                                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
                                                    removeManualModeInServer();
                                                  },
                                                  icon: const Icon(
                                                    Icons.stop_circle_outlined,
                                                    color: Colors.redAccent,
                                                  ))
                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: Colors.green.withOpacity(0.1),
                                          height: 70,
                                          child: standaloneMethod !=0? ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: programList.length,
                                              itemBuilder: (context, pIdx) {
                                                return InkWell(
                                                  child: SizedBox(
                                                    height: 70,
                                                    child: DataTable2(
                                                      columnSpacing: 12,
                                                      horizontalMargin: 12,
                                                      minWidth: 550,
                                                      dataRowHeight: 35.0,
                                                      headingRowHeight: 35.0,
                                                      border: TableBorder.all(color: Colors.green.withOpacity(0.6)),
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
                                                      ],
                                                      rows: List<DataRow>.generate(1, (index) => const DataRow(cells: [
                                                        DataCell(Text('Manual')),
                                                        DataCell(Center(child: Text('---'))),
                                                        DataCell(Center(child: Text('---'))),
                                                        DataCell(Center(child: Text('---'))),
                                                        DataCell(Center(child: Text('----'))),
                                                      ])),
                                                    ),
                                                  ),
                                                  onTap: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: siteListFinal[i].siteId, siteName: siteListFinal[i].siteName, controllerID: siteListFinal[i].controllerId, customerID: widget.customerID, imeiNo: siteListFinal[i].deviceId, programId: programList[pIdx].programId,)),);
                                                  },
                                                );
                                              }):
                                          Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  Container(
                                    height: 136,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: myTheme.primaryColor.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: const Text('NEXT PROGRAM'),
                                          subtitle: Text(programList.isNotEmpty ? programList[0].programName:''),
                                          trailing: IconButton(
                                              tooltip: 'Up Coming Program',
                                              onPressed: () {
                                              },
                                              icon: Icon(
                                                Icons.view_list_outlined,
                                                color: myTheme.primaryColor.withOpacity(0.6),
                                              )),
                                        ),
                                        Container(
                                          color: myTheme.primaryColor.withOpacity(0.1),
                                          height: 70,
                                          child: programList.isNotEmpty? ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: programList.length,
                                              itemBuilder: (context, pIdx) {
                                                return InkWell(
                                                  child: SizedBox(
                                                    height: 70,
                                                    child: DataTable2(
                                                      columnSpacing: 12,
                                                      horizontalMargin: 12,
                                                      minWidth: 550,
                                                      dataRowHeight: 35.0,
                                                      headingRowHeight: 35.0,
                                                      border: TableBorder.all(color: myTheme.primaryColor.withOpacity(0.6)),
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
                                                  onTap: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: siteListFinal[i].siteId, siteName: siteListFinal[i].siteName, controllerID: siteListFinal[i].controllerId, customerID: widget.customerID, imeiNo: siteListFinal[i].deviceId, programId: programList[pIdx].programId,)),);
                                                  },
                                                );
                                              }):
                                          Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ):
                            const Column(
                              children: [
                                SizedBox(height: 150),
                                Text('No Schedule Available')
                              ]
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
                      Expanded(
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
                          rows: List<DataRow>.generate(siteListFinal[siteIndex].nodeList.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.normal),))),
                            DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                            siteListFinal[siteIndex].nodeList[index].Status == 1 ? Colors.green.shade400:
                            siteListFinal[siteIndex].nodeList[index].Status == 2 ? Colors.red.shade400:
                            siteListFinal[siteIndex].nodeList[index].Status == 3 ? Colors.grey:
                            Colors.yellow,
                            ))),
                            DataCell(Center(child: Text('${siteListFinal[siteIndex].nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal)))),
                            DataCell(Text(siteListFinal[siteIndex].nodeList[index].categoryName, style: TextStyle(fontWeight: FontWeight.normal)),),
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
                                        Text(siteListFinal[siteIndex].nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                        const Divider(),
                                        Text('Battery voltage : ${siteListFinal[siteIndex].nodeList[index].BatVolt}'),
                                        Text('Solar voltage : ${siteListFinal[siteIndex].nodeList[index].SVolt}'),
                                        Text('Sensor : ${siteListFinal[siteIndex].nodeList[index].Sensor}'),
                                        Text('Relay Status : ${siteListFinal[siteIndex].nodeList[index].RlyStatus}'),
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
        ],
      ),
    );
  }

  Future<void>removeManualModeInServer() async {
    Map<String, dynamic> manualOperation = {
      "method": 1,
      "time": '00:00',
      "flow": '00.0',
      "selected": [],
    };
    try {
      final body = {"userId": widget.customerID, "controllerId": siteListFinal[siteIndex].controllerId, "manualOperation": manualOperation, "createUser": widget.customerID};
      final response = await HttpService().postRequest("createUserManualOperation", body);
      if (response.statusCode == 200) {
        Future.delayed(const Duration(seconds: 01), () {
          getStandaloneDetails(siteListFinal[siteIndex].controllerId ?? 0);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
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