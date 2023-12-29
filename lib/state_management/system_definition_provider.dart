import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../Models/Customer/system_definition_model.dart';
import '../constants/http_service.dart';

class SystemDefinitionProvider extends ChangeNotifier{
  final HttpService httpService = HttpService();
  int _selectedSegment = 0;

  int get selectedSegment => _selectedSegment;

  void updateSelectedSegment(int newIndex) {
    _selectedSegment = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  EnergySaveSettings? _energySaveSettings;
  EnergySaveSettings? get energySaveSettings => _energySaveSettings;
  PowerOffRecoveryModel? _powerOffRecoveryModel;
  PowerOffRecoveryModel? get powerOffRecoveryModel => _powerOffRecoveryModel;

  Future<void> getUserPlanningPowerSaver(userId, controllerId) async {
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
      };
      var getUserPlanningPowerSaver = await httpService.postRequest('getUserPlanningPowerSaver', userData);
      if(getUserPlanningPowerSaver.statusCode == 200) {
        final responseJson = getUserPlanningPowerSaver.body;
        final convertedJson = jsonDecode(responseJson);
        if(convertedJson["data"].isEmpty) {
          convertedJson["data"].addAll(
              {
                "energySaveFunction": {
                  "energySaveFunction": false,
                  "startDayTime": "00:00",
                  "stopDayTime": "00:00",
                  "pauseMainLine": false,
                  "sunday": {"from": "12:00 AM", "to": "02:00 AM", "selected" : false},
                  "monday": {"from": "02:00 AM", "to": "04:00 AM", "selected" : false},
                  "tuesday": {"from": "06:00 AM", "to": "08:00 AM", "selected" : false},
                  "wednesday": {"from": "08:00 AM", "to": "10:00 AM", "selected" : false},
                  "thursday": {"from": "10:00 AM", "to": "12:00 PM", "selected" : false},
                  "friday": {"from": "12:00 PM", "to": "02:00 PM", "selected" : false},
                  "saturday": {"from": "02:00 PM", "to": "04:00 PM", "selected" : false}
                },
                "powerOffRecovery": {
                  "duration": "00:00",
                  "selectedOption": []
                }
              }
          );
          _energySaveSettings = EnergySaveSettings.fromJson(convertedJson);
          _powerOffRecoveryModel = PowerOffRecoveryModel.fromJson(convertedJson);
        } else {
          _energySaveSettings = EnergySaveSettings.fromJson(convertedJson);
          _powerOffRecoveryModel = PowerOffRecoveryModel.fromJson(convertedJson);
        }

      } else {
        log("HTTP Request failed or received an unexpected response.");
      }
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
    Future.delayed(Duration.zero, (){
      notifyListeners();
    });
  }

  List<String> options = ["Reset", "Queue", "Irrigation"];

  void updateCheckBoxesForOption(newValue, selectedOption, index) {
    if (newValue) {
      _powerOffRecoveryModel!.selectedOption.add(selectedOption);
    } else {
      _powerOffRecoveryModel!.selectedOption.remove(selectedOption);
    }
    notifyListeners();
  }

  void updateValues(newValue, type) {
    switch(type) {
      case "energySaveFunction": _energySaveSettings?.energySaveFunction = newValue;
      break;
      case "startDayTime": _energySaveSettings?.startDayTime = newValue;
      break;
      case "stopDayTime": _energySaveSettings?.stopDayTime = newValue;
      break;
      case "pauseOnOff": _energySaveSettings?.pauseMainLine = newValue;
      break;
      case "duration": _powerOffRecoveryModel!.duration = newValue;
      break;
    }
    notifyListeners();
  }

  void updateDayTimeRange(DayTimeRange dayTimeRange, String newFrom, String newTo) {
    dayTimeRange.from = newFrom;
    dayTimeRange.to = newTo;
    notifyListeners();
  }

  List<String> days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
  List daysFromAndToTimes() {
    return [
      _energySaveSettings!.sunday,
      _energySaveSettings!.monday,
      _energySaveSettings!.tuesday,
      _energySaveSettings!.wednesday,
      _energySaveSettings!.thursday,
      _energySaveSettings!.friday,
      _energySaveSettings!.saturday,
    ];
  }
  List<String> values = ["1", "2", "3", "4", "5", "6", "7"];
  List<bool> isSelectedList() {
    return [
      _energySaveSettings!.sunday.selected,
      _energySaveSettings!.monday.selected,
      _energySaveSettings!.tuesday.selected,
      _energySaveSettings!.wednesday.selected,
      _energySaveSettings!.thursday.selected,
      _energySaveSettings!.friday.selected,
      _energySaveSettings!.saturday.selected,
    ];
  }

  bool sunday = false;
  bool monday = false;
  bool tuesday = false;
  bool wednesday = false;
  bool thursday = false;
  bool friday = false;
  bool saturday = false;

  void updateCheckBoxes(day, newValue) {
    switch(day) {
      case "1": _energySaveSettings!.sunday.selected =  newValue;
      break;
      case "2": _energySaveSettings!.monday.selected = newValue;
      break;
      case "3": _energySaveSettings!.tuesday.selected = newValue;
      break;
      case "4": _energySaveSettings!.wednesday.selected = newValue;
      break;
      case "5": _energySaveSettings!.thursday.selected = newValue;
      break;
      case "6": _energySaveSettings!.friday.selected = newValue;
      break;
      case "7": _energySaveSettings!.saturday.selected = newValue;
      break;
    }
    notifyListeners();
  }

  dynamic dataToMqtt() {
    String convertTo24HourFormat(String time12Hour) {
      List<String> components = time12Hour.split(' ');
      String timePart = components[0];
      String period = components[1];

      List<String> timeComponents = timePart.split(':');
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      String formattedHour = hour.toString().padLeft(2, '0');
      String formattedMinute = minute.toString().padLeft(2, '0');

      return '$formattedHour:$formattedMinute:00';
    }
    return [
      _energySaveSettings!.energySaveFunction ? 1 : 0,
      _energySaveSettings!.startDayTime != "00:00" ? convertTo24HourFormat(_energySaveSettings!.startDayTime) : "00:00:00",
      _energySaveSettings!.stopDayTime != "00:00" ? convertTo24HourFormat(_energySaveSettings!.stopDayTime) : "00:00:00",
      _energySaveSettings!.pauseMainLine ? 1 : 0,
      _energySaveSettings!.sunday.selected ? 1 : 0,
      _energySaveSettings!.sunday.from != "00:00" ? convertTo24HourFormat(_energySaveSettings!.sunday.from) : "00:00:00",
      _energySaveSettings!.sunday.to != "00:00" ? convertTo24HourFormat(_energySaveSettings!.sunday.to) : "00:00:00",
    ];
  }
}