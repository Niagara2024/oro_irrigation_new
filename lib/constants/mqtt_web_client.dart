
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttWebClient {

  MqttBrowserClient client;
  MqttWebClient({required this.onMqttPayloadReceived}) : client = MqttBrowserClient('ws://3.0.229.165', 'client-1');

  final Function(String) onMqttPayloadReceived;

  Future<int> connectAndSubscribe() async {
    client.logging(on: false);
    client.setProtocolV31();
    client.keepAlivePeriod = 20;
    client.port = 1883;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('client-1').authenticateAs('niagara', 'niagara@123')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('client exception - $e');
      client.disconnect();
      return -1;
    }

    //event listeners
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =  MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      onMqttPayloadReceived(pt);
    });

    return 0;
  }

  /*Future<int> main() async {

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('connectionStatus successfully');
    }
    else{
      client.logging(on: false);
      client.setProtocolV311();
      // client.keepAlivePeriod = 60;
      // client.connectTimeoutPeriod = 2000; // milliseconds
      // client.autoReconnect = true;
      client.port = 9001;
      client.onDisconnected = onDisconnected;
      client.onConnected = onConnected;
      client.onSubscribed = onSubscribed;
      //client.pongCallback = pong;
      // client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

      final connMess = MqttConnectMessage()
          .withClientIdentifier('Mqtt_MyClientUniqueId')
          .withWillTopic('will-topic') // If you set this you must set a will message
          .withWillMessage('My Will message')
          .startClean() // Non persistent session for testing
          .withWillQos(MqttQos.atLeastOnce);
      print('Mosquitto client connecting....');
      client.connectionMessage = connMess;


      try {
        await client.connect();
      } on Exception catch (e) {
        print('client exception - $e');
        client.disconnect();
        return -1;
      }

      /// Check we are connected
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('Mosquitto client connected');
      } else {
        print('ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
        client.disconnect();
        return -1;
      }

      final prefs = await SharedPreferences.getInstance();
      List<String> userDeviceIDList = (prefs.getStringList('userDeviceIDList') ?? []);

      for(int i=0; i<userDeviceIDList.length; i++){
        String topic = userDeviceIDList[i];
        print('Subscribing to the $topic topic');
        client.subscribe(topic, MqttQos.atMostOnce);
      }

      /// Ok, lets try a subscription
      /* print('Subscribing to the FirmwareToApp/E8FB1C3501D1 topic');
    const topic = 'FirmwareToApp/E8FB1C3501D9'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);*/

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final pt =  MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        onMqttPayloadReceived(pt);

        //mqttPayloadModel.updatePayload(pt.toString());
        //print('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
        //print('');
      });

      client.published!.listen((MqttPublishMessage message) {
        print('Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
      });
    }
    return 0;
  }*/

  Future<void> subscribeTopic(String topic) async {
    print('Subscribing to the ${topic} topic');
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  Future<void> unsubscribeTopic(String topic) async {
    print('Un Subscribing to the ${topic} topic');
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  Future<void> publishMessage(String topic, String message) async {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('Cannot publish message, MQTT client is not connected');
     // reconnect();
    }
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    //main();
    if (client.connectionStatus!.disconnectionOrigin ==  MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
      //main();
    }else{
      //reconnect();
    }
  }

  Future<void> reconnect() async {
    while (true) {
      try {
        await client.connect();
        if (client.connectionStatus!.state == MqttConnectionState.connected) {
          print('Reconnected successfully');
          break;
        }
      } catch (e) {
        print('Reconnection attempt failed: $e');
      }
      await Future.delayed(Duration(seconds: 5)); // Delay between reconnection attempts
    }
  }

  /// The successful connect callback
  Future<void> onConnected() async {
    print('OnConnected client callback - Client connection was sucessful');

    final prefs = await SharedPreferences.getInstance();
    List<String> userDeviceIDList = prefs.getStringList('userDeviceIDList') ?? [];
    for (int i = 0; i < userDeviceIDList.length; i++) {
      String topic = userDeviceIDList[i];
      print('Subscribing to the $topic topic');
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  /// Pong callback
  void pong() {
    print('Ping response client callback invoked');
  }

}

