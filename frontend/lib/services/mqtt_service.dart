import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient _client;
  final StreamController<List<MqttReceivedMessage<MqttMessage>>> _messageStreamController = StreamController.broadcast();

  Stream<List<MqttReceivedMessage<MqttMessage>>> get messageStream => _messageStreamController.stream;

  MQTTService() {
    _client = MqttServerClient('your-mqtt-broker-url', '');
    _client.port = 1883; // Use the correct port (1883 for unencrypted, 8883 for SSL/TLS)
    _client.keepAlivePeriod = 60;
    _client.logging(on: false);
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
  }

  // Connect to MQTT broker
  Future<void> connect() async {
    try {
      _client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client')
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      await _client.connect();
    } catch (e) {
      print('MQTT Connection Error: $e');
      _client.disconnect();
    }

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      _messageStreamController.add(messages);
    });
  }

  // Subscribe to a topic
  void subscribe(String topic) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      print('MQTT not connected. Cannot subscribe.');
    }
  }

  // Publish a message
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // Disconnect from MQTT
  void disconnect() {
    _client.disconnect();
  }

  void _onConnected() => print('Connected to MQTT broker');
  void _onDisconnected() => print('Disconnected from MQTT broker');
  void _onSubscribed(String topic) => print('Subscribed to topic: $topic');
}