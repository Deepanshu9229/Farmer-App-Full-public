
// lib/services/mqtt_service.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  // Singleton pattern
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  late MqttServerClient client;

  /// Connect to the broker.
  Future<void> connect({String broker = 'broker.hivemq.com', int port = 1883}) async {
    client = MqttServerClient(broker, '');
    client.port = port;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean() // Start with a clean session.
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT connection exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      print('MQTT client connection failed - state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
  }

  void _onConnected() {
    print('MQTT client connected');
  }

  void _onDisconnected() {
    print('MQTT client disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  /// Subscribe to a topic.
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    client.subscribe(topic, qos);
  }

  /// Publish a message to a topic.
  void publish(String topic, String message, {MqttQos qos = MqttQos.atLeastOnce}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, qos, builder.payload!);
  }

  /// Returns the stream of incoming messages.
  Stream<List<MqttReceivedMessage<MqttMessage>>>? get messageStream => client.updates;
}
