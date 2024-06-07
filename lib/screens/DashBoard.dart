import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/NarrowLayout/Customer/HomeScreenN.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/MQTTManager.dart';
import '../constants/MqttServer.dart';
import '../state_management/MqttPayloadProvider.dart';
import 'Admin/AdminScreenController.dart';
import 'Customer/CustomerScreenController.dart';
import 'Dealer/DealerScreenController.dart';
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
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
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
        }else{
          final sharedPreferences = snapshot.data!;
          final userId = sharedPreferences.getString('userId') ?? '';
          final userName = sharedPreferences.getString('userName') ?? '';
          final userType = sharedPreferences.getString('userType') ?? '';
          final countryCode = sharedPreferences.getString('countryCode') ?? '';
          final mobileNo = sharedPreferences.getString('mobileNumber') ?? '';
          final emailId = sharedPreferences.getString('emailId') ?? '';

          if (userId.isNotEmpty) {
            return Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints)
                {
                  if (constraints.maxWidth < 600) {
                    return  DashboardNarrow(userId: int.parse(userId));
                  } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
                    return const DashboardMiddle();
                  } else {
                    return  DashboardWide(userId: int.parse(userId), userType: int.parse(userType), userName: userName, countryCode: countryCode, mobileNo: mobileNo, emailId: emailId,);
                  }
                },
              ),
            );
          } else {
            return const LoginForm();
          }
        }
      },
    );
  }
}


//Narrow-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

class DashboardNarrow extends StatefulWidget {
  const DashboardNarrow({Key? key, required this.userId}) : super(key: key);
  final int userId;
  @override
  State<DashboardNarrow> createState() => _DashboardNarrowState();
}

class _DashboardNarrowState extends State<DashboardNarrow> {
  @override
  Widget build(BuildContext context) {
    return HomeScreenN(userId: widget.userId);
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
  const DashboardWide({Key? key, required this.userId, required this.userType, required this.userName, required this.countryCode, required this.mobileNo, required this.emailId}) : super(key: key);
  final int userId, userType;
  final String userName, countryCode, mobileNo, emailId;

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
    print('userName:${widget.userName}');
    print('userId:${widget.userId}');
    print('userType:${widget.userType}');
    return  Scaffold(
      body: mainScreen(widget.userType),
    );
  }

  Widget mainScreen(int userType) {
    switch (userType) {
      case 1:
        return AdminScreenController(
          userName: widget.userName,
          countryCode: widget.countryCode,
          mobileNo: widget.mobileNo,
          fromLogin: true,
          userId: widget.userId,);
      case 2:
        return DealerScreenController(
          userName: widget.userName,
          countryCode: widget.countryCode,
          mobileNo: widget.mobileNo,
          fromLogin: true,
          userId: widget.userId,
          emailId: widget.emailId,);
      case 3:
        return CustomerScreenController(
          customerId: widget.userId,
          customerName: widget.userName,
          mobileNo: '+${widget.countryCode}-${widget.mobileNo}',
          comingFrom: 'Customer',
          emailId: widget.emailId,);
      default:
        return const SizedBox();
    }
  }

}
