import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oro_irrigation_new/state_management/scheule_view_provider.dart';


enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String dashBoardPayload = '', schedulePayload = '';
  late ScheduleViewProvider mySchedule;

  int wifiStrength = 0;
  //List<dynamic> mainLine = [];
  List<dynamic> currentSchedule = [];
  List<dynamic> PrsIn = [];
  List<dynamic> PrsOut = [];
  List<dynamic> nextSchedule = [];
  List<dynamic> upcomingProgram = [];
  List<dynamic> filtersCentral = [];
  List<dynamic> filtersLocal = [];
  List<dynamic> sourcePump = [];
  List<dynamic> irrigationPump = [];
  List<dynamic> fertilizerCentral = [];
  List<dynamic> fertilizerLocal = [];
  //List<dynamic> flowMeter = [];
  List<dynamic> waterMeter = [];
  List<dynamic> alarmList = [];
  List<dynamic> payload2408 = [];

  void editMySchedule(ScheduleViewProvider instance){
    mySchedule = instance;
    notifyListeners();
  }

  void updateReceivedPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
        dashBoardPayload = payload;

        if (data['2400'][0].containsKey('2405')) {
          //mainLine = data['2400'][0]['2405'];
        }
        if (data['2400'][0].containsKey('2402')) {
          currentSchedule = data['2400'][0]['2402'];
          if(currentSchedule.isNotEmpty && currentSchedule[0].containsKey('PrsIn')){
            PrsIn = currentSchedule[0]['PrsIn'];
            PrsOut = currentSchedule[0]['PrsOut'];
          }
        }
        if (data['2400'][0].containsKey('2403')) {
          nextSchedule = data['2400'][0]['2403'];
        }
        if (data['2400'][0].containsKey('2404')) {
          upcomingProgram = data['2400'][0]['2404'];
        }
        if (data['2400'][0].containsKey('2405')) {
          List<dynamic> filtersJson = data['2400'][0]['2405'];
          filtersCentral = [];
          filtersLocal = [];

          for (var filter in filtersJson) {
            if (filter['Type'] == 1) {
              filtersCentral.add(filter);
            } else if (filter['Type'] == 2) {
              filtersLocal.add(filter);
            }
          }
        }

        if (data['2400'][0].containsKey('2406')) {
          List<dynamic> filters = data['2400'][0]['2406'];
          fertilizerCentral = filters.where((item) => item['Type'] == 1).toList();
          fertilizerLocal = filters.where((item) => item['Type'] == 2).toList();
        }

        if (data['2400'][0].containsKey('2407')) {
          List<dynamic> pumps = data['2400'][0]['2407'];
          sourcePump = pumps.where((item) => item['Type'] == 1).toList();
          irrigationPump = pumps.where((item) => item['Type'] == 2).toList();
        }

        if (data['2400'][0].containsKey('2408')) {
          payload2408 = data['2400'][0]['2408'];
        }

        if (data['2400'][0].containsKey('2409')) {
          alarmList = data['2400'][0]['2409'];
        }

        if (data['2400'][0].containsKey('2410')) {
          waterMeter = data['2400'][0]['2410'];
        }

      }
      else if(data.containsKey('2900') && data['2900'] != null && data['2900'].isNotEmpty){
        schedulePayload = payload;
      }
      notifyListeners();
      print('provider upcomingProgram:${upcomingProgram}');
    } catch (e) {
      print('Error parsing JSON: $e');
    }
    //notifyListeners();
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;

}