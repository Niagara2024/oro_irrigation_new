import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/NarrowLayout/Customer/HomeScreenN.dart';
import 'package:oro_irrigation_new/screens/product_inventory.dart';
import 'package:oro_irrigation_new/screens/web_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/MQTTManager.dart';
import '../constants/MqttServer.dart';
import '../constants/UserData.dart';
import '../state_management/MqttPayloadProvider.dart';
import 'Customer/CustomerScreenController.dart';
import 'my_preference.dart';
import 'product_entry.dart';
import 'AdminDealerHomePage.dart';
import 'login_form.dart';


enum Calendar { day, week, month, year }

class MainDashBoard extends StatefulWidget
{
  const MainDashBoard({super.key});

  @override
  State<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends State<MainDashBoard> {

  late MQTTManager manager = MQTTManager();
  late MqttServer mqttServer = MqttServer();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (kIsWeb) {
        print('web platform');
        mqttConfigureAndConnect();
      } else {
        print('other platform');
        mqttSeverConfigureAndConnect();
      }
    });
  }

  void mqttConfigureAndConnect() {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    manager.initializeMQTTClient(state: payloadProvider);
    manager.connect();
  }

  void mqttSeverConfigureAndConnect() {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    mqttServer.initializeMQTTServer(state: payloadProvider);
  }


  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container();
        }
        final sharedPreferences = snapshot.data!;
        final userId = sharedPreferences.getString('userId') ?? '';
        final userName = sharedPreferences.getString('userName') ?? '';
        final userType = sharedPreferences.getString('userType') ?? '';
        final countryCode = sharedPreferences.getString('countryCode') ?? '';
        final mobileNo = sharedPreferences.getString('mobileNumber') ?? '';
        final userEmailId = sharedPreferences.getString('email') ?? '';
        final password = sharedPreferences.getString('password') ?? '';

        if (userId.isNotEmpty) {
          return UserData(
            userId: int.parse(userId),
            userName: userName,
            userType: userType,
            countryCode: countryCode,
            mobileNo: mobileNo,
            userEmailId: userEmailId,
            password: password,
            child: Scaffold(
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
            ),
          );
        } else {
          return const LoginForm();
        }
      },
    );
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
    final userData = UserData.of(context)!;
    return HomeScreenN(userId: userData.userId);
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
  bool visibleLoading = false;


  @override
  Widget build(BuildContext context)  {
    final userData = UserData.of(context)!;
    return  Scaffold(
      body: userData.userType=='3'?
      CustomerScreenController(customerID: userData.userId, customerName: userData.userName, mobileNo: '+${userData.countryCode}-${userData.mobileNo}', comingFrom: 'Customer'):
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: myTheme.primaryColorDark,
            labelType: NavigationRailLabelType.all,
            indicatorColor: myTheme.primaryColorLight,
            elevation: 5,
            leading: const Column(
              children: [
                Image(image: AssetImage("assets/images/oro_logo_white.png"), height: 40, width: 60,),
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
                      await prefs.remove('userType');
                      await prefs.remove('countryCode');
                      await prefs.remove('mobileNumber');
                      await prefs.remove('subscribeTopic');
                      if (mounted){
                        Navigator.pushReplacementNamed(context, '/login');
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
            destinations: userData.userType == '1'? <NavigationRailDestination>[
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
          buildExpandedWidget(userData),
        ],
      ),
    );

  }

  Widget buildExpandedWidget(userData) {
    return Expanded(
      child: selectedWidget(_selectedIndex, userData),
    );
  }

  Widget selectedWidget(int index, userData) {
    switch (index) {
      case 0:
        return AdminDealerHomePage(
          userName: userData.userName,
          countryCode: userData.countryCode,
          mobileNo: userData.mobileNo,
          fromLogin: true,
          userId: userData.userId,
          userType: int.parse(userData.userType ?? 0),
        );
      case 1:
        return ProductInventory(
          userName: userData.userName,
        );
      case 2:
        return userData.userType == '1' ? const AllEntry() : MyPreference(userID: userData.userId);
      case 3:
        return userData.userType == '1' ? MyPreference(userID: userData.userId) : const MyWebView();
      default:
        return const SizedBox(); // Return an empty widget by default or handle error case
    }
  }
}
