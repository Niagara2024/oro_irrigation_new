import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Forms/create_account.dart';
import 'package:oro_irrigation_new/screens/product_inventory.dart';
import 'package:oro_irrigation_new/screens/web_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Customer/Dashboard/DashboardNode.dart';
import '../Models/language.dart';
import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../state_management/MqttPayloadProvider.dart';
import 'Customer/AccountManagement.dart';
import 'Customer/Dashboard/SentAndReceived.dart';
import 'Customer/Dashboard/FarmSettings.dart';
import 'Customer/customer_home.dart';
import 'my_preference.dart';
import 'product_entry.dart';
import 'AdminDealerHomePage.dart';
import 'login_form.dart';


enum Calendar { day, week, month, year }

class MainDashBoard extends StatelessWidget
{
  const MainDashBoard({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      routes: {
        '/': (context) => const DashBoardMain(),
        '/login': (context) => const LoginForm(),
      },
    );
  }
}


class DashBoardMain extends StatefulWidget
{
  const DashBoardMain({super.key});

  @override
  DashBoardMainState createState() => DashBoardMainState();
}

class DashBoardMainState extends State<DashBoardMain> with TickerProviderStateMixin
{
  late MqttPayloadProvider payloadProvider;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();
    manager = MQTTManager();
    Future.delayed(const Duration(milliseconds: 1500), () async {
      mqttConfigureAndConnect();
    });
  }

  void mqttConfigureAndConnect() {
    manager.initializeMQTTClient(state: payloadProvider);
    manager.connect();
  }

  @override
  Widget build(BuildContext context)
  {
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints)
        {
          if (constraints.maxWidth < 600) {
            return const DashboardNarrow();//mobile
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return const DashboardMiddle();//pad or tap
          } else {
            return const DashboardWide();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}



//Narrow-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardNarrow extends StatefulWidget {
  const DashboardNarrow({Key? key}) : super(key: key);
  @override
  State<DashboardNarrow> createState() => _DashboardNarrowState();
}

class _DashboardNarrowState extends State<DashboardNarrow> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Middle-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardMiddle extends StatefulWidget {
  const DashboardMiddle({Key? key}) : super(key: key);
  @override
  State<DashboardMiddle> createState() => _DashboardMiddleState();
}

class _DashboardMiddleState extends State<DashboardMiddle> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

//Wide-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardWide extends StatefulWidget
{
  const DashboardWide({Key? key}) : super(key: key);

  @override
  State<DashboardWide> createState() => _DashboardWideState();
}

class _DashboardWideState extends State<DashboardWide> {

  String appBarTitle = 'Home';
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  int _selectedIndex = 0;
  int userId = 0;
  String userName = '', userType = '0', countryCode = '', mobileNo = '', userEmailId = '';
  bool visibleLoading = false;

  final List<LanguageList> languageList = <LanguageList>[];
  String _mySelection = 'English';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    indicatorViewShow();
    getCustomerSite();
  }

  void callbackFunction(message)
  {
    Navigator.pop(context);
    _showSnackBar(message);
  }

  Future<void> getCustomerSite() async
  {
    final prefs = await SharedPreferences.getInstance();
    userName = (prefs.getString('userName') ?? "");
    userType = (prefs.getString('userType') ?? "");
    countryCode = (prefs.getString('countryCode') ?? "");
    mobileNo = (prefs.getString('mobileNumber') ?? "");
    userId = int.parse(prefs.getString('userId') ?? "");
    userEmailId = (prefs.getString('email') ?? "");

    Future.delayed(const Duration(seconds: 3), () async {
      indicatorViewHide();
      getLanguage();
    });

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
      setState(() {
        languageList;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context)  {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: userType =='3'? AppBar(
        leading: const Image(image: AssetImage("assets/images/niagara_logo.png")),
        leadingWidth: 100,
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
              IconButton(tooltip : 'Niagara Account\n$userName\n+$countryCode $mobileNo', onPressed: (){
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 0, 10, 0),
                  surfaceTintColor: Colors.green,
                  items: <PopupMenuEntry>[
                    PopupMenuItem(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: CircleAvatar(radius: 35, backgroundColor: Colors.greenAccent, child: Text(userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 25)),),
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 70.0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle, // Optional: Makes the container circular
                                    color: Colors.green, // Set the background color here
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
                          Text('Hi, $userName!',style: const TextStyle(fontSize: 20)),
                          Text(userEmailId, style: const TextStyle(fontSize: 13)),
                          Text('+$countryCode $mobileNo', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 15),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return AccountManagement(userID: userId, callback: callbackFunction);
                              },
                            );
                          }, child: const Text('Manage Your Niagara Account')),
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
                                  await prefs.remove('countryCode');
                                  await prefs.remove('mobileNumber');
                                  await prefs.remove('subscribeTopic');
                                  if (context.mounted){
                                    Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
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
                child: Text(userName.substring(0, 1).toUpperCase()),
              )),
            ],),
          const SizedBox(width: 10),
        ],
      ) : null,
      body: visibleLoading? Center(
        child: Visibility(
          visible: visibleLoading,
          child: Container(
            padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 25, 0, mediaQuery.size.width/2 - 25, 0),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            ),
          ),
        ),
      ) :
      userType =='3'? Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: CustomerHome(customerID: userId, customerName: userName, mobileNo: '+$countryCode-$mobileNo', comingFrom: 'Customer',),
      ): Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.white,
            labelType: NavigationRailLabelType.all,
            indicatorColor: myTheme.primaryColor,
            indicatorShape: const CircleBorder(eccentricity: 0.3),
            //unselectedIconTheme: const IconThemeData(color: Colors.grey),
            elevation: 5,
            leading: const Column(
              children: [
                Image(image: AssetImage("assets/images/company_logo.png"), height: 60,),
                SizedBox(height: 20),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout, color: Colors.redAccent,),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('userId');
                      await prefs.remove('userName');
                      await prefs.remove('countryCode');
                      await prefs.remove('mobileNumber');
                      await prefs.remove('subscribeTopic');
                      if (mounted){
                        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
                      }
                    },
                  ),
                ),
              ),
            ),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                if(_selectedIndex==0){
                  appBarTitle = 'Home';
                }else if(_selectedIndex==1){
                  appBarTitle = 'Product';
                }else{
                  appBarTitle = 'My Preference';
                }
              });
            },
            destinations: userType == '1'? <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.topic_outlined),
                selectedIcon: Icon(Icons.topic_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Colors.white,),
                label: Text(''),
              ),
            ]:
            <NavigationRailDestination>[
              const NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.list, color: Colors.white),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_outlined, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Colors.white,),
                label: Text(''),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Colors.white,),
                label: Text(''),
              ),
            ],
          ),
          Expanded(
            child: userType == '1'?
            _selectedIndex == 0 ? AdminDealerHomePage(userName: userName, countryCode: countryCode, mobileNo: mobileNo, fromLogin: true, userId: 0, userType: 0,) :
            _selectedIndex == 1 ? ProductInventory(userName: userName) :
            _selectedIndex == 2 ? const AllEntry():
            _selectedIndex == 3 ?  MyPreference(userID: userId,) : const MyWebView() :

            _selectedIndex == 0 ? AdminDealerHomePage(userName: userName, countryCode: countryCode, mobileNo: mobileNo, fromLogin: true, userId: 0, userType: 0,) :
            _selectedIndex == 1 ? ProductInventory(userName: userName) :
            _selectedIndex == 2 ? MyPreference(userID: userId,) : const MyWebView(),
          ),
        ],
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


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

}