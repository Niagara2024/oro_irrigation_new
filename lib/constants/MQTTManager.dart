import 'dart:async';

import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';
import '../state_management/MqttPayloadProvider.dart';

class MQTTManager {
  static MQTTManager? _instance;
  MqttPayloadProvider? providerState;
  MqttBrowserClient? _client;

  factory MQTTManager() {
    _instance ??= MQTTManager._internal();
    return _instance!;
  }

  MQTTManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  void initializeMQTTClient({MqttPayloadProvider? state}) {

    String uniqueId = const Uuid().v4();

    //development
    // String baseURL = 'ws://192.168.68.141';
    // int port = 9001;

    //cloud
     String baseURL = 'ws://13.235.254.21:8083/mqtt';
     int port = 8083;

    if (_client == null) {
       providerState = state;
      _client = MqttBrowserClient(baseURL, uniqueId);
      _client!.port = port;
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);
      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
          print('Mosquitto client connecting....');
      _client!.connectionMessage = connMess;
    }
  }

  void connect() async {
    assert(_client != null);
    if (!isConnected) {
      try {
        print('Mosquitto start client connecting....');
        providerState?.setAppConnectionState(MQTTConnectionState.connecting);
        await _client!.connect();
      } on Exception catch (e, stackTrace) {
        print('Client exception - $e');
        print('StackTrace: $stackTrace');
        disconnect();
      }
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void subscribeToTopic(String topic) {
    try {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        providerState?.updateReceivedPayload(pt);
      });
    } catch (e) {
      print('Error while subscribing to topic: $e');
    }
  }

  void publish(String message, String topic) {
    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } catch (e) {
      print('Error while publishing message: $e');
    }
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
      print('OnDisconnected callback is solicited, this is correct');
      //providerState?.mqttConnectionStatus(false);
    }
    providerState?.setAppConnectionState(MQTTConnectionState.disconnected);

    //connect();

  }

  void onConnected() {
    assert(isConnected);
    providerState?.setAppConnectionState(MQTTConnectionState.connected);
    print('Mosquitto client connected....');
    providerState?.mqttConnectionStatus(true);
  }

  void unsubscribeFromAllTopics(String topic) {
    _client!.unsubscribe(topic);
    print('Unsubscribed from $topic');
  }

}
