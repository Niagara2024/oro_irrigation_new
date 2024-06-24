import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/state_management/scheule_view_provider.dart';

import '../Models/Customer/Dashboard/DashboardNode.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String dashBoardPayload = '', schedulePayload = '';
  late ScheduleViewProvider mySchedule;

  int wifiStrength = 0;
  //List<dynamic> nodeList = [];
  //List<dynamic> currentSchedule = [];
  List<dynamic> PrsIn = [];
  List<dynamic> PrsOut = [];
  //List<dynamic> nextSchedule = [];
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

  List<dynamic> _nodeList = [];
  List<dynamic> get nodeList => _nodeList;

  List<ScheduledProgram> _scheduledProgram = [];
  List<ScheduledProgram> get scheduledProgram => _scheduledProgram;

  List<ProgramQueue> _programQueue = [];
  List<ProgramQueue> get programQueue => _programQueue;

  List<CurrentScheduleModel> _currentSchedule = [];
  List<CurrentScheduleModel> get currentSchedule => _currentSchedule;

  String currentDate = '', currentTime = '';

  void editMySchedule(ScheduleViewProvider instance){
    mySchedule = instance;
    notifyListeners();
  }

  void updateReceivedPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);

      if(data.containsKey('2400')){
        print('Gem controller payload :$payload');
        if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
          dashBoardPayload = payload;

          final DateTime now = DateTime.now();
          final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
          final DateFormat timeFormatter = DateFormat('HH:mm:ss');

          currentDate = dateFormatter.format(now);
          currentTime = timeFormatter.format(now);

          if(data['2400'][0].containsKey('WifiStrength')) {
            wifiStrength = data['2400'][0]['WifiStrength'];
          }

          if(data['2400'][0].containsKey('2401')) {
            List<dynamic> nodes = data['2400'][0]['2401'];
            updateNodeList(nodes);
          }

          if(data['2400'][0].containsKey('2402')) {
            List<dynamic> csItems = data['2400'][0]['2402'];
            List<CurrentScheduleModel> cs = csItems.map((cs) => CurrentScheduleModel.fromJson(cs)).toList();
            updateCurrentScheduled(cs);

            if(csItems.isNotEmpty && csItems[0].containsKey('PrsIn')){
              PrsIn = csItems[0]['PrsIn'];
              PrsOut = csItems[0]['PrsOut'];
            }
          }
          if (data['2400'][0].containsKey('2403')) {
            List<dynamic> programList = data['2400'][0]['2403'];
            List<ProgramQueue> pq = programList.map((pq) => ProgramQueue.fromJson(pq)).toList();
            updateProgramQueue(pq);
          }
          if (data['2400'][0].containsKey('2404')) {
            List<dynamic> programList = data['2400'][0]['2404'];
            List<ScheduledProgram> scp = programList.map((sp) => ScheduledProgram.fromJson(sp)).toList();
            updateScheduledProgram(scp);
          }
          //print('upcomingProgram:${upcomingProgram}');
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
            List<dynamic> fertilizer = data['2400'][0]['2406'];
            fertilizerCentral = fertilizer.where((item) => item['Type'] == 1).toList();
            fertilizerLocal = fertilizer.where((item) => item['Type'] == 2).toList();
          }

          if (data['2400'][0].containsKey('2407')) {
            List<dynamic> pumps = data['2400'][0]['2407'];
            sourcePump = pumps.where((item) => item['Type'] == 1).toList();
            irrigationPump = pumps.where((item) => item['Type'] == 2).toList();
          }

          if (data['2400'][0].containsKey('2408')) {
            payload2408 = data['2400'][0]['2408'];
            //print('payload2408:$payload2408');
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
      }else{
        print('pump controller payload :$payload');
      }

      notifyListeners();
    } catch (e) {
      print('Error parsing JSON: $e');
    }
    //notifyListeners();
  }

  void updateNodeList(List<dynamic> nds) {
    _nodeList = nds;
    notifyListeners();
  }

  void updateCurrentScheduled(List<CurrentScheduleModel> cs) {
    _currentSchedule = cs;
    notifyListeners();
  }

  void updateScheduledProgram(List<ScheduledProgram> schPrograms) {
    _scheduledProgram = schPrograms;
    notifyListeners();
  }

  void updateProgramQueue(List<ProgramQueue> programsQue) {
    _programQueue = programsQue;
    notifyListeners();
  }

  void updatePumpPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
        if (data['2400'][0].containsKey('2407')) {
          List<dynamic> pumps = data['2400'][0]['2407'];
          sourcePump = pumps.where((item) => item['Type'] == 1).toList();
          irrigationPump = pumps.where((item) => item['Type'] == 2).toList();
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }


  void updateFilterPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);
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
      notifyListeners();
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  void updateFertilizerPayload(String payload) {
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      if (data['2400'][0].containsKey('2406')) {
        List<dynamic> fertilizer = data['2400'][0]['2406'];
        fertilizerCentral = fertilizer.where((item) => item['Type'] == 1).toList();
        fertilizerLocal = fertilizer.where((item) => item['Type'] == 2).toList();
      }
      notifyListeners();
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;

}