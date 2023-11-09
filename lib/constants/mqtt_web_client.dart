

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

final client = MqttBrowserClient('ws://192.168.1.141', '');

class MqttWebClient {

  Future<int> init() async
  {
    client.logging(on: false);
    client.setProtocolV311();

    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    client.keepAlivePeriod = 20;
    /// The connection timeout period can be set if needed, the default is 5 seconds.
    client.connectTimeoutPeriod = 2000; // milliseconds
    /// The ws port for Mosquitto is 9001, for wss it is 8080
    client.port = 9001;
    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;
    /// Add the successful connection callback
    client.onConnected = onConnected;
    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = onSubscribed;
    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.

    //client.pongCallback = pong;

    /// Set the appropriate websocket headers for your connection/broker.
    /// Mosquito uses the single default header, other brokers may be fine with the
    /// default headers.
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('will-topic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('Mosquitto client connecting....');
    client.connectionMessage = connMess;

    connectMqtt();

    return 0;
  }

  Future<void> connectMqtt() async {
    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
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

    /// Ok, lets try a subscription
    /* print('EXAMPLE::Subscribing to the test/lol topic');
    const topic = 'test/lol'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);*/

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =  MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });

    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    client.published!.listen((MqttPublishMessage message) {
      print('Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });

    /// Lets publish to our topic
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    //const pubTopic = 'Dart/Mqtt_client/testtopic';
    //final builder = MqttClientPayloadBuilder();
    // builder.addString('Hello from mqtt_client');

    /// Subscribe to it
    //print('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
    //client.subscribe(pubTopic, MqttQos.exactlyOnce);

    /// Publish it
    //print('EXAMPLE::Publishing our topic');
    //client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

    /// Ok, we will now sleep a while, in this gap you will see ping request/response
    /// messages being exchanged by the keep alive mechanism.
    //print('EXAMPLE::Sleeping....');
    //await MqttUtilities.asyncSleep(60);

    /// Finally, unsubscribe and exit gracefully
    // print('EXAMPLE::Unsubscribing');
    //client.unsubscribe(topic);

    /// Wait for the unsubscribe message from the broker if you wish.
    //await MqttUtilities.asyncSleep(2);
    //print('EXAMPLE::Disconnecting');
    //client.disconnect();
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

  /// The unsolicited disconnect callback
  Future<void> onDisconnected() async {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    //main();
     // Uncomment this line to automatically reconnect
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

