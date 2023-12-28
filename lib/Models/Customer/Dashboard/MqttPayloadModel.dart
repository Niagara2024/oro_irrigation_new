import 'package:flutter/material.dart';

class MqttPayloadProviderModel extends ChangeNotifier {
  String payload = '';

  String getPayload() {
    return payload;
  }

  void updatePayload(String newPayload) {
    print('Updating payload: $newPayload');
    payload = newPayload;
    print('Updated payload: $payload');
    notifyListeners();
  }
}