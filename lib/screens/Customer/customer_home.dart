import 'dart:async';
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'Dashboard/RunByManual.dart';
import 'ProgramSchedule.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.type, required this.customerName, required this.userID, required this.mobileNo}) : super(key: key);
  final int userID, customerID, type;
  final String customerName, mobileNo;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with SingleTickerProviderStateMixin
{
   late AnimationController animationController;
  late Animation<double> rotationAnimation;

  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  List<ProgramList> programList = [];
  bool visibleLoading = false;
  int wifiStrength = 0;
  final double _progressValue = 0.35;
  ProgramServiceDevices programServiceDevices = ProgramServiceDevices(irrigationPump: [], mainValve: [], centralFertilizerSite: [], centralFertilizer: [], localFertilizer: [], centralFilterSite: [], localFilter: []);

  String standaloneTime = '', standaloneFlow = '';
  int standaloneMethod = 0;
  String lastSyncData = '';


  @override
  void initState() {
    super.initState();
    initRotationAnimation();
    indicatorViewShow();
    getCustomerSite(widget.customerID);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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

  void onRefreshClicked() {
    animationController.repeat();
    Future.delayed(const Duration(milliseconds: 500), () {
      animationController.stop();
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
    });
  }

  void callbackFunction(message)
  {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });
  }

  Future<void> getCustomerSite(userId) async
  {
    Map<String, Object> body = {"userId" : userId ?? 0};
    //print(body);
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      siteListFinal.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        //print(cntList);
        try {
          siteListFinal = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          //live call
          String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
          MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
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

  Future<void> getProgramServiceDevices(int controllerId) async
  {
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

  int getNodePositionInNodeList(int siteIndex, int srlNo)
  {
    if (siteIndex >= 0 && siteIndex < siteListFinal.length) {
      List<NodeModel> nodeList = siteListFinal[siteIndex].nodeList;
      for (int i = 0; i < nodeList.length; i++) {
        if (nodeList[i].serialNumber == srlNo) {
          return i;
        }
      }
      return -1; // Return -1 as a signal of not found
    } else {
      return -1; // Return -1 if siteIndex is invalid
    }
  }

  @override
  Widget build(BuildContext context)
  {
    var provider = Provider.of<MqttPayloadProvider>(context, listen: true);
    try{
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
                int position = getNodePositionInNodeList(siteIndex, item['SNo']);
                if (position != -1) {
                  siteListFinal[siteIndex].nodeList[position].status = item['Status'];
                  siteListFinal[siteIndex].nodeList[position].batVolt = item['BatVolt'];
                  siteListFinal[siteIndex].nodeList[position].slrVolt = item['SVolt'];
                  siteListFinal[siteIndex].nodeList[position].rlyStatus = item['RlyStatus'];
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

    final screenWidth = MediaQuery.of(context).size.width;
    if(widget.type==0){
      return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
      DefaultTabController(
        length: siteListFinal.length,
        animationDuration: Duration.zero,
        child: Scaffold(
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

  Widget buildLoadingIndicator(bool isVisible, double width)
  {
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

  AppBar buildAppBar(String title, BuildContext context)
  {
    return AppBar(
      title: Text(title),
      backgroundColor: myTheme.primaryColor,
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(widget.mobileNo, style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.white)),
              ],
            ),
            const SizedBox(width: 05),
            const CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
            ),
          ],),
        const SizedBox(width: 10)
      ],
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

  Container buildBodyContent()
  {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          siteListFinal.length >1 ? TabBar(
            indicatorColor: myTheme.primaryColor,
            isScrollable: true,
            labelColor: myTheme.primaryColor,
            unselectedLabelColor: Colors.black,
            tabs: [
              for (var i = 0; i < siteListFinal.length; i++)
                Tab(text: siteListFinal[i].siteName ?? '',),
            ],
            onTap: (index) {
              getProgramList(siteListFinal[index].controllerId ?? 0 );
              siteIndex = index;
            },
          ) :
          const SizedBox(),
          ListTile(
            tileColor: Colors.white,
            leading: Image.asset('assets/images/oro_gem.png'),
            title: Text(siteListFinal[siteIndex].deviceName),
            subtitle: Text('${siteListFinal[siteIndex].categoryName} - Last sync : $lastSyncData', style: const TextStyle(fontWeight: FontWeight.normal),),
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
                        return RunByManual(siteID: siteListFinal[siteIndex].siteId,
                          siteName: siteListFinal[siteIndex].siteName,
                          controllerID: siteListFinal[siteIndex].controllerId,
                          customerID: widget.customerID,
                          imeiNo: siteListFinal[siteIndex].deviceId,
                          programList: programList, callbackFunction: callbackFunction);
                      },
                    );

                    /*Navigator.push(
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
                    );*/
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
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TabBarView(
                      children: [
                        for (int i = 0; i < siteListFinal.length; i++)
                          SingleChildScrollView(
                            child: SizedBox(
                              child: Column(
                                children: [
                                  /*SizedBox(
                                    height: 220,
                                    child: Card(
                                      elevation: 2,
                                      surfaceTintColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
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
                                  ),
                                  const Divider(),*/
                                  SizedBox(
                                    height: 170,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          tileColor: Colors.green,
                                          title: const Text('CURRENT PROGRAM', style: TextStyle(fontSize: 14)),
                                          subtitle: const Text('Standalone'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset('assets/GiffFile/water_drop_animation.gif'),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 0),
                                        Container(
                                          color: Colors.white,
                                          height: 100,
                                          child: standaloneMethod !=0? ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: programList.length,
                                              itemBuilder: (context, pIdx) {
                                                return InkWell(
                                                  child: SizedBox(
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
                                                              String payload = '${0},${1},${1},${0},${0},${0},${0},${0}';
                                                              String payLoadFinal = jsonEncode({
                                                                "800": [{"801": payload}]
                                                              });
                                                              MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
                                                              removeManualModeInServer();
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
                                                  ),
                                                  onTap: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: siteListFinal[i].siteId, siteName: siteListFinal[i].siteName, controllerID: siteListFinal[i].controllerId, customerID: widget.customerID, imeiNo: siteListFinal[i].deviceId, programId: programList[pIdx].programId,)),);
                                                  },
                                                );
                                              }) :
                                          Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: (programList.length * 35) + 110,
                                    child: Column(
                                      children: [
                                        const Divider(height: 0),
                                        ListTile(
                                          tileColor: Colors.white,
                                          title: const Text('NEXT PROGRAM', style: TextStyle(fontSize: 14)),
                                          subtitle: Text(programList.isNotEmpty ? programList[0].programName:'No program Available'),
                                          trailing: IconButton(
                                              tooltip: 'Up Coming Program',
                                              onPressed: () {
                                              },
                                              icon: const Icon(Icons.view_list_outlined)),
                                        ),
                                        const Divider(height: 0),
                                        Container(
                                          color: Colors.white,
                                          height: (programList.length * 35) + 35,
                                          child: programList.isNotEmpty? InkWell(
                                            child: SizedBox(
                                              height: (programList.length * 35) + 35,
                                              child: DataTable2(
                                                columnSpacing: 12,
                                                horizontalMargin: 12,
                                                minWidth: 550,
                                                dataRowHeight: 35.0,
                                                headingRowHeight: 35.0,
                                                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                                                //border: TableBorder.all(),
                                                columns: const [
                                                  DataColumn2(
                                                      label: Text('Name', style: TextStyle(fontSize: 13),),
                                                      size: ColumnSize.M
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('Total Rtc', style: TextStyle(fontSize: 13),)),
                                                      fixedWidth: 100
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('Current Rtc', style: TextStyle(fontSize: 13),)),
                                                      fixedWidth: 100
                                                  ),
                                                  DataColumn2(
                                                      label: Center(child: Text('Total Cycle', style: TextStyle(fontSize: 13),)),
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
                                                rows: List<DataRow>.generate(programList.length, (index) => DataRow(cells: [
                                                  DataCell(Text(programList[index].firstSequence)),
                                                  DataCell(Center(child: Text('1/${programList[index].sequenceCount}'))),
                                                  DataCell(Center(child: programList[index].scheduleType == 'NO SCHEDULE' ? const Text('---') :
                                                  Text(programList[index].startDate.split(' ').first))),
                                                  DataCell(Center(child: Text(programList[index].startTime))),
                                                  DataCell(Center(child: Text(programList[index].duration))),
                                                  DataCell(Center(child: Text(programList[index].duration))),
                                                  DataCell(Center(child: Text(programList[index].duration))),
                                                ])),
                                              ),
                                            ),
                                            onTap: (){
                                              //Navigator.push(context, MaterialPageRoute(builder: (context) =>  DashboardByProgram(siteID: siteListFinal[i].siteId, siteName: siteListFinal[i].siteName, controllerID: siteListFinal[i].controllerId, customerID: widget.customerID, imeiNo: siteListFinal[i].deviceId, programId: programList[index].programId,)),);
                                            },
                                          ) :
                                          Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 2),
                  Container(
                    width: 345,
                    height: MediaQuery.sizeOf(context).height,
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
                                          SizedBox(width: 10),
                                          CircleAvatar(radius: 5, backgroundColor: Colors.green,),
                                          SizedBox(width: 5),
                                          Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
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
                                          SizedBox(width: 20),
                                          CircleAvatar(radius: 5, backgroundColor: Colors.redAccent,),
                                          SizedBox(width: 5),
                                          Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 20),
                                          CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                                          SizedBox(width: 5),
                                          Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(tooltip:'View all Node details', onPressed: (){
                                      showNodeDetailsBottomSheet(context);
                                    }, icon: const Icon(Icons.backup_table_rounded)),
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
                            rows: List<DataRow>.generate(siteListFinal[siteIndex].nodeList.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Text('${siteListFinal[siteIndex].nodeList[index].serialNumber}', style: const TextStyle(fontWeight: FontWeight.normal),))),
                              DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                              siteListFinal[siteIndex].nodeList[index].status == 1 ? Colors.green.shade400:
                              siteListFinal[siteIndex].nodeList[index].status == 3 ? Colors.red.shade400:
                              siteListFinal[siteIndex].nodeList[index].status == 2 ? Colors.grey :
                              siteListFinal[siteIndex].nodeList[index].status == 4 ? Colors.yellow :
                              Colors.grey,
                              ))),
                              DataCell(Center(child: Text('${siteListFinal[siteIndex].nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal)))),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(siteListFinal[siteIndex].nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.normal)),
                                  Text(siteListFinal[siteIndex].nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11)),
                                ],
                              )),
                              DataCell(Center(child: IconButton(tooltip: 'View Relay status',
                                icon: const Icon(Icons.receipt_long), // Icon to display
                                onPressed: () {
                                  showRelayBottomSheet(context, index);
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
        ],
      ),
    );
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
                      for (int i = 0; i < siteListFinal[siteIndex].nodeList.length; i++)
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
                                title: Text('${siteListFinal[siteIndex].nodeList[i].categoryName} - ${siteListFinal[siteIndex].nodeList[i].deviceId}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.solar_power_outlined),
                                    const SizedBox(width: 5,),
                                    Text('${siteListFinal[siteIndex].nodeList[i].slrVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                    const SizedBox(width: 5,),
                                    const Icon(Icons.battery_3_bar_rounded),
                                    Text('${siteListFinal[siteIndex].nodeList[i].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                    const SizedBox(width: 5,),
                                    IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                      String payLoadFinal = jsonEncode({
                                        "2300": [
                                          {"2301": "${siteListFinal[siteIndex].nodeList[i].serialNumber}"},
                                        ]
                                      });
                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
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
                                itemCount: siteListFinal[siteIndex].nodeList[i].rlyStatus.length,
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
                                            backgroundColor: siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Status']==0 ? Colors.grey :
                                            siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Status']==1 ? Colors.green :
                                            siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Status']==2 ? Colors.orange :
                                            siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Status']==3 ? Colors.redAccent : Colors.black12,
                                          ),
                                          const SizedBox(width: 3),
                                          Text('${siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name']}(${siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['RlyNo']})', style: const TextStyle(color: Colors.black, fontSize: 10)),
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

  Future<void>showRelayBottomSheet(BuildContext context, int index) async{
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: siteListFinal[siteIndex].nodeList[index].rlyStatus.length > 8? 275 : 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListTile(
                tileColor: myTheme.primaryColor,
                textColor: Colors.white,
                leading: const Icon(Icons.developer_board_rounded, color: Colors.white),
                title: Text('${siteListFinal[siteIndex].nodeList[index].categoryName} - ${siteListFinal[siteIndex].nodeList[index].deviceId}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.solar_power_outlined, color: Colors.white),
                    const SizedBox(width: 5,),
                    Text('${siteListFinal[siteIndex].nodeList[index].slrVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                    const SizedBox(width: 5,),
                    const Icon(Icons.battery_3_bar_rounded, color: Colors.white),
                    const SizedBox(width: 5,),
                    Text('${siteListFinal[siteIndex].nodeList[index].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                    const SizedBox(width: 5,),
                    IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                      String payLoadFinal = jsonEncode({
                        "2300": [
                          {"2301": "${siteListFinal[siteIndex].nodeList[index].serialNumber}"},
                        ]
                      });
                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
                    }, icon: Icon(Icons.fact_check_outlined, color: Colors.white))
                  ],
                ),
              ),
              const Divider(height: 0),
              SizedBox(
                width : double.infinity,
                height : siteListFinal[siteIndex].nodeList[index].rlyStatus.length > 8? 206 : 130,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: siteListFinal[siteIndex].nodeList[index].rlyStatus.isNotEmpty ? Column(
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
                        height : siteListFinal[siteIndex].nodeList[index].rlyStatus.length > 8? 150 : 70,
                        child: GridView.builder(
                          itemCount: siteListFinal[siteIndex].nodeList[index].rlyStatus.length, // Number of items in the grid
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          itemBuilder: (BuildContext context, int indexGv) {
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: siteListFinal[siteIndex].nodeList[index].rlyStatus[indexGv]['Status']==0 ? Colors.grey :
                                  siteListFinal[siteIndex].nodeList[index].rlyStatus[indexGv]['Status']==1 ? Colors.green :
                                  siteListFinal[siteIndex].nodeList[index].rlyStatus[indexGv]['Status']==2 ? Colors.orange :
                                  siteListFinal[siteIndex].nodeList[index].rlyStatus[indexGv]['Status']==3 ? Colors.redAccent : Colors.black12, // Avatar background color
                                  child: Text((siteListFinal[siteIndex].nodeList[index].rlyStatus[indexGv]['RlyNo']).toString(), style: const TextStyle(color: Colors.white)),
                                ),
                                Text((siteListFinal[siteIndex].nodeList[index].rlyStatus[indexGv]['Name']).toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
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
  }

  Future<void>removeManualModeInServer() async
  {
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

   void _showSnackBar(String message) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         duration: const Duration(seconds: 3),
       ),
     );
   }

}