
import 'package:flutter/cupertino.dart';

enum MQTTConnectionState { connected, disconnected, connecting }
class MqttPayloadProvider with ChangeNotifier{
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  String _receivedText = '';

  void setReceivedText(String text) {
    _receivedText = text;
    notifyListeners();
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;

}