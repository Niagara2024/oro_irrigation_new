import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/dash_board.dart';
import 'package:oro_irrigation_new/screens/login_form.dart';
import 'package:oro_irrigation_new/state_management/constant_provider.dart';
import 'package:oro_irrigation_new/state_management/data_acquisition_provider.dart';
import 'package:oro_irrigation_new/state_management/irrigation_program_main_provider.dart';
import 'package:oro_irrigation_new/state_management/mqtt_message_provider.dart';
import 'package:oro_irrigation_new/state_management/overall_use.dart';
import 'package:oro_irrigation_new/state_management/preferences_screen_main_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state_management/config_maker_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ConfigMakerProvider()),
      ChangeNotifierProvider(create: (context) => PreferencesMainProvider()),
      ChangeNotifierProvider(create: (context) => DataAcquisitionProvider()),
      ChangeNotifierProvider(create: (context) => ConstantProvider()),
      ChangeNotifierProvider(create: (context) => OverAllUse()),
      ChangeNotifierProvider(create: (context) => MessageProvider()),
      ChangeNotifierProvider(create: (context) => IrrigationProgramMainProvider()),
      ChangeNotifierProvider(create: (context) => OverAllUse()),
      ChangeNotifierProvider(create: (context) => ConstantProvider()),
      // ChangeNotifierProvider(create: (context) => MqttProvider(mqttClient: mqtt)),
    ],
    child: MyApp(),
  )
  );
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
      statusBarBrightness: Brightness.dark,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      routes: {
        '/': (context) => const Landing(),
        '/login': (context) => const LoginForm(),
        '/dashboard': (context) => const DashBoard(),
      },
    );
  }
}

class Landing extends StatefulWidget {
  const Landing({super.key});
  @override
  LandingState createState() => LandingState();
}

class LandingState extends State<Landing>
{
  String username = "";

  @override
  void initState() {
    super.initState();
    checkUserInfo();
  }

  void checkUserInfo() async
  {
    final prefs = await SharedPreferences.getInstance();
    username = (prefs.getString('userName') ?? "");
    if (mounted){
      if (username == "") {
        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
      }else{
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ModalRoute.withName('/dashboard'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  void dispose() {
    super.dispose();
  }

}