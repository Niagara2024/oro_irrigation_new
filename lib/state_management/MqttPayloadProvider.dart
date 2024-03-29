import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:oro_irrigation_new/state_management/scheule_view_provider.dart';


enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String dashBoardPayload = '', schedulePayload = '';
  late ScheduleViewProvider mySchedule;

  int wifiStrength = 0;
  List<dynamic> mainLine = [];
  List<dynamic> currentSchedule = [];
  List<dynamic> PrsIn = [];
  List<dynamic> PrsOut = [];
  List<dynamic> nextSchedule = [];
  List<dynamic> upcomingProgram = [];
  List<dynamic> filtersCentral = [];
  List<dynamic> filtersLocal = [];
  List<dynamic> irrigationPump = [];
  List<dynamic> fertilizerCentral = [];
  List<dynamic> flowMeter = [];

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
          if(currentSchedule.isNotEmpty && currentSchedule[0].containsKey('PrsIn')){
            //print(currentSchedule[0]['PrsIn'].runtimeType);
            //print(currentSchedule[0]['PrsOut'].runtimeType);
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
          List<dynamic> fertilizerJson = data['2400'][0]['2406'];
          fertilizerCentral = [];

          for (var fertilizer in fertilizerJson) {
            if (fertilizer['Type'] == 1) {
              fertilizerCentral.add(fertilizer);
            } else if (fertilizer['Type'] == 2) {
              //filtersLocal.add(filter);
            }
          }
        }

        if (data['2400'][0].containsKey('2407')) {
          List<dynamic> items = data['2400'][0]['2407'];
          irrigationPump = items.where((item) => item['Type'] == 2).toList();
        }

        if (data['2400'][0].containsKey('2408')) {
          List<dynamic> items = data['2400'][0]['2408'];
          flowMeter.addAll(items.where((item) => item['Watermeter'] != '-').map((item) => item['Watermeter']));
        }

      }
      else if(data.containsKey('2900') && data['2900'] != null && data['2900'].isNotEmpty){
        schedulePayload = payload;
      }
      notifyListeners();
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

  void clearData() {
    wifiStrength = 0;
    dashBoardPayload = '';
    mainLine = [];
    currentSchedule = [];
    PrsIn = [];
    PrsOut = [];
    upcomingProgram = [];
    nextSchedule = [];
    filtersCentral = [];
    filtersLocal = [];
    irrigationPump = [];
    fertilizerCentral = [];
    notifyListeners();
  }

}