import 'dart:async';
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/SentAndReceived.dart';
import 'package:oro_irrigation_new/screens/Customer/WeatherScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../constants/AppImages.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import '../product_inventory.dart';
import 'AccountManagement.dart';
import 'CustomerDashboard.dart';
import 'Dashboard/AllNodeListAndDetails.dart';
import 'Dashboard/ControllerLogs.dart';
import 'Dashboard/ControllerSettings.dart';
import 'Dashboard/RunByManual.dart';
import 'ProgramSchedule.dart';
import 'PumpControllerScreen/PumpDashboard.dart';


class CustomerScreenController extends StatefulWidget {
  const CustomerScreenController({Key? key, required this.customerId, required this.customerName, required this.mobileNo, required this.emailId, required this.comingFrom, required this.userId}) : super(key: key);
  final int userId, customerId;
  final String customerName, mobileNo, emailId, comingFrom;

  @override
  _CustomerScreenControllerState createState() => _CustomerScreenControllerState();
}

class _CustomerScreenControllerState extends State<CustomerScreenController> with SingleTickerProviderStateMixin
{
  late TabController _tabController;

  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  int masterIndex = 0;
  int lineIndex = 0;
  bool visibleLoading = false;
  int _selectedIndex = 0;
  List<ProgramList> programList = [];

  String lastSyncData = '';

  late String _myCurrentSite;
  late String _myCurrentMasterC;
  late String _myCurrentIrrLine;


  @override
  void initState() {
    super.initState();
    print('coming from: ${widget.comingFrom}');
    print('coming userId: ${widget.userId}');
    print('coming customerId: ${widget.customerId}');
    indicatorViewShow();
    clearMQTTPayload();
    getCustomerSite(widget.customerId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void callbackFunction(message)
  {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });
  }

  void onRefreshClicked() {
    String livePayload = '';
    Future.delayed(const Duration(milliseconds: 1000), () {

      if(siteListFinal[siteIndex].master[masterIndex].modelId==1||
          siteListFinal[siteIndex].master[masterIndex].modelId==2){
        livePayload = jsonEncode({"3000": [{"3001": ""}]});
      }else{
        livePayload = jsonEncode({"sentSMS": [{"#live": ""}]});
      }
      MQTTManager().publish(livePayload, 'AppToFirmware/${siteListFinal[siteIndex].master[masterIndex].deviceId}');
    });
  }

  void clearMQTTPayload(){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    payloadProvider.currentSchedule.clear();
    payloadProvider.PrsIn=[];
    payloadProvider.PrsOut=[];
    payloadProvider.programQueue.clear();
    payloadProvider.scheduledProgram.clear();
    payloadProvider.filtersCentral=[];
    payloadProvider.filtersLocal=[];
    payloadProvider.sourcePump=[];
    payloadProvider.irrigationPump=[];
    payloadProvider.fertilizerCentral=[];
    payloadProvider.fertilizerLocal=[];
    payloadProvider.waterMeter=[];
    payloadProvider.wifiStrength = 0;
    payloadProvider.alarmList = [];
    payloadProvider.payload2408 = [];
  }

  Future<void> getCustomerSite(userId) async
  {
    Map<String, Object> body = {"userId" : userId ?? 0};
    //final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    final response = await HttpService().postRequest("getCustomerDashboard", body);
    if (response.statusCode == 200)
    {
      siteListFinal.clear();
      var data = jsonDecode(response.body);
      print(response.body);
      if(data["code"]==200)
      {
        final jsonData = data["data"] as List;
        try {
          siteListFinal = jsonData.map((json) => DashboardModel.fromJson(json)).toList();
          indicatorViewHide();
          if(siteListFinal.isNotEmpty){
            /*if(siteListFinal[siteIndex].master[masterIndex].irrigationLine.length>1){
              IrrigationLine newLine = IrrigationLine(
                sNo: 0,
                id: '0',
                hid: '0',
                name: 'Line overview',
                location: 'No location',
                type: 'no type',
                mainValve: [],
                valve: [],
              );
              siteListFinal[siteIndex].master[masterIndex].irrigationLine.insert(0, newLine);
            }*/
            _myCurrentSite = siteListFinal[siteIndex].groupName;
            _myCurrentMasterC = siteListFinal[siteIndex].master[masterIndex].categoryName;
            _myCurrentIrrLine = siteListFinal[siteIndex].master[masterIndex].irrigationLine[lineIndex].name;

            intTabController();
            subscribeAndUpdateSite();
            getProgramList();
            loadServerData();
          }
        } catch (e) {
          print('Error: $e');
          indicatorViewHide();
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  void intTabController(){
    _tabController = TabController(length: siteListFinal[siteIndex].master.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        masterIndex = _tabController.index;
        subscribeAndUpdateSite();
      }
    });
  }

  void loadServerData(){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    List<dynamic> ndlLst = siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList.map((ndl) => ndl.toJson()).toList();
    payloadProvider.updateNodeList(ndlLst);

    List<dynamic> csLst = siteListFinal[siteIndex].master[masterIndex].liveData[0].currentSchedule.map((cs) => cs.toJson()).toList();
    List<CurrentScheduleModel> cs = csLst.map((cs) => CurrentScheduleModel.fromJson(cs)).toList();
    payloadProvider.updateCurrentScheduled(cs);

    List<dynamic> pqLst = siteListFinal[siteIndex].master[masterIndex].liveData[0].queProgramList.map((pq) => pq.toJson()).toList();
    List<ProgramQueue> pq = pqLst.map((pq) => ProgramQueue.fromJson(pq)).toList();
    payloadProvider.updateProgramQueue(pq);

    List<dynamic> spLst = siteListFinal[siteIndex].master[masterIndex].liveData[0].scheduledProgramList.map((sp) => sp.toJson()).toList();
    List<ScheduledProgram> sp = spLst.map((sp) => ScheduledProgram.fromJson(sp)).toList();
    payloadProvider.updateScheduledProgram(sp);

    String filterList = jsonEncode(siteListFinal[siteIndex].master[masterIndex].liveData[0].filterList.map((filter) => filter.toJson()).toList());
    List<dynamic> jsonFilterList = jsonDecode(filterList);
    String filterPayloadFinal = jsonEncode({
      "2400": [{"2405": jsonFilterList.toList()}]
    });
    payloadProvider.updateFilterPayload(filterPayloadFinal);

    String fertilizerSiteList = jsonEncode(siteListFinal[siteIndex].master[masterIndex].liveData[0].fertilizerSiteList.map((pump) => pump.toJson()).toList());
    List<dynamic> jsonFertilizerList = jsonDecode(fertilizerSiteList);
    String fertilizerPayloadFinal = jsonEncode({
      "2400": [{"2406": jsonFertilizerList.toList()}]
    });
    payloadProvider.updateFertilizerPayload(fertilizerPayloadFinal);

    String pumpList= jsonEncode(siteListFinal[siteIndex].master[masterIndex].liveData[0].pumpList.map((pump) => pump.toJson()).toList());
    List<dynamic> jsonPumpList = jsonDecode(pumpList);
    String pumpPayloadFinal = jsonEncode({
      "2400": [{"2407": jsonPumpList.toList()}]
    });
    payloadProvider.updatePumpPayload(pumpPayloadFinal);

  }

  Future<void> getProgramList() async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerId, "controllerId": siteListFinal[siteIndex].master[masterIndex].controllerId};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> programsJson = jsonResponse['data'];
        setState(() {
          programList = [...programsJson.map((programJson) => ProgramList.fromJson(programJson)).toList()];
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void subscribeAndUpdateSite() {
    Future.delayed(const Duration(seconds: 3), () {
      MQTTManager().subscribeToTopic('FirmwareToApp/${siteListFinal[siteIndex].master[masterIndex].deviceId}');
    });
  }


  @override
  Widget build(BuildContext context)
  {
    final screenWidth = MediaQuery.of(context).size.width;
    final provider = Provider.of<MqttPayloadProvider>(context);
    final wifiStrength = Provider.of<MqttPayloadProvider>(context).wifiStrength;
    final currentDate = Provider.of<MqttPayloadProvider>(context).currentDate;
    final currentTime = Provider.of<MqttPayloadProvider>(context).currentTime;

    final payload2408 = Provider.of<MqttPayloadProvider>(context).payload2408;
    bool allIrrigationResumeFlag = payload2408.every((record) => record['IrrigationPauseFlag'] == 1);

    if(siteListFinal.isNotEmpty){
      if(currentDate.isNotEmpty){
        siteListFinal[siteIndex].master[masterIndex].liveSyncDate = currentDate;
        siteListFinal[siteIndex].master[masterIndex].liveSyncTime = currentTime;
      }
    }

    return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
    Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Image(image: AssetImage("assets/images/oro_logo_white.png")),
        ),
        title:  Row(
          children: [
            const SizedBox(width: 10,),
            Container(width: 1, height: 20, color: Colors.white54,),
            const SizedBox(width: 5,),
            siteListFinal.length>1? DropdownButton(
              underline: Container(),
              items: (siteListFinal ?? []).map((site) {
                return DropdownMenuItem(
                  value: site.groupName,
                  child: Text(site.groupName, style: const TextStyle(color: Colors.white, fontSize: 17),),
                );
              }).toList(),
              onChanged: (newSiteName) {
                int newIndex = siteListFinal.indexWhere((site) => site.groupName == newSiteName);
                if (newIndex != -1 && siteListFinal.length > 1) {
                  setState(() {
                    _myCurrentSite = newSiteName!;
                    siteIndex = newIndex;
                  });
                  clearMQTTPayload();
                  subscribeAndUpdateSite();
                  getProgramList();
                }
              },
              value: _myCurrentSite,
              dropdownColor: Colors.teal,
              iconEnabledColor: Colors.white,
              iconDisabledColor: Colors.white,
              focusColor: Colors.transparent,
            ) :
            Text(siteListFinal[siteIndex].groupName, style: const TextStyle(fontSize: 17),),

            const SizedBox(width: 15,),
            Container(width: 1,height: 20, color: Colors.white54,),
            const SizedBox(width: 5,),
            siteListFinal[siteIndex].master.length>1? DropdownButton(
              underline: Container(),
              items: (siteListFinal[siteIndex].master ?? []).map((master) {
                return DropdownMenuItem(
                  value: master.categoryName,
                  child: Text(master.categoryName, style: const TextStyle(color: Colors.white, fontSize: 17),),
                );
              }).toList(),
              onChanged: (newMaterName) {
                int newIndex = siteListFinal[siteIndex].master.indexWhere((master)
                => master.categoryName == newMaterName);
                if (newIndex != -1 && siteListFinal[siteIndex].master.length > 1) {
                  setState(() {
                    _myCurrentMasterC = newMaterName!;
                    masterIndex = newIndex;
                  });
                }
              },
              value: _myCurrentMasterC,
              dropdownColor: Colors.teal,
              iconEnabledColor: Colors.white,
              iconDisabledColor: Colors.white,
              focusColor: Colors.transparent,
            ) :
            Text(siteListFinal[siteIndex].master[masterIndex].categoryName, style: const TextStyle(fontSize: 17),),

            siteListFinal[siteIndex].master[masterIndex].categoryId == 1 ||
                siteListFinal[siteIndex].master[masterIndex].categoryId == 2? const SizedBox(width: 15,): const SizedBox(),
            siteListFinal[siteIndex].master[masterIndex].categoryId == 1 ||
                siteListFinal[siteIndex].master[masterIndex].categoryId == 2? Container(width: 1,height: 20, color: Colors.white54,): const SizedBox(),
            siteListFinal[siteIndex].master[masterIndex].categoryId == 1 ||
                siteListFinal[siteIndex].master[masterIndex].categoryId == 2? const SizedBox(width: 5,): const SizedBox(),
            siteListFinal[siteIndex].master[masterIndex].categoryId == 1 ||
                siteListFinal[siteIndex].master[masterIndex].categoryId == 2? DropdownButton(
              underline: Container(),
              items: (siteListFinal[siteIndex].master[masterIndex].irrigationLine ?? []).map((line) {
                return DropdownMenuItem(
                  value: line.name,
                  child: Text(line.name, style: const TextStyle(color: Colors.white, fontSize: 17),),
                );
              }).toList(),
              onChanged: (newLineName) {
                int newIndex = siteListFinal[siteIndex].master[masterIndex].irrigationLine.indexWhere((line)
                => line.name == newLineName);
                if (newIndex != -1 && siteListFinal[siteIndex].master[masterIndex].irrigationLine.length > 1) {
                  setState(() {
                    _myCurrentIrrLine = newLineName!;
                    lineIndex = newIndex;
                  });
                }
              },
              value: _myCurrentIrrLine,
              dropdownColor: Colors.teal,
              iconEnabledColor: Colors.white,
              iconDisabledColor: Colors.white,
              focusColor: Colors.transparent,
            ):
            const SizedBox(),

            const SizedBox(width: 15,),
            Container(width: 1, height: 20, color: Colors.white54,),
            const SizedBox(width: 5,),
            Text('Last sync : ${'${siteListFinal[siteIndex].master[masterIndex].liveSyncDate} - ${siteListFinal[siteIndex].master[masterIndex].liveSyncTime}'}', style: const TextStyle(fontSize: 15),),
          ],
        ),
        leadingWidth: 75,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.clamp,
              colors: [myTheme.primaryColorDark, myTheme.primaryColor], // Define your gradient colors
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              siteListFinal[siteIndex].master[masterIndex].irrigationLine.length>1 && Provider.of<MqttPayloadProvider>(context).currentSchedule.isNotEmpty?
              CircleAvatar(
                radius: 15,
                backgroundImage: const AssetImage('assets/GifFile/water_drop_ani.gif'),
                backgroundColor: Colors.blue.shade100,
              ):
              const SizedBox(),
              const SizedBox(width: 10,),
              
              siteListFinal[siteIndex].master[masterIndex].irrigationLine.length>1? TextButton(
                onPressed: () {
                  String strPRPayload = '';
                  for (int i = 0; i < payload2408.length; i++) {
                    if (allIrrigationResumeFlag) {
                      strPRPayload += '${payload2408[i]['S_No']},0;';
                    } else {
                      strPRPayload += '${payload2408[i]['S_No']},1;';
                    }
                  }
                  String payloadFinal = jsonEncode({
                    "4900": [{"4901": strPRPayload}]
                  });
                  MQTTManager().publish(payloadFinal, 'AppToFirmware/${siteListFinal[siteIndex].master[masterIndex].deviceId}');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(allIrrigationResumeFlag?Colors.green: Colors.orange),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    allIrrigationResumeFlag
                        ? const Icon(Icons.play_arrow_outlined, color: Colors.white)
                        : const Icon(Icons.pause, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(allIrrigationResumeFlag ? 'RESUME ALL LINE' : 'PAUSE ALL LINE',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ):
              const SizedBox(),
              const SizedBox(width: 10),
              IconButton(tooltip : 'Help & Support', onPressed: (){
                showMenu(
                  context: context,
                  color: Colors.white,
                  position: const RelativeRect.fromLTRB(100, 0, 50, 0),
                  items: <PopupMenuEntry>[
                    PopupMenuItem(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('App info'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Help'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.model_training),
                            title: const Text('Training'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.feedback_outlined),
                            title: const Text('Send feedback'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }, icon: const CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: Icon(Icons.live_help_outlined),
              )),
              IconButton(tooltip : 'Niagara Account\n${widget.customerName}\n ${widget.mobileNo}', onPressed: (){
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 0, 10, 0),
                  surfaceTintColor: myTheme.primaryColor,
                  items: <PopupMenuEntry>[
                    PopupMenuItem(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: CircleAvatar(radius: 35, backgroundColor: myTheme.primaryColor.withOpacity(0.1), child: Text(widget.customerName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 25)),),
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 70.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: myTheme.primaryColor,
                                  ),
                                  child: IconButton(
                                    tooltip:'Edit',
                                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text('Hi, ${widget.customerName}!',style: const TextStyle(fontSize: 20)),
                          Text(widget.emailId, style: const TextStyle(fontSize: 13)),
                          Text(widget.mobileNo, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 15),
                          MaterialButton(
                            color: myTheme.primaryColor,
                            textColor: Colors.white,
                            child: const Text('Manage Your Niagara Account'),
                            onPressed: () async {
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccountManagement(userID: widget.customerId, callback: callbackFunction),
                                ),
                              );

                              /*showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return AccountManagement(userID: widget.customerId, callback: callbackFunction);
                                },
                              );*/
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                tooltip:'Logout',
                                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                                onPressed: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.remove('userId');
                                  await prefs.remove('userName');
                                  await prefs.remove('userType');
                                  await prefs.remove('countryCode');
                                  await prefs.remove('mobileNumber');
                                  await prefs.remove('subscribeTopic');
                                  await prefs.remove('password');
                                  await prefs.remove('email');
                                  MQTTManager().disconnect();
                                  if (context.mounted){
                                    clearMQTTPayload();
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Add more menu items as needed
                  ],
                );
              }, icon: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: Text(widget.customerName.substring(0, 1).toUpperCase()),
              )),
            ],),
          const SizedBox(width: 05),
        ],
      ),
      backgroundColor: Colors.white,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        //color: myTheme.primaryColorLight.withOpacity(0.1),
        color: Colors.teal.shade50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationRailDestination(
                  padding: EdgeInsets.only(top: 5),
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                  label: Text(''),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.devices_other),
                  selectedIcon: Icon(Icons.devices_other, color: Colors.white),
                  label: Text(''),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.question_answer_outlined),
                  selectedIcon: Icon(Icons.question_answer_outlined, color: Colors.white,),
                  label: Text(''),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_outlined),
                  selectedIcon: Icon(Icons.receipt_outlined, color: Colors.white,),
                  label: Text(''),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wb_cloudy_outlined),
                  selectedIcon: Icon(Icons.wb_cloudy_outlined, color: Colors.white,),
                  label: Text(''),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_outlined, color: Colors.white,),
                  label: Text(''),
                ),
              ],
            ),
            Container(
              width: MediaQuery.sizeOf(context).width-140,
              height: MediaQuery.sizeOf(context).height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  tileMode: TileMode.clamp,
                  colors: [myTheme.primaryColorDark, myTheme.primaryColor],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  //color: Color(0x64C4E9EE),
                  color: Colors.teal.shade50,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  _selectedIndex == 0 ? SizedBox(child: siteListFinal[siteIndex].master[masterIndex].categoryId==1 ||
                      siteListFinal[siteIndex].master[masterIndex].categoryId==2 ?
                  CustomerDashboard(customerID: widget.customerId, type: 1, customerName: widget.customerName, userID: widget.customerId, mobileNo: widget.mobileNo, siteData: siteListFinal[siteIndex], crrIrrLine: siteListFinal[siteIndex].master[masterIndex].irrigationLine[lineIndex], masterInx: masterIndex, lineIdx: lineIndex,):
                  PumpDashboard(siteData: siteListFinal[siteIndex], masterIndex: masterIndex,)):
                  _selectedIndex == 1 ? ProductInventory(userName: widget.customerName):
                  _selectedIndex == 2 ? SentAndReceived(customerID: widget.customerId, controllerId: siteListFinal[siteIndex].master[masterIndex].controllerId):
                  _selectedIndex == 3 ? ListOfLogConfig(userId: widget.customerId, controllerId: siteListFinal[siteIndex].master[masterIndex].controllerId,):
                  _selectedIndex == 4 ? WeatherScreen(userId: widget.customerId, controllerId: siteListFinal[siteIndex].master[masterIndex].controllerId, deviceID: siteListFinal[siteIndex].master[masterIndex].deviceId,):
                  ControllerSettings(customerID: widget.customerId, siteData: siteListFinal[siteIndex], masterIndex: masterIndex, adDrId: widget.comingFrom=='AdminORDealer'? widget.userId:0,),
                ),
              ),
            ),
            Container(
              width: 60,
              height: MediaQuery.sizeOf(context).height,
              color: myTheme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  siteListFinal[siteIndex].master[masterIndex].categoryId==1 ||
                      siteListFinal[siteIndex].master[masterIndex].categoryId==2 ? CircleAvatar(
                    radius: 20,
                    backgroundColor: myTheme.primaryColorDark,
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: IconButton(tooltip:'Show node list', onPressed: (){
                        sideSheet();
                      }, icon: const Icon(Icons.menu, color: Colors.white)),
                    ),
                  ):
                  const SizedBox(),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
                    ),
                    width: 45,
                    height: 45,
                    child: IconButton(
                      tooltip: 'refresh',
                      icon: const Icon(Icons.refresh, color: Colors.white,),
                      onPressed: onRefreshClicked,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
                    ),
                    width: 45,
                    height: 45,
                    child: IconButton(
                      tooltip: '$wifiStrength %',
                      icon: Icon(wifiStrength == 0? Icons.wifi_off:
                      wifiStrength >= 1 && wifiStrength <= 20 ? Icons.network_wifi_1_bar_outlined:
                      wifiStrength >= 21 && wifiStrength <= 40 ? Icons.network_wifi_2_bar_outlined:
                      wifiStrength >= 41 && wifiStrength <= 60 ? Icons.network_wifi_3_bar_outlined:
                      wifiStrength >= 61 && wifiStrength <= 80 ? Icons.network_wifi_3_bar_outlined:
                      Icons.wifi, color: Colors.white,),
                      onPressed: null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
                    ),
                    width: 45,
                    height: 45,
                    child: IconButton(
                      tooltip: 'Manual Mode',
                      icon: const Icon(Icons.touch_app_outlined, color: Colors.white),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RunByManual(siteID: siteListFinal[siteIndex].userGroupId,
                                siteName: siteListFinal[siteIndex].groupName,
                                controllerID: siteListFinal[siteIndex].master[masterIndex].controllerId,
                                customerID: widget.customerId,
                                imeiNo: siteListFinal[siteIndex].master[masterIndex].deviceId,
                                programList: programList, callbackFunction: callbackFunction),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
                    ),
                    width: 45,
                    height: 45,
                    child: IconButton(
                      tooltip: 'Planning',
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgramSchedule(
                              customerID: widget.customerId,
                              controllerID: siteListFinal[siteIndex].master[masterIndex].controllerId,
                              siteName: siteListFinal[siteIndex].groupName,
                              imeiNumber: siteListFinal[siteIndex].master[masterIndex].deviceId,
                              userId: widget.customerId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
                    ),
                    width: 45,
                    height: 45,
                    child: IconButton(tooltip:'View all Node details', onPressed: (){
                      //showNodeDetailsBottomSheet(context);
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => AllNodeListAndDetails(userID: widget.customerId, customerID: widget.customerId, masterInx: masterIndex, siteData: siteListFinal[siteIndex],),
                        ),
                      );
                    }, icon: const Icon(Icons.grid_view, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
                    ),
                    width: 45,
                    height: 45,
                    child: BadgeButton(
                      onPressed: () {
                        if(provider.alarmList.isNotEmpty){
                          showAlarmBottomSheet(context, provider);
                        }else{
                          GlobalSnackBar.show(context, 'Alarm is Empty', 200);
                        }
                      },
                      icon: Icons.alarm,
                      badgeNumber: provider.alarmList.length,

                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void sideSheet() {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      barrierColor: const Color(0xff66000000),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SideSheetClass(customerID: widget.customerId, nodeList: siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList,
                  deviceId: siteListFinal[siteIndex].master[masterIndex].deviceId,
                  lastSyncDate: '${siteListFinal[siteIndex].master[masterIndex].liveSyncDate} - ${siteListFinal[siteIndex].master[masterIndex].liveSyncTime}',
                  deviceName: siteListFinal[siteIndex].master[masterIndex].categoryName,);
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
          child: child,
        );
      },
    );
  }

  Future<void>showNodeDetailsBottomSheet(BuildContext context) async{
    //print(siteListFinal[siteIndex].nodeList);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return  SizedBox(
          height: 600,
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                ),
                surfaceTintColor: Colors.white,
                margin: EdgeInsets.zero,
                child: ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                  ),
                  tileColor: myTheme.primaryColor,
                  textColor: Colors.white,
                  title: const Text('All Node Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list, color: Colors.white,),
                    onSelected: (value) {
                      print('Filter option selected: $value');
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Sort by Active relay',
                        child: Text('Sort by Active relays'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Sort by In-Active relays',
                        child: Text('Sort by In-Active relays'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Others',
                        child: Text('Others'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: [
                    for (int i = 0; i < siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList.length; i++)
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
                              title: Text('${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].categoryName} - ${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].deviceId}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.solar_power_outlined),
                                  const SizedBox(width: 5,),
                                  Text('${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].sVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                  const SizedBox(width: 5,),
                                  const Icon(Icons.battery_3_bar_rounded),
                                  Text('${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                  const SizedBox(width: 5,),
                                  IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                    String payLoadFinal = jsonEncode({
                                      "2300": [
                                        {"2301": "${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].serialNumber}"},
                                      ]
                                    });
                                    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].master[masterIndex].deviceId}');
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
                                  itemCount: siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("SP") ?
                                          const AssetImage('assets/images/irrigation_pump.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("IP") ?
                                          const AssetImage('assets/images/irrigation_pump.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("VL") ?
                                          const AssetImage('assets/images/valve_gray.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("MV") ?
                                          const AssetImage('assets/images/dp_main_valve.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("FL") ?
                                          const AssetImage('assets/images/dp_filter.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("FC") ?
                                          const AssetImage('assets/images/fert_chanel.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("FG") ?
                                          const AssetImage('assets/images/fogger.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("FB") ?
                                          const AssetImage('assets/images/booster_pump.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("AG") ?
                                          const AssetImage('assets/images/dp_agitator_gray.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("DV") ?
                                          const AssetImage('assets/images/downstream_valve.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("SL") ?
                                          const AssetImage('assets/images/selector.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("FN") ?
                                          const AssetImage('assets/images/fan.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("LI") ?
                                          const AssetImage('assets/images/pressure_sensor.png'):
                                          siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!.contains("LO") ?
                                          const AssetImage('assets/images/pressure_sensor.png'):
                                          const AssetImage('assets/images/pressure_sensor.png'),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.grey,
                                            ),
                                            const SizedBox(width: 3),
                                            Text('${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].name!}(${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].rlyStatus[index].rlyNo})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].sensor.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Stack(
                                            children: [
                                              AppImages.getAsset('sensor',0, siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].sensor[index].Name!),
                                              Positioned(
                                                top: 25,
                                                left: 0,
                                                child: Container(width: 40, height: 14,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Colors.yellow,
                                                    ),
                                                    child: Center(child: Text('${siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].sensor[index].Value}', style: const TextStyle(color: Colors.black, fontSize: 10)))
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(siteListFinal[siteIndex].master[masterIndex].liveData[0].nodeList[i].sensor[index].Name!, style: const TextStyle(color: Colors.black, fontSize: 10)),
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

  Future<void>showAlarmBottomSheet(BuildContext context, MqttPayloadProvider provider) async{
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return  SizedBox(
          height: 300,
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                ),
                surfaceTintColor: Colors.white,
                margin: EdgeInsets.zero,
                child: ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                  ),
                  tileColor: myTheme.primaryColor,
                  textColor: Colors.white,
                  title: const Text('Alarm List'),
                ),
              ),
              Expanded(
                flex: 1,
                child: provider.alarmList.isNotEmpty? DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  dataRowHeight: 45.0,
                  headingRowHeight: 35.0,
                  headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                  columns: const [
                    DataColumn2(
                      label: Text('S-No', style: TextStyle(fontSize: 13),),
                      fixedWidth: 50,
                    ),
                    DataColumn2(
                        label: Text('', style: TextStyle(fontSize: 13)),
                        fixedWidth: 40,
                    ),
                    DataColumn2(
                        label: Text('Message', style: TextStyle(fontSize: 13),),
                        size: ColumnSize.L
                    ),
                    DataColumn2(
                        label: Text('Location', style: TextStyle(fontSize: 13),),
                        size: ColumnSize.L
                    ),
                    DataColumn2(
                      label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
                      fixedWidth: 80,
                    ),
                  ],
                  rows: List<DataRow>.generate(provider.alarmList.length, (index) => DataRow(cells: [
                    DataCell(Text('${index+1}')),
                    DataCell(Icon(Icons.warning_amber, color: provider.alarmList[index]['Status']==1 ? Colors.orangeAccent : Colors.redAccent,)),
                    DataCell(Text(getAlarmMessage(provider.alarmList[index]['AlarmType']))),
                    DataCell(Text(provider.alarmList[index]['Location'])),
                    DataCell(Center(child: MaterialButton(
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      onPressed: (){
                        String payload =  '${provider.alarmList[index]['S_No']}';
                        String payLoadFinal = jsonEncode({
                          "4100": [{"4101": payload}]
                        });
                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].master[masterIndex].deviceId}');

                      },
                      child: const Text('Reset'),
                    ))),
                  ])),
                ):
                const Center(child: Text('Alarm not found'),),
              )
            ],
          ),
        );
      },
    );
  }

  String getAlarmMessage(int alarmType) {
    String msg = '';
    switch (alarmType) {
      case 1:
        msg ='Low Flow';
        break;
      case 2:
        msg ='High Flow';
        break;
      case 3:
        msg ='No Flow';
        break;
      case 4:
        msg ='Ec High';
        break;
      case 5:
        msg ='Ph Low';
        break;
      case 6:
        msg ='Ph High';
        break;
      case 7:
        msg ='Pressure Low';
        break;
      case 8:
        msg ='Pressure High';
        break;
      case 9:
        msg ='No Power Supply';
        break;
      case 10:
        msg ='No Communication';
        break;
      case 11:
        msg ='Wrong Feedback';
        break;
      default:
        msg ='alarmType default';
    }
    return msg;
  }

  Widget buildLoadingIndicator(bool isVisible, double width)
  {
    return Visibility(
      visible: isVisible,
      child: Center(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ),
    );
  }

  void indicatorViewShow() {
    setState((){
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    if(mounted){
      setState(() {
        visibleLoading = false;
      });
    }
  }

}


class BadgeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final int badgeNumber;

  const BadgeButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.badgeNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          tooltip: 'Alarm list',
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white,),
        ),
        if (badgeNumber > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}


class SideSheetClass extends StatefulWidget {
  const SideSheetClass({Key? key, required this.customerID, required this.nodeList, required this.deviceId, required this.lastSyncDate, required this.deviceName}) : super(key: key);
  final int customerID;
  final String deviceId, deviceName, lastSyncDate;
  final List<NodeData> nodeList;


  @override
  State<SideSheetClass> createState() => _SideSheetClassState();
}

class _SideSheetClassState extends State<SideSheetClass> {

  String lastSyncData = '';

  @override
  Widget build(BuildContext context) {

    final nodeList = Provider.of<MqttPayloadProvider>(context).nodeList;
    try{
      for (var item in nodeList) {
        if (item is Map<String, dynamic>) {
          try {
            int position = getNodeListPosition(item['SNo']);
            if (position != -1) {
              widget.nodeList[position].status = item['Status'];
              widget.nodeList[position].batVolt = item['BatVolt'];
              widget.nodeList[position].sVolt = item['SVolt'];
              widget.nodeList[position].lastFeedbackReceivedTime = item['LastFeedbackReceivedTime'];
              widget.nodeList[position].rlyStatus = [];
              List<dynamic> rlyList = item['RlyStatus'];
              List<RelayStatus> rlyStatusList = rlyList.isNotEmpty? rlyList.map((rl) => RelayStatus.fromJson(rl)).toList() : [];
              widget.nodeList[position].rlyStatus = rlyStatusList;
            } else {
              print('${item['SNo']} The serial number not found');
            }
          } catch (e) {
            print('Error updating node properties: $e');
          }
        }
      }
      setState(() {
        widget.nodeList;
      });
    }
    catch(e){
      print(e);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      height: MediaQuery.sizeOf(context).height,
      width: 400,
      child: SingleChildScrollView(
        child:Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const Text('NODE LIST', style: TextStyle(color: Colors.black, fontSize: 15)),
            const Divider(),
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
                              Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 5),
                              CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                              SizedBox(width: 5),
                              Text('No Communication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
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
                              Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 10),
                              CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                              SizedBox(width: 5),
                              Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          tooltip: 'Set serial for all Nodes',
                          icon: Icon(Icons.format_list_numbered, color: myTheme.primaryColorDark),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text('Are you sure! you want to proceed to reset all node ids?'),
                                  actions: <Widget>[
                                    MaterialButton(
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    MaterialButton(
                                      color: myTheme.primaryColor,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        String payLoadFinal = jsonEncode({
                                          "2300": [
                                            {"2301": ""},
                                          ]
                                        });
                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                        GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          tooltip: 'Test Communication',
                          icon: Icon(Icons.network_check, color: myTheme.primaryColorDark),
                          onPressed: () async {
                            String payLoadFinal = jsonEncode({
                              "4500": [{"4501": ""},]
                            });
                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                            GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                            //Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 400,
              height: MediaQuery.sizeOf(context).height-150,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 325,
                dataRowHeight: 40.0,
                headingRowHeight: 35.0,
                headingRowColor: MaterialStateProperty.all<Color>(myTheme.primaryColorDark.withOpacity(0.2)),
                columns: const [
                  DataColumn2(
                      label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                      fixedWidth: 35
                  ),
                  DataColumn2(
                    label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                    fixedWidth: 55,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Rf.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                    fixedWidth: 45,
                  ),
                  DataColumn2(
                    label: Text('Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                    size: ColumnSize.M,
                    numeric: true,
                  ),
                  DataColumn2(
                    label: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                    fixedWidth: 40,
                  ),
                ],
                rows: List<DataRow>.generate(widget.nodeList.length, (index) => DataRow(cells: [
                  DataCell(Center(child: Text('${widget.nodeList[index].serialNumber}', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),))),
                  DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                  widget.nodeList[index].status == 1? Colors.green.shade400:
                  widget.nodeList[index].status == 2? Colors.grey:
                  widget.nodeList[index].status == 3? Colors.redAccent:
                  widget.nodeList[index].status == 4? Colors.yellow:
                  Colors.grey,
                  ))),
                  DataCell(Center(child: Text('${widget.nodeList[index].referenceNumber}', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black)))),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
                      Text(widget.nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.black)),
                    ],
                  )),
                  DataCell(Center(child: IconButton(tooltip: 'View Relay status',
                    icon: widget.nodeList[index].rlyStatus.any((rly) => rly.Status == 2 || rly.Status == 3)? const Icon(Icons.warning, color: Colors.orangeAccent):
                    Icon(Icons.info_outline, color: myTheme.primaryColorDark), // Icon to display
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: double.infinity,
                            height: 270,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ListTile(
                                  tileColor: myTheme.primaryColor,
                                  textColor: Colors.white,
                                  leading: const Icon(Icons.developer_board_rounded, color: Colors.white),
                                  title: Text('${widget.nodeList[index].categoryName} - ${widget.nodeList[index].deviceId}'),
                                  subtitle: Text(formatDateTime(widget.nodeList[index].lastFeedbackReceivedTime)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.solar_power_outlined, color: Colors.white),
                                      const SizedBox(width: 5,),
                                      Text('${widget.nodeList[index].sVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(width: 5,),
                                      const Icon(Icons.battery_3_bar_rounded, color: Colors.white),
                                      const SizedBox(width: 5,),
                                      Text('${widget.nodeList[index].batVolt} Volt', style: const TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(width: 5,),
                                      IconButton(tooltip : 'Serial set for all Relay', onPressed: (){
                                        String payLoadFinal = jsonEncode({
                                          "2300": [
                                            {"2301": "${widget.nodeList[index].serialNumber}"},
                                          ]
                                        });
                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                      }, icon: Icon(Icons.fact_check_outlined, color: Colors.white))
                                    ],
                                  ),
                                ),
                                Column(
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
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      width: double.infinity,
                                      height : widget.nodeList[index].rlyStatus.length > 8? 160 : 80,
                                      child: GridView.builder(
                                        itemCount: widget.nodeList[index].rlyStatus.length, // Number of items in the grid
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          crossAxisSpacing: 05.0,
                                          mainAxisSpacing: 05.0,
                                        ),
                                        itemBuilder: (BuildContext context, int indexGv) {
                                          print(widget.nodeList[index].rlyStatus[indexGv].name);
                                          return Column(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: widget.nodeList[index].rlyStatus[indexGv].Status==0 ? Colors.grey :
                                                widget.nodeList[index].rlyStatus[indexGv].Status==1 ? Colors.green :
                                                widget.nodeList[index].rlyStatus[indexGv].Status==2 ? Colors.orange :
                                                widget.nodeList[index].rlyStatus[indexGv].Status==3 ? Colors.redAccent : Colors.black12, // Avatar background color
                                                child: Text((widget.nodeList[index].rlyStatus[indexGv].rlyNo).toString(), style: const TextStyle(color: Colors.white)),
                                              ),
                                              Text((widget.nodeList[index].rlyStatus[indexGv].name).toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
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
    );
  }

  int getNodeListPosition(int srlNo){
    List<NodeData> nodeList = widget.nodeList;
    for (int i = 0; i < nodeList.length; i++) {
      if (nodeList[i].serialNumber == srlNo) {
        return i;
      }
    }
    return -1;
  }

  String formatDateTime(String? dateTimeString) {
    print('dateTimeString:$dateTimeString');
    if (dateTimeString == null) {
      return "No feedback received";
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return "Invalid date format";
    }
  }
}
