import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/DashBoard.dart';
import 'package:oro_irrigation_new/screens/login_form.dart';
import 'package:oro_irrigation_new/state_management/FertilizerSetProvider.dart';
import 'package:oro_irrigation_new/state_management/GlobalFertLimitProvider.dart';
import 'package:oro_irrigation_new/state_management/MqttPayloadProvider.dart';
import 'package:oro_irrigation_new/state_management/SelectedGroupProvider.dart';
import 'package:oro_irrigation_new/state_management/constant_provider.dart';
import 'package:oro_irrigation_new/state_management/data_acquisition_provider.dart';
import 'package:oro_irrigation_new/state_management/irrigation_program_main_provider.dart';
import 'package:oro_irrigation_new/state_management/mqtt_message_provider.dart';
import 'package:oro_irrigation_new/state_management/overall_use.dart';
import 'package:oro_irrigation_new/state_management/preferences_screen_main_provider.dart';
import 'package:oro_irrigation_new/state_management/program_queue_provider.dart';
import 'package:oro_irrigation_new/state_management/system_definition_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state_management/config_maker_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ConfigMakerProvider()),
      ChangeNotifierProvider(create: (context) => PreferencesMainProvider()),
      ChangeNotifierProvider(create: (context) => DataAcquisitionProvider()),
      ChangeNotifierProvider(create: (context) => OverAllUse()),
      ChangeNotifierProvider(create: (context) => MessageProvider()),
      ChangeNotifierProvider(create: (context) => IrrigationProgramMainProvider()),
      ChangeNotifierProvider(create: (context) => ConstantProvider()),
      ChangeNotifierProvider(create: (context) => SelectedGroupProvider()),
      ChangeNotifierProvider(create: (context) => FertilizerSetProvider()),
      ChangeNotifierProvider(create: (context) => GlobalFertLimitProvider()),
      ChangeNotifierProvider(create: (context) => MqttPayloadProvider()),
      ChangeNotifierProvider(create: (context) => SystemDefinitionProvider()),
      ChangeNotifierProvider(create: (context) => ProgramQueueProvider()),

    ],
    child: const MyApp(),
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
        '/dashboard': (context) => const MainDashBoard(),
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