import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/MQTTManager.dart';
import '../constants/MqttServer.dart';
import '../state_management/MqttPayloadProvider.dart';
import '../state_management/ConnectivityService.dart';
import 'Admin/AdminScreenController.dart';
import 'Customer/CustomerScreenController.dart';
import 'Dealer/DealerScreenController.dart';
import 'login_form.dart';

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
        //mqttSeverConfigureAndConnect();
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
    /*final connection = Provider.of<MqttPayloadProvider>(context).mqttConnection;
    if(!connection){
      MQTTManager manager = MQTTManager();
      MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      manager.initializeMQTTServer(state: payloadProvider);
      //manager.connect();
    }*/


    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: Text('Loading... Please waite.'));
        }else{
          final sharedPreferences = snapshot.data!;
          final userId = sharedPreferences.getString('userId') ?? '';
          final userName = sharedPreferences.getString('userName') ?? '';
          final userType = sharedPreferences.getString('userType') ?? '';
          final countryCode = sharedPreferences.getString('countryCode') ?? '';
          final mobileNo = sharedPreferences.getString('mobileNumber') ?? '';
          final emailId = sharedPreferences.getString('emailId') ?? '';

          return Consumer<ConnectivityService>(
            builder: (context, connectivityService, child) {
              final isConnected = connectivityService.isConnected;
              return  isConnected ? userId.isNotEmpty? BuildDashboardScreen(userId: int.parse(userId), userType: int.parse(userType), userName: userName, countryCode: countryCode, mobileNo: mobileNo, emailId: emailId,):
              const LoginForm():
              const Scaffold(
                body: Center(child: Text('No Internet Connection')),
              );
            },
          );
        }
      },
    );
  }
}


/*Consumer<MQTTManager>(
builder: (context, mqttServer, child) {
final isConnected = mqttServer.isConnected;

return Text(
isConnected ? 'Connected to MQTT Broker' : 'Disconnected from MQTT Broker',
style: const TextStyle(fontSize: 24),
);
},
),*/


class BuildDashboardScreen extends StatefulWidget
{
  const BuildDashboardScreen({Key? key, required this.userId, required this.userType, required this.userName, required this.countryCode, required this.mobileNo, required this.emailId}) : super(key: key);
  final int userId, userType;
  final String userName, countryCode, mobileNo, emailId;

  @override
  State<BuildDashboardScreen> createState() => _BuildDashboardScreenState();
}

class _BuildDashboardScreenState extends State<BuildDashboardScreen> {

  @override
  Widget build(BuildContext context)  {
    print('userName:${widget.userName}');
    print('userId:${widget.userId}');
    print('userType:${widget.userType}');

    return Scaffold(
      body: mainScreen(widget.userType),
    );

  }

  Widget mainScreen(int userType) {
    switch (userType) {
      case 0||1:
        return AdminScreenController(
          userName: widget.userName,
          countryCode: widget.countryCode,
          mobileNo: widget.mobileNo,
          fromLogin: true,
          userId: widget.userId, userType: userType,);
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
          emailId: widget.emailId, userId: widget.userId,);
      default:
        return const SizedBox();
    }
  }

}
