import 'dart:async';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';
import '../state_management/MqttPayloadProvider.dart';

class MQTTManager {
  static MQTTManager? _instance;
  MqttPayloadProvider? providerState;
  MqttBrowserClient? _client;
  final int _maxAttempts = 5;

  factory MQTTManager() {
    _instance ??= MQTTManager._internal();
    return _instance!;
  }

  MQTTManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  void initializeMQTTClient({MqttPayloadProvider? state}) {
    String uniqueId = const Uuid().v4();
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

  Future<void> connect() async {
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
    _client!.subscribe(topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      providerState?.updateReceivedPayload(pt);
    });
  }

  Future<void> publish(String message, String topic) async {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    providerState?.setAppConnectionState(MQTTConnectionState.disconnected);

    Future.delayed(const Duration(seconds: 3), () {
      retryConnect(_maxAttempts);
    });
  }

  void onConnected() {
    assert(isConnected);
    providerState?.setAppConnectionState(MQTTConnectionState.connected);
    print('Mosquitto client connected....');
  }

  void unsubscribeTopic(String topic) {
    _client!.unsubscribe(topic);
    print('unsubscribeTopic from $topic');
  }

  void unsubscribeFromAllTopics(String topic) {
    _client!.unsubscribe(topic);
    print('Unsubscribed from $topic');
  }

  Future<bool> retryConnect(int maxAttempts) async {
    return await _retryConnect(maxAttempts);
  }

  Future<bool> _retryConnect(int maxAttempts) async {
    int attempts = 0;
    bool isConnected = false;

    while (attempts < maxAttempts && !isConnected) {
      try {
        await connect();
        isConnected = this.isConnected;
      } catch (e) {
        print('Connection attempt $attempts failed: $e');
      }

      if (!isConnected) {
        await Future.delayed(const Duration(seconds: 2));
      }

      attempts++;
    }

    return isConnected;
  }
}