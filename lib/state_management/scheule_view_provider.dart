import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/MQTTManager.dart';
import '../constants/http_service.dart';
import '../screens/Customer/ScheduleView.dart';
import 'MqttPayloadProvider.dart';

class ScheduleViewProvider extends ChangeNotifier {
  late MQTTManager manager;
  HttpService httpService = HttpService();
  late MqttPayloadProvider payloadProvider;
  String changeToValue = '';
  bool start = false;
  bool pause = false;
  late String data;
  List<dynamic> scheduleList = [];
  DateTime date = DateTime.now();
  List<Map<String, dynamic>> scheduleListFromMqtt = [];
  Map<String, dynamic> innerList = {};
  bool scheduleGotFromMqtt = false;

  // Constructor
  ScheduleViewProvider() {
    manager= MQTTManager();
    payloadProvider = MqttPayloadProvider();
    dataFromMqttConversion(payloadProvider.receivedSchedulePayload);
  }

  void updateChannel(index, itemIndex) {
    scheduleList[index]["CentralFertChannelSelection"].split("_")[itemIndex] == "1" ? "0" : "1";
    notifyListeners();
  }

  StatusInfo getStatusInfo(code) {
    Color innerCircleColor;
    String statusString;

    switch (code) {
      case "0":
        innerCircleColor = Colors.grey;
        statusString = "Pending";
        break;
      case "1":
        innerCircleColor = Colors.orange;
        statusString = "Running";
        break;
      case "2":
        innerCircleColor = Colors.green;
        statusString = "Completed";
        break;
      case "3":
        innerCircleColor = Colors.yellow;
        statusString = "Skipped by user";
        break;
      case "4":
        innerCircleColor = Colors.orangeAccent;
        statusString = "Day schedule pending";
        break;
      case "5":
        innerCircleColor = const Color(0xFF0D5D9A);
        statusString = "Day schedule running";
        break;
      case "6":
        innerCircleColor = Colors.yellowAccent;
        statusString = "Day schedule completed";
        break;
      case "7":
        innerCircleColor = Colors.red;
        statusString = "Day schedule skipped";
        break;
      case "8":
        innerCircleColor = Colors.redAccent;
        statusString = "Postponed partially to tomorrow";
        break;
      case "9":
        innerCircleColor = Colors.green;
        statusString = "Postponed fully to tomorrow";
        break;
      case "10":
        innerCircleColor = Colors.amberAccent;
        statusString = "RTC off time reached";
        break;
      case "11":
        innerCircleColor = Colors.amber;
        statusString = "RTC max time reached";
        break;
      default:
        throw Exception("Unsupported status code: $code");
    }

    return StatusInfo(innerCircleColor, statusString);
  }

  Future<void> requestScheduleData(deiceId) async {
    data = {
      "2600": [
        {"2601": DateFormat('yyyy-MM-dd').format(date)}
      ]
    }.toString();
    manager.publish(data, "AppToFirmware/$deiceId");
  }

  Future<void> getUserSequencePriority(userId, controllerId) async {
    print('Getting from http ------------------------------>');
    try {
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
        "scheduleDate": DateFormat('yyyy-MM-dd').format(date)
        // "scheduleDate": "2024-01-12"
      };

      var getUserProgramQueue = await httpService.postRequest("getUserSequencePriority", userData);

      if (getUserProgramQueue.statusCode == 200) {
        final responseJson = getUserProgramQueue.body;
        final convertedJson = jsonDecode(responseJson);
        if (convertedJson["code"] == 200) {
          scheduleList = convertedJson["data"][0]["sequence"];
        } else {
          scheduleList = [];
          print("schedule list is empty in the http");
        }
      }
    } catch (e) {
      log('Error: $e');
    }
    notifyListeners();
  }

  void fetchDataAfterDelay(deviceId, userId, controllerId) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      scheduleList.clear();
      scheduleListFromMqtt.clear();
    }).then((value) {
      requestScheduleData(deviceId);
      if(!scheduleGotFromMqtt) {
        Future.delayed(const Duration(milliseconds: 3000), () {
          getUserSequencePriority(userId, controllerId);
        });
      }
    });
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void dataFromMqttConversion(String payload) {
    scheduleGotFromMqtt = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        innerList = data["2900"]["2901"];
        for (int i = 0; i < innerList["S_No"].length; i++) {
          Map<String, dynamic> resultDict = {
            "S_No": innerList["S_No"][i],
            "ScheduleOrder": innerList["ScheduleOrder"][i],
            "ScaleFactor": innerList["ScaleFactor"][i],
            "SkipFlag": innerList["SkipFlag"][i],
            "Priority": innerList["Priority"][i],
            "Date": innerList["Date"][i],
            "ProgramCategory": innerList["ProgramCategory"][i],
            "MainValve": innerList["MainValve"][i],
            "ProgramS_No": innerList["ProgramS_No"][i],
            "ProgramName": innerList["ProgramName"][i],
            "ZoneS_No": innerList["ZoneS_No"][i],
            "ZoneName": innerList["ZoneName"][i],
            "RtcNumber": innerList["RtcNumber"][i],
            "CycleNumber": innerList["CycleNumber"][i],
            "RtcOnTime": innerList["RtcOnTime"][i],
            "ProgramStopMethod": innerList["ProgramStopMethod"][i],
            "RtcOffTime": innerList["RtcOffTime"][i],
            "Status": innerList["Status"][i],
            "Pump": innerList["Pump"][i],
            "SequenceData": innerList["SequenceData"][i],
            "IrrigationMethod": innerList["IrrigationMethod"][i],
            "ScheduledStartTime": innerList["ScheduledStartTime"][i],
            "ActualStartTime": innerList["ActualStartTime"][i],
            "ActualStopTime": innerList["ActualStopTime"][i],
            "IrrigationDuration_Quantity": innerList["IrrigationDuration_Quantity"][i],
            "IrrigationQuantityCompleted": innerList["IrrigationQuantityCompleted"][i],
            "IrrigationDurationCompleted": innerList["IrrigationDurationCompleted"][i],
            "ValveFlowrate": innerList["ValveFlowrate"][i],
            "PlannedStartTime": innerList["PlannedStartTime"][i],
            "CentralFilterSite": innerList["CentralFilterSite"][i],
            "LocalFilterSite": innerList["LocalFilterSite"][i],
            "CentralFilterSiteOperationMode": innerList["CentralFilterSiteOperationMode"][i],
            "LocalFilterSiteOperationMode": innerList["LocalFilterSiteOperationMode"][i],
            "CentralFilterSelection": innerList["CentralFilterSelection"][i],
            "LocalFilterSelection": innerList["LocalFilterSelection"][i],
            "CentralFilterSelectionName": innerList["CentralFilterSelectionName"][i],
            "LocalFilterSelectionName": innerList["LocalFilterSelectionName"][i],
            "CentralFilterBeginningOnly": innerList["CentralFilterBeginningOnly"][i],
            "LocalFilterBeginningOnly": innerList["LocalFilterBeginningOnly"][i],
            "CentralFilterLimit": innerList["CentralFilterLimit"][i],
            "LocalFilterLimit": innerList["LocalFilterLimit"][i],
            "CentralFertOnOff": innerList["CentralFertOnOff"][i],
            "LocalFertOnOff": innerList["LocalFertOnOff"][i],
            "CentralFertilizerSite": innerList["CentralFertilizerSite"][i],
            "LocalFertilizerSite": innerList["LocalFertilizerSite"][i],
            "PrePostMethod": innerList["PrePostMethod"][i],
            "Pretime": innerList["Pretime"][i],
            "PostTime": innerList["PostTime"][i],
            "PreQty": innerList["PreQty"][i],
            "PostQty": innerList["PostQty"][i],
            "CentralFertMethod": innerList["CentralFertMethod"][i],
            "LocalFertMethod": innerList["LocalFertMethod"][i],
            "CentralFertChannelSelection": innerList["CentralFertChannelSelection"][i],
            "LocalFertChannelSelection": innerList["LocalFertChannelSelection"][i],
            "CentralFertChannelSelectionName": innerList["CentralFertChannelSelectionName"][i],
            "LocalFertChannelSelectionName": innerList["LocalFertChannelSelectionName"][i],
            "CentralFertilizerChannelDuration": innerList["CentralFertilizerChannelDuration"][i],
            "LocalFertilizerChannelDuration": innerList["LocalFertilizerChannelDuration"][i],
            "CentralFertilizerChannelQuantity": innerList["CentralFertilizerChannelQuantity"][i],
            "LocalFertilizerChannelQuantity": innerList["LocalFertilizerChannelQuantity"][i],
            "CentralFertilizerTankSelection": innerList["CentralFertilizerTankSelection"][i],
            "LocalFertilizerTankSelection": innerList["LocalFertilizerTankSelection"][i],
            "EcBasedOnOff": innerList["EcBasedOnOff"][i],
            "EcSetValue": innerList["EcSetValue"][i],
            "PhBasedOnOff": innerList["PhBasedOnOff"][i],
            "CentralFertilizerChannelDurationCompleted": innerList["CentralFertilizerChannelDurationCompleted"][i],
            "LocalFertilizerChannelDurationCompleted": innerList["LocalFertilizerChannelDurationCompleted"][i],
            "PhSetValue": innerList["PhSetValue"][i],
            "CentralFertilizerChannelOnDuration": innerList["CentralFertilizerChannelOnDuration"][i],
            "CentralFertilizerChannelOffDuration": innerList["CentralFertilizerChannelOffDuration"][i],
            "CentralFertilizerChannelOnPulseCount": innerList["CentralFertilizerChannelOnPulseCount"][i],
            "LocalFertilizerChannelOnDuration": innerList["LocalFertilizerChannelOnDuration"][i],
            "LocalFertilizerChannelOffDuration": innerList["LocalFertilizerChannelOffDuration"][i],
            "LocalFertilizerChannelOnPulseCount": innerList["LocalFertilizerChannelOnPulseCount"][i],
            "CentralFertilizerChannelOnDurationCompleted": innerList["CentralFertilizerChannelOnDurationCompleted"][i],
            "CentralFertilizerChannelOffDurationCompleted": innerList["CentralFertilizerChannelOffDurationCompleted"][i],
            "CentralFertilizerChannelOnPulseCountCompleted": innerList["CentralFertilizerChannelOnPulseCountCompleted"][i],
            "LocalFertilizerChannelOnDurationCompleted": innerList["LocalFertilizerChannelOnDurationCompleted"][i],
            "LocalFertilizerChannelOffDurationCompleted": innerList["LocalFertilizerChannelOffDurationCompleted"][i],
            "LocalFertilizerChannelOnPulseCountCompleted": innerList["LocalFertilizerChannelOnPulseCountCompleted"][i],
            "CentralFertChannelSelectionCompleted": innerList["CentralFertChannelSelectionCompleted"][i],
            "LocalFertChannelSelectionCompleted": innerList["LocalFertChannelSelectionCompleted"][i],
            "CentralBoosterDurationCompleted": innerList["CentralBoosterDurationCompleted"][i],
            "LocalBoosterDurationCompleted": innerList["LocalBoosterDurationCompleted"][i],
            "IrrigationBeginningFlag": innerList["IrrigationBeginningFlag"][i],
            "CentralFertBeginningFlag": innerList["CentralFertBeginningFlag"][i],
            "LocalFertBeginningFlag": innerList["LocalFertBeginningFlag"][i],
            "CentralFertChannelBeginningFlag": innerList["CentralFertChannelBeginningFlag"][i],
            "LocalFertChannelBeginningFlag": innerList["LocalFertChannelBeginningFlag"][i],
            "BeginningTime": innerList["BeginningTime"][i],
            "ProgramDuration": innerList["ProgramDuration"][i],
            "Factor": innerList["Factor"][i],
          };
          scheduleListFromMqtt.add(resultDict);
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
      if (scheduleListFromMqtt.isNotEmpty) {
        scheduleList = scheduleListFromMqtt;
      }
      notifyListeners();
    });
  }
}
