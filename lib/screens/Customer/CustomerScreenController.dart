import 'dart:async';
import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/screens/Customer/Dashboard/SentAndReceived.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../Models/language.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/UserData.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import '../product_inventory.dart';
import 'AccountManagement.dart';
import 'CustomerDashboard.dart';
import 'Dashboard/RunByManual.dart';
import 'ProgramSchedule.dart';


class CustomerScreenController extends StatefulWidget {
  const CustomerScreenController({Key? key, required this.customerID, required this.customerName, required this.mobileNo, required this.comingFrom}) : super(key: key);
  final int customerID;
  final String customerName, mobileNo, comingFrom;

  @override
  _CustomerScreenControllerState createState() => _CustomerScreenControllerState();
}

class _CustomerScreenControllerState extends State<CustomerScreenController> with SingleTickerProviderStateMixin
{
  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  bool loadingSite = true;
  bool visibleLoading = false;
  int _selectedIndex = 0;

  late AnimationController animationController;
  late Animation<double> rotationAnimation;
  List<ProgramList> programList = [];

  int wifiStrength = 0;
  String lastSyncData = '';

  final List<LanguageList> languageList = <LanguageList>[];
  String _mySelection = 'English';


  @override
  void initState() {
    super.initState();
    initRotationAnimation();
    clearMQTTPayload();
    getLanguage();
    getCustomerSite(widget.customerID);
    getProgramList();
  }

  void callbackFunction(message)
  {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      animationController.stop();
      String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
    });
  }

  void clearMQTTPayload(){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    //payloadProvider.mainLine=[];
    payloadProvider.currentSchedule=[];
    payloadProvider.PrsIn=[];
    payloadProvider.PrsOut=[];
    payloadProvider.nextSchedule=[];
    payloadProvider.upcomingProgram=[];
    payloadProvider.filtersCentral=[];
    payloadProvider.filtersLocal=[];
    payloadProvider.irrigationPump=[];
    payloadProvider.fertilizerCentral=[];
    payloadProvider.fertilizerLocal=[];
    payloadProvider.waterMeter=[];
    payloadProvider.wifiStrength = 0;
    payloadProvider.alarmList = [];
    payloadProvider.payload2408 = [];

  }

  Future<void> getLanguage() async
  {
    final response = await HttpService().postRequest("getLanguageByActive", {"active": '1'});
    if (response.statusCode == 200)
    {
      languageList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          languageList.add(LanguageList.fromJson(cntList[i]));
        }
      }
      indicatorViewHide();
    }
    else{
      indicatorViewHide();
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
      //print(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        try {
          siteListFinal = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          setState((){
            loadingSite = false;
          });
          subscribeAndUpdateSite();
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

  Future<void> getProgramList() async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": siteListFinal[siteIndex].controllerId};
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void subscribeAndUpdateSite() {
    indicatorViewShow();
    Future.delayed(const Duration(seconds: 3), () {
      MQTTManager().subscribeToTopic('FirmwareToApp/${siteListFinal[siteIndex].deviceId}');
      indicatorViewHide();
    });

  }

  @override
  Widget build(BuildContext context)
  {
    final screenWidth = MediaQuery.of(context).size.width;
    final provider = Provider.of<MqttPayloadProvider>(context);

    /*print('userId :${widget.customerID}');
    print('controllerId :${siteListFinal[siteIndex].controllerId}');*/

    if(widget.comingFrom == 'AdminORDealer'){

      return loadingSite? buildLoadingIndicator(loadingSite, screenWidth):
      Scaffold(
        appBar: AppBar(
          title: Text('${widget.customerName} - DASHBOARD'),
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
                IconButton(tooltip : 'Site List', onPressed: (){
                  showMenu(
                    context: context,
                    color: Colors.white,
                    position: const RelativeRect.fromLTRB(100, 0, 30, 0),
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Column(
                          children: (siteListFinal ?? []).map((site) {
                            int index = siteListFinal.indexOf(site);
                            return ListTile(
                              leading: Image.asset('assets/images/oro_gem.png', width: 30, height: 30,),
                              title: Text(site.siteName),
                              subtitle: Text('Controller : ${site.deviceName}\nModel : ${site.modelName}\nController ID : ${site.deviceId}'),
                              onTap: () {
                                if(siteListFinal.length>1){
                                  clearMQTTPayload();
                                  siteIndex = index;
                                  subscribeAndUpdateSite();
                                }
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }, icon: CircleAvatar(
                  radius: 17.5,
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/oro_gem.png', width: 25, height: 25,),
                )),
              ],),
            const SizedBox(width: 05),
          ],
        ),
        backgroundColor: Colors.white,
        extendBody: true,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomerDashboard(customerID: widget.customerID, type: 0, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex]),
            )),
            Container(
              width: 60,
              height: MediaQuery.sizeOf(context).height,
              color: myTheme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: myTheme.primaryColorDark,
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: IconButton(tooltip:'Show node list', onPressed: (){
                        sideSheet();
                      }, icon: const Icon(Icons.menu, color: Colors.white)),
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
                    child: RotationTransition(
                      turns: rotationAnimation,
                      child: IconButton(
                        tooltip: 'refresh',
                        icon: Icon(Icons.refresh, color: Colors.white,),
                        onPressed: onRefreshClicked,
                      ),
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
                      wifiStrength >= 61 && wifiStrength <= 80 ? Icons.network_wifi_outlined:
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
                            builder: (context) => RunByManual(siteID: siteListFinal[siteIndex].siteId,
                                siteName: siteListFinal[siteIndex].siteName,
                                controllerID: siteListFinal[siteIndex].controllerId,
                                customerID: widget.customerID,
                                imeiNo: siteListFinal[siteIndex].deviceId,
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
                      showNodeDetailsBottomSheet(context);
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
                        showAlarmBottomSheet(context, provider);
                      },
                      icon: Icons.alarm,
                      badgeNumber: provider.alarmList.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

    }else{

      final userData = UserData.of(context)!;
      return loadingSite? buildLoadingIndicator(loadingSite, screenWidth):
      Scaffold(
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Image(image: AssetImage("assets/images/oro_logo_white.png")),
          ),
          title:  Center(child: Text(siteListFinal[siteIndex].siteName, style: const TextStyle(fontSize: 20),)),
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
                TextButton(
                  onPressed: () {
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade300),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pause, color: Colors.white),
                      SizedBox(width:5),
                      Text('PAUSE', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(tooltip : 'Help & Support', onPressed: (){
                  showMenu(
                    context: context,
                    color: Colors.white,
                    position: const RelativeRect.fromLTRB(100, 0, 95, 0),
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
                            ListTile(
                              leading: const Icon(Icons.update),
                              title: const Text('Updates'),
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
                IconButton(tooltip : 'App Settings', onPressed: (){
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 0, 70, 0),
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Language'),
                              leading: Icon(Icons.language, color: myTheme.primaryColor,),
                              trailing: DropdownButton(
                                items: languageList.map((item) {
                                  return DropdownMenuItem(
                                    value: item.languageName,
                                    child: Text(item.languageName),
                                  );
                                }).toList(),
                                onChanged: (newVal) {
                                  setState(() {
                                    _mySelection = newVal!;
                                  });
                                },
                                value: _mySelection,
                              ),
                            ),
                            ListTile(
                              title: const Text('Theme(Light/Dark)'),
                              leading: Icon(Icons.color_lens_outlined,  color: myTheme.primaryColor,),
                              onTap: (){
                                Navigator.pop(context);
                                ThemeData initialTheme = Theme.of(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => ThemeChangeDialog(initialTheme: initialTheme),
                                );
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
                  child: Icon(Icons.settings_outlined),
                )),
                IconButton(tooltip : 'Niagara Account\n${userData.userName}\n+${userData.countryCode} ${userData.mobileNo}', onPressed: (){
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
                                  child: CircleAvatar(radius: 35, backgroundColor: myTheme.primaryColor.withOpacity(0.1), child: Text(userData.userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 25)),),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  right: 70.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle, // Optional: Makes the container circular
                                      color: myTheme.primaryColor, // Set the background color here
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
                            Text('Hi, ${userData.userName}!',style: const TextStyle(fontSize: 20)),
                            Text(userData.userEmailId, style: const TextStyle(fontSize: 13)),
                            Text('+${userData.countryCode} ${userData.mobileNo}', style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 15),
                            MaterialButton(
                              color: myTheme.primaryColor,
                              textColor: Colors.white,
                              child: const Text('Manage Your Niagara Account'),
                              onPressed: () async {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AccountManagement(userID: userData.userId, callback: callbackFunction);
                                  },
                                );
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
                  child: Text(userData.userName.substring(0, 1).toUpperCase()),
                )),
                IconButton(tooltip : 'Site List', onPressed: (){
                  showMenu(
                    context: context,
                    color: Colors.white,
                    position: const RelativeRect.fromLTRB(100, 0, 30, 0),
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Column(
                          children: (siteListFinal ?? []).map((site) {
                            int index = siteListFinal.indexOf(site);
                            return ListTile(
                              leading: Image.asset('assets/images/oro_gem.png', width: 30, height: 30,),
                              title: Text(site.siteName),
                              subtitle: Text('Controller : ${site.deviceName}\nModel : ${site.modelName}\nController ID : ${site.deviceId}'),
                              onTap: () {
                                if(siteListFinal.length>1){
                                  clearMQTTPayload();
                                  siteIndex = index;
                                  subscribeAndUpdateSite();
                                }
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }, icon: CircleAvatar(
                  radius: 17.5,
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/oro_gem.png', width: 25, height: 25,),
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
          color: myTheme.primaryColorLight.withOpacity(0.1),
          child: visibleLoading ? buildLoadingIndicator(visibleLoading, screenWidth) : Row(
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
                    icon: Icon(Icons.message_outlined),
                    selectedIcon: Icon(Icons.message_outlined, color: Colors.white,),
                    label: Text(''),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.stacked_bar_chart),
                    selectedIcon: Icon(Icons.stacked_bar_chart, color: Colors.white,),
                    label: Text(''),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.question_answer_outlined),
                    selectedIcon: Icon(Icons.question_answer_outlined, color: Colors.white,),
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
                  decoration: const BoxDecoration(
                    color: Color(0xffefefef),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)), // Adjust the radius as needed
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _selectedIndex == 0 ? CustomerDashboard(customerID: widget.customerID, type: 1, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex]) :
                    _selectedIndex == 1 ? ProductInventory(userName: widget.customerName):
                    _selectedIndex == 2 ? ProductInventory(userName: widget.customerName):
                    _selectedIndex == 3 ?  ProductInventory(userName: widget.customerName):
                    _selectedIndex == 4 ?  SentAndReceived(customerID: widget.customerID, controllerId: siteListFinal[siteIndex].controllerId):
                    ProductInventory(userName: widget.customerName),
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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: myTheme.primaryColorDark,
                      child: SizedBox(
                        height: 45,
                        width: 45,
                        child: IconButton(tooltip:'Show node list', onPressed: (){
                          sideSheet();

                        }, icon: const Icon(Icons.menu, color: Colors.white)),
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
                      child: RotationTransition(
                        turns: rotationAnimation,
                        child: IconButton(
                          tooltip: 'refresh',
                          icon: Icon(Icons.refresh, color: Colors.white,),
                          onPressed: onRefreshClicked,
                        ),
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
                        wifiStrength >= 61 && wifiStrength <= 80 ? Icons.network_wifi_outlined:
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
                              builder: (context) => RunByManual(siteID: siteListFinal[siteIndex].siteId,
                                  siteName: siteListFinal[siteIndex].siteName,
                                  controllerID: siteListFinal[siteIndex].controllerId,
                                  customerID: widget.customerID,
                                  imeiNo: siteListFinal[siteIndex].deviceId,
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
                        showNodeDetailsBottomSheet(context);
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
                        badgeNumber: provider.alarmList.length, // Set your badge number here
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
                return SideSheetClass(customerID: widget.customerID, siteData: siteListFinal[siteIndex],);
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
                    icon: Icon(Icons.filter_list, color: Colors.white,),
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
                                  itemCount: siteListFinal[siteIndex].nodeList[i].rlyStatus.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("SP") ?
                                          const AssetImage('assets/images/dp_src_pump.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("IP") ?
                                          const AssetImage('assets/images/irrigation_pump.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("VL") ?
                                          const AssetImage('assets/images/valve_gray.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("MV") ?
                                          const AssetImage('assets/images/dp_main_valve.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("FL") ?
                                          const AssetImage('assets/images/dp_filter.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("FC") ?
                                          const AssetImage('assets/images/fert_chanel.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("FG") ?
                                          const AssetImage('assets/images/fogger.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("FB") ?
                                          const AssetImage('assets/images/booster_pump.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("AG") ?
                                          const AssetImage('assets/images/dp_agitator_gray.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("DV") ?
                                          const AssetImage('assets/images/downstream_valve.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("SL") ?
                                          const AssetImage('assets/images/selector.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("FN") ?
                                          const AssetImage('assets/images/fan.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("LI") ?
                                          const AssetImage('assets/images/pressure_sensor.png'):
                                          siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name'].contains("LO") ?
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
                                            Text('${siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['Name']}(${siteListFinal[siteIndex].nodeList[i].rlyStatus[index]['RlyNo']})', style: const TextStyle(color: Colors.black, fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: siteListFinal[siteIndex].nodeList[i].sensor.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                            backgroundImage:  siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("SM") ?
                                            const AssetImage('assets/images/dp_src_pump.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("IF") ?
                                            const AssetImage('assets/images/irrigation_pump.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("LI") ?
                                            const AssetImage('assets/images/irrigation_pump.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("LO") ?
                                            const AssetImage('assets/images/irrigation_pump.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("LW") ?
                                            const AssetImage('assets/images/irrigation_pump.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("PSP") ?
                                            const AssetImage('assets/images/irrigation_pump.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("EC") ?
                                            const AssetImage('assets/images/pressure_sensor.png') :
                                            siteListFinal[siteIndex].nodeList[i].sensor[index]['Name'].contains("PH") ?
                                            const AssetImage('assets/images/pressure_sensor.png') :
                                            const AssetImage('assets/images/irrigation_pump.png')
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor: siteListFinal[siteIndex].nodeList[i].sensor[index]['Status']==0 ? Colors.grey :
                                              siteListFinal[siteIndex].nodeList[i].sensor[index]['Status']==1 ? Colors.green :
                                              siteListFinal[siteIndex].nodeList[i].sensor[index]['Status']==2 ? Colors.orange :
                                              siteListFinal[siteIndex].nodeList[i].sensor[index]['Status']==3 ? Colors.redAccent : Colors.black12,
                                            ),
                                            const SizedBox(width: 3),
                                            Text('${siteListFinal[siteIndex].nodeList[i].sensor[index]['Name']}(${siteListFinal[siteIndex].nodeList[i].sensor[index]['AngIpNo']})', style: const TextStyle(color: Colors.black, fontSize: 10)),
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
                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');

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
      default:
        msg ='alarmType default';
    }

    return msg;
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

class ThemeChangeDialog extends StatefulWidget {
  final ThemeData initialTheme;
  ThemeChangeDialog({super.key, required this.initialTheme});

  @override
  _ThemeChangeDialogState createState() => _ThemeChangeDialogState();
}

class _ThemeChangeDialogState extends State<ThemeChangeDialog> {
  late ThemeData _selectedTheme;

  @override
  void initState() {
    _selectedTheme = widget.initialTheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
            title: Container(
              color: Colors.cyan,
              width: 150,
              height: 75,
              child: const Center(child: Text('Theme cyan')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.yellow,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme yellow')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.green,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme green')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.pink,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme pink')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          RadioListTile(
            title: Container(
              color: Colors.purple,
              width: 150,
              height: 75,
              child: Center(child: const Text('Theme purple')),
            ),
            value: ThemeData.light(),
            groupValue: _selectedTheme,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        MaterialButton(
          onPressed: () {
            // Update the theme and close the dialog
            //ThemeController().updateTheme(_selectedTheme);
            Navigator.pop(context);
          },
          child: Text('OK'),
        ),
      ],
    );
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
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeNumber.toString(),
                style: TextStyle(
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
  const SideSheetClass({Key? key, required this.customerID, required this.siteData}) : super(key: key);
  final int customerID;
  final DashboardModel siteData;


  @override
  State<SideSheetClass> createState() => _SideSheetClassState();
}

class _SideSheetClassState extends State<SideSheetClass> {

  String lastSyncData = '';

  @override
  Widget build(BuildContext context) {

    var provider = Provider.of<MqttPayloadProvider>(context, listen: true);
    try{
      Map<String, dynamic> data = jsonDecode(provider.receivedDashboardPayload);
      setState(() {
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
                    print('rlyStatusJsonList:${rlyStatusJsonList}');
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

    return provider.receivedDashboardPayload.isNotEmpty ? Container(
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
            CircleAvatar(
              radius: 30,
              backgroundColor:myTheme.primaryColorDark.withOpacity(0.2),
              child: Image.asset('assets/images/oro_gem.png', width: 40, height: 40,),
            ),
            Text(widget.siteData.deviceName, style: const TextStyle(color: Colors.black, fontSize: 13)),
            Text('${widget.siteData.categoryName} - Last sync : $lastSyncData', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: Colors.black,),),
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
                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
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
                              "4500": [
                                {"4501": ""},
                              ]
                            });
                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.deviceId}');
                            GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                            Navigator.of(context).pop();
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
              height: 400,
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
                rows: List<DataRow>.generate(widget.siteData.nodeList.length, (index) => DataRow(cells: [
                  DataCell(Center(child: Text('${widget.siteData.nodeList[index].serialNumber}', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),))),
                  DataCell(Center(child: CircleAvatar(radius: 7, backgroundColor:
                  widget.siteData.nodeList[index].status == 1 ? Colors.green.shade400:
                  widget.siteData.nodeList[index].status == 2 ? Colors.grey :
                  widget.siteData.nodeList[index].status == 3 ? Colors.redAccent :
                  widget.siteData.nodeList[index].status == 4 ? Colors.yellow :
                  Colors.grey,
                  ))),
                  DataCell(Center(child: Text('${widget.siteData.nodeList[index].referenceNumber}', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)))),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.siteData.nodeList[index].categoryName, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
                      Text(widget.siteData.nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.black)),
                    ],
                  )),
                  DataCell(Center(child: IconButton(tooltip: 'View Relay status',
                    icon: widget.siteData.nodeList[index].rlyStatus.any((rly) => rly.status == 2 || rly.status == 3)? const Icon(Icons.warning, color: Colors.orangeAccent):
                    Icon(Icons.info_outline, color: myTheme.primaryColorDark), // Icon to display
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
                                                    backgroundColor: widget.siteData.nodeList[index].rlyStatus[indexGv]['Status']==0 ? Colors.grey :
                                                    widget.siteData.nodeList[index].rlyStatus[indexGv]['Status']==1 ? Colors.green :
                                                    widget.siteData.nodeList[index].rlyStatus[indexGv]['Status']==2 ? Colors.orange :
                                                    widget.siteData.nodeList[index].rlyStatus[indexGv]['Status']==3 ? Colors.redAccent : Colors.black12, // Avatar background color
                                                    child: Text((widget.siteData.nodeList[index].rlyStatus[indexGv]['RlyNo']).toString(), style: const TextStyle(color: Colors.white)),
                                                  ),
                                                  Text((widget.siteData.nodeList[index].rlyStatus[indexGv]['Name']).toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
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
    ):
    Container(
        height: MediaQuery.sizeOf(context).height,
        width: 400,
        color: Colors.white,
        child: const Center(child: Text('Loading datas...'))
    );
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
}
