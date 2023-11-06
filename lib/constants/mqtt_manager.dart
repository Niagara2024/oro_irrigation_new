
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import '../state_management/mqtt_message_provider.dart';
import 'CounterBloc.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  MqttBrowserClient _mqttClient;
  MqttBrowserClient get mqttClient => _mqttClient;
  final counterBloc = CounterBloc();

  factory MqttService() {
    return _instance;
  }

  MqttService._internal() : _mqttClient = MqttBrowserClient("ws://192.168.1.141", "")
  {
    final connectMessage = MqttConnectMessage()
        .authenticateAs('niagara', 'niagara@123')
        .withClientIdentifier("ClientIdentifier-flutter")
        .withWillMessage('connection-failed')
        .withWillTopic('willTopic')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withWillTopic('failed');

    _mqttClient.connectionMessage = connectMessage;

    _initMqtt();
  }

  //kamaraj

  Future<void> _initMqtt() async
  {
    mqttClient.logging(on: false);
    mqttClient.port = 9001;//web
    mqttClient.keepAlivePeriod = 60;
    mqttClient.onSubscribed = onSubscribed;
    mqttClient.onDisconnected = onDisconnected;
    mqttClient.autoReconnect = true;

    try {
      await _mqttClient.connect();
      print('Connected to the MQTT broker');
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  Future<void> onDisconnected() async {
    print('MqttService Disconnected');
    _mqttClient.resubscribeOnAutoReconnect;
  }

  void subscribeToTopic(String topic, BuildContext contact)
  {
    if (mqttClient.connectionStatus?.state == MqttConnectionState.connected)
    {
      mqttClient.subscribe(topic, MqttQos.atLeastOnce);
      _listenMqtt(contact);
    } else {
      print('MQTT client is not connected. Cannot subscribe to the topic.');
    }
  }

  void onSubscribed(String? topic) {
    print('Subscribed to topic: $topic');
  }

  Future<void> publishMessage(String topic, String message, {bool retain = true}) async
  {
    if (mqttClient.connectionStatus?.state == MqttConnectionState.connected)
    {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      if (builder.payload != null) {
        mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      } else {
        print('Payload is null. Cannot publish message.');
      }

      builder.clear();
    } else {
      print('MQTT client is not connected. Cannot publish message.');
    }
  }

  void _listenMqtt(BuildContext context)
  {
    mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c)
    {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //print('Received message: $payload from topic: ${c[0].topic}>');

      if (payload.contains("updateCustomerAccount"))
      {
        print(payload);
        Provider.of<MessageProvider>(context, listen: false).setMessage(payload);

      }

      //final body = json.decode(payload);
      //print(body);
      /*
      final cC = body['cC'] as String;
      final cM = body['cM'] as String;
      final cD = body['cD'] as String;
      final cT = body['cT'] as String;
      final mC = body['mC'] as String;

      if (mC == "LD01") {
        liveMsgList.clear();
        liveSyncDT = '$cD - $cT';
        //setState(() => liveMsgList = cM.split(","));
      } else if (mC == "SMS") {
        //setState(() => smsSyncDT = '$cD - $cT');
      }*/

    });

  }

}


