import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/language.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/UserData.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../../state_management/MqttPayloadProvider.dart';
import '../product_inventory.dart';
import 'AccountManagement.dart';
import 'CustomerDashboard.dart';


class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.customerName, required this.mobileNo, required this.comingFrom}) : super(key: key);
  final int customerID;
  final String customerName, mobileNo, comingFrom;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with SingleTickerProviderStateMixin
{
  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  bool loadingSite = true;
  bool visibleLoading = false;
  int _selectedIndex = 0;

  final List<LanguageList> languageList = <LanguageList>[];
  String _mySelection = 'English';


  @override
  void initState() {
    super.initState();
    clearMQTTPayload();
    getLanguage();
    getCustomerSite(widget.customerID);
  }

  void clearMQTTPayload(){
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    payloadProvider.mainLine=[];
    payloadProvider.currentSchedule=[];
    payloadProvider.PrsIn=[];
    payloadProvider.PrsOut=[];
    payloadProvider.nextSchedule=[];
    payloadProvider.upcomingProgram=[];
    payloadProvider.filtersCentral=[];
    payloadProvider.filtersLocal=[];
    payloadProvider.irrigationPump=[];
    payloadProvider.fertilizerCentral=[];
    payloadProvider.flowMeter=[];
    payloadProvider.wifiStrength = 0;
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

  void callbackFunction(message)
  {
    Navigator.pop(context);
    _showSnackBar(message);
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
    if(widget.comingFrom == 'AdminORDealer'){

      final screenWidth = MediaQuery.of(context).size.width;

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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: myTheme.primaryColorLight.withOpacity(0.1),
          child: CustomerDashboard(customerID: widget.customerID, type: 0, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex]),
        ),
      );

    }else{
      final screenWidth = MediaQuery.of(context).size.width;
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
              Expanded(
                child:
                _selectedIndex == 0 ? CustomerDashboard(customerID: widget.customerID, type: 1, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex]) :
                _selectedIndex == 1 ? ProductInventory(userName: widget.customerName) :
                _selectedIndex == 2 ? ProductInventory(userName: widget.customerName):
                _selectedIndex == 3 ?  ProductInventory(userName: widget.customerName) :  ProductInventory(userName: widget.customerName),
              ),
            ],
          ),
        ),
      );
    }

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
          child: Text('Cancel'),
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