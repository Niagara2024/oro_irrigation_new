import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MqttClientService
{
  //MqttServerClient browserClient = MqttServerClient("192.168.1.141", "");
  MqttBrowserClient browserClient = MqttBrowserClient("ws://192.168.1.141", "");
  static StreamSubscription? mqttListen;

  String ctrlName = '', liveSyncDT = '', smsSyncDT = '';
  List<String> liveMsgList = [];
  Future<void> initMqtt() async
  {
    if (browserClient.connectionStatus?.state == MqttConnectionState.connected) {
      log('MqttService already Connected');
    } else {
      //browserClient = MqttServerClient("192.168.1.141", "");//mobile or tap
      browserClient = MqttBrowserClient("ws://192.168.1.141", "");//web
      browserClient.logging(on: false);
      //browserClient.port = 1883;//mobile or tap
      browserClient.port = 9001;//web
      browserClient.keepAlivePeriod = 60;
      browserClient.onDisconnected = onDisconnected;
      browserClient.autoReconnect = false;
      browserClient.onSubscribed = onSubscribed;
      browserClient.onConnected = onConnected;
      browserClient.onUnsubscribed = onUnsubscribed;
      browserClient.onSubscribeFail = onSubscribeFail;

      final mqttMsg = MqttConnectMessage()
          .authenticateAs('niagara', 'niagara@123')
          .withClientIdentifier("ClientIdentifier-flutter")
          .withWillMessage('connection-failed')
          .withWillTopic('willTopic')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce)
          .withWillTopic('failed');
      browserClient.connectionMessage = mqttMsg;
      await _connectMqtt();
    }
  }

  void onConnected() async {
    log('MqttService Connected');
    final prefs = await SharedPreferences.getInstance();
    final subscribeTopic = prefs.getString('subscribeTopic') ?? "Nop";
    subscribeTopicMqtt('tweet/867624064504847');
    if (subscribeTopic != "Nop") subscribeTopicMqtt('tweet/867624064504847');
    _listenMqtt();
  }

  void onDisconnected() {
    log('MqttService Disconnected');
  }

  static void onSubscribed(String? topic) {
    log('MqttService Subscribed topic is : $topic');
  }

  static void onUnsubscribed(String? topic) {
    log('MqttService Unsubscribed topic is : $topic');
  }

  static void onSubscribeFail(String? topic) {
    log('MqttService Failed subscribe topic : $topic');
  }

  Future<void> _connectMqtt() async
  {
    if (browserClient.connectionStatus!.state != MqttConnectionState.connected) {
      try {
        await browserClient.connect();
      } catch (e) {
        log('MqttService Connection failed $e');
      }
    } else {
      log('MqttService MQTT Server already connected');
    }
  }

  Future<void> disconnectMqtt() async {
    if (browserClient.connectionStatus!.state == MqttConnectionState.connected) {
      try {
        browserClient.disconnect();
      } catch (e) {
        log('MqttService Disconnection Failed $e');
      }
    } else {
      log('MQTT Server already disconnected');
    }
  }

  Future<void> subscribeTopicMqtt(String topic) async {
    if (browserClient.connectionStatus?.state == MqttConnectionState.connected) {
      browserClient.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      initMqtt();
    }
  }

  void publish(String topic, String message, {bool retain = true}) {
    final builder = MqttClientPayloadBuilder()..addString(message);
    browserClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: retain);
    builder.clear();
  }

  void unSubscribeTopic(String topic) {
    if (browserClient.connectionStatus?.state == MqttConnectionState.connected) {
      browserClient.unsubscribe(topic);
    } else {
      initMqtt();
    }
  }

  void onClose() {
    mqttListen?.cancel();
    disconnectMqtt();
  }

  void _listenMqtt()
  {
    mqttListen = browserClient.updates!.listen((dynamic t) async {
      final recMessage = t[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      log(message);

     /* final body = json.decode(message);
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