import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../state_management/MqttPayloadProvider.dart';

class MQTTManager {
  static MQTTManager? _instance;
  MqttPayloadProvider? _currentState;
  MqttBrowserClient? _client;

  factory MQTTManager() {
    _instance ??= MQTTManager._internal();
    return _instance!;
  }

  MQTTManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  void initializeMQTTClient({MqttPayloadProvider? state}) {
    if (_client == null) {
      _currentState = state;
      _client = MqttBrowserClient('ws://192.168.1.141', 'flutter_identifier');
      _client!.port = 9001;
      _client!.keepAlivePeriod = 20;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);

      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier('flutter_identifier')
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
        _currentState?.setAppConnectionState(MQTTConnectionState.connecting);
        await _client!.connect();
      } on Exception catch (e) {
        print('client exception - $e');
        disconnect();
      }
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void subscribeToTopic(String topic) {
    assert(isConnected);
    _client!.subscribe(topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState?.setReceivedText(pt);

      print('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });

  }


  void publish(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
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
    }
    _currentState?.setAppConnectionState(MQTTConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState?.setAppConnectionState(MQTTConnectionState.connected);
    print('Mosquitto client connected....');
  }
}
