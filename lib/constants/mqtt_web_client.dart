

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

final client = MqttBrowserClient('ws://192.168.1.141', '');

class MqttWebClient {

  Future<int> init() async
  {
    if(client.connectionStatus!.state == MqttConnectionState.connected)
    {
      print('client Already connected');
    }else{

      client.logging(on: false);
      client.setProtocolV311();
      client.keepAlivePeriod = 20;
      client.connectTimeoutPeriod = 5000; // milliseconds
      client.port = 9001;
      //client.autoReconnect = true;
      //client.resubscribeOnAutoReconnect = true;
     // client.onAutoReconnect = onAutoReconnect;
      //client.onAutoReconnected = onAutoReconnected;
      client.onConnected = onConnected;
      client.onSubscribed = onSubscribed;

      client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

      final connMess = MqttConnectMessage()
          .withClientIdentifier('Mqtt_MyClientUniqueId')
          .withWillTopic('will-topic') // If you set this you must set a will message
          .withWillMessage('My Will message')
          .startClean() // Non persistent session for testing
          .withWillQos(MqttQos.atLeastOnce);
      print('Mosquitto client connecting....');
      client.connectionMessage = connMess;

      connectMqtt();
    }

    return 0;
  }

  Future<void> connectMqtt() async {

    try {
      await client.connect();
    } on Exception catch (e) {
      print('client exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print('ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =  MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });

    client.published!.listen((MqttPublishMessage message) {
      print('Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });

  }

  Future<void> publishMessage(String topic, String message, {bool retain = true}) async
  {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Subscription confirmed for topic $topic');
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print("MQTT client is not connected.");
    }

  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void unsubscribeFromTopic(String topic) {
    print('Un Subscription confirmed for topic $topic');
  }



  void onAutoReconnect() {
    print('onAutoReconnect client callback - Client auto reconnection sequence will start');
  }

  /// The post auto re connect callback
  void onAutoReconnected() {
    print('onAutoReconnected client callback - Client auto reconnection sequence has completed');
  }

  /// The successful connect callback
  void onConnected() {
    print('OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  Future<void> pong() async {
    print('Ping response client callback invoked');
  }
}

