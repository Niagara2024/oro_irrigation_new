
import 'dart:convert';

import 'package:flutter/cupertino.dart';

enum MQTTConnectionState { connected, disconnected, connecting }
class MqttPayloadProvider with ChangeNotifier{
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String _receivedText = '';
  int _wifiStrength = 0;
  List<dynamic> _list2401 = [];

  void setReceivedText(String payload) {
    _receivedText = payload;

    try {

      // Parse JSON
      Map<String, dynamic> data = jsonDecode(payload);
      // Access values
      _wifiStrength = data['2400'][0]['WifiStregth'];
      _list2401 = data['2400'][0]['2401'];

      for (var item in _list2401) {
        Map<String, dynamic> entry = item as Map<String, dynamic>;

        // print('SNo: ${entry['SNo']}');
        // print('SVolt: ${entry['SVolt']}');
        // print('BatVolt: ${entry['BatVolt']}');
        // print('RlyStatus: ${entry['RlyStatus']}');
        // print('Sensor: ${entry['Sensor']}');
        // print('Status: ${entry['Status']}');
        // print('---');
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

  String get getReceivedText => _receivedText;
  int get receivedWifiStrength => _wifiStrength;
  List<dynamic> get receivedNodeStatus => _list2401;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;

}