import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  late MqttServerClient _client;
  final Map<String, Function(String)> _messageHandlers = {};
  bool _isConnected = false;

  bool get isConnected => _isConnected; // Public getter for connection status

  Future<void> connect() async {
    if (_isConnected) return;

    final String broker = dotenv.env['MQTT_BROKER_URL'] ??
        '308a324019804dfc8f98afa69818681a.s1.eu.hivemq.cloud';
    final String username = dotenv.env['MQTT_USERNAME'] ?? 'deepa42';
    final String password = dotenv.env['MQTT_PASSWORD'] ?? 'deepa42@Lpa';

    _client = MqttServerClient.withPort(
        broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}', 8883);
    _client.secure = true;
    _client.keepAlivePeriod = 30;
    _client.logging(on: false);

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
      _isConnected = true;

      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (var message in messages) {
          final payload = MqttPublishPayload.bytesToStringAsString(
              (message.payload as MqttPublishMessage).payload.message);
          _messageHandlers[message.topic]?.call(payload);
        }
      });
    } catch (e) {
      _isConnected = false;
      print('MQTT Connection Failed: $e');
    }
  }

  void subscribe(String topic, Function(String) handler) {
    if (!_isConnected) return;
    if (_messageHandlers.containsKey(topic)) return;

    _messageHandlers[topic] = handler;
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publish(String topic, String message) {
    if (!_isConnected) return;

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void publishMessage(String topic, String message) {
    publish(topic, message);
  }

  void unsubscribe(String topic) {
    if (!_isConnected) return;
    _messageHandlers.remove(topic);
    _client.unsubscribe(topic);
  }

  void disconnect() {
    if (!_isConnected) return;
    _client.disconnect();
    _isConnected = false;
  }
}
