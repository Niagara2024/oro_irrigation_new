import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oro_irrigation_new/state_management/scheule_view_provider.dart';


enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String dashBoardPayload = '', schedulePayload = '';
  late ScheduleViewProvider mySchedule;

  int wifiStrength = 0;
  late List<dynamic> mainLine = [];
  late List<dynamic> currentSchedule = [];
  late List<dynamic> nextSchedule = [];
  late List<dynamic> upcomingProgram = [];

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
          mainLine = data['2400'][0]['2405'];
        }
        if (data['2400'][0].containsKey('2402')) {
          currentSchedule = data['2400'][0]['2402'];
        }
        if (data['2400'][0].containsKey('2403')) {
          nextSchedule = data['2400'][0]['2403'];
        }
        if (data['2400'][0].containsKey('2404')) {
          upcomingProgram = data['2400'][0]['2404'];
        }

      }
      else if(data.containsKey('2900') && data['2900'] != null && data['2900'].isNotEmpty){
        schedulePayload = payload;
      }
    } catch (e) {
      print('Error parsing JSON: $e');
    }
    notifyListeners();
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;

  void clearData() {
    dashBoardPayload = '';
    mainLine.clear();
    currentSchedule.clear();
    upcomingProgram.clear();
    nextSchedule.clear();
    notifyListeners();
  }

}