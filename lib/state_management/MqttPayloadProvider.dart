import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oro_irrigation_new/state_management/scheule_view_provider.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String dashBoardPayload = '', schedulePayload = '';
  late ScheduleViewProvider mySchedule;

  void editMySchedule(ScheduleViewProvider instance){
    mySchedule = instance;
    notifyListeners();
  }

  void updateReceivedPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
        dashBoardPayload = payload;
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

}