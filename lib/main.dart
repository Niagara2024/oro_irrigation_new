import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/DashBoard.dart';
import 'package:oro_irrigation_new/screens/login_form.dart';
import 'package:oro_irrigation_new/state_management/CustomerDataProvider.dart';
import 'package:oro_irrigation_new/state_management/DurationNotifier.dart';
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
import 'package:oro_irrigation_new/state_management/scheule_view_provider.dart';
import 'package:oro_irrigation_new/state_management/system_definition_provider.dart';
import 'package:provider/provider.dart';
import 'state_management/config_maker_provider.dart';

void main() {
  ScheduleViewProvider mySchedule = ScheduleViewProvider();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  myMqtt.editMySchedule(mySchedule);

  runApp(
      MultiProvider(
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
          ChangeNotifierProvider(create: (context) => myMqtt),
          ChangeNotifierProvider(create: (context) => SystemDefinitionProvider()),
          ChangeNotifierProvider(create: (context) => ProgramQueueProvider()),
          ChangeNotifierProvider(create: (context) => mySchedule),
          ChangeNotifierProvider(create: (_) => CustomerDataProvider()),
          ChangeNotifierProvider(create: (_) => DurationNotifier()),
        ],
        child: const MyApp(),
      )
  );


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      initialRoute: '/dashboard',
      routes: {
        '/login': (context) => const LoginForm(),
        '/dashboard': (context) => const MainDashBoard(),
      },
    );
  }

}