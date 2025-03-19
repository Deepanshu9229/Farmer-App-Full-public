const mqtt = require("mqtt");
const client = mqtt.connect("308a324019804dfc8f98afa69818681a.s1.eu.hivemq.cloud"); // Replace with your broker

exports.sendWiFiCredentials = async (req, res) => {
  const { farmId, pumpId } = req.params; // Directly get pumpId from params
  const { ssid, password } = req.body; // Only SSID and password needed here

  if (!ssid || !password) {
    return res.status(400).json({ error: "SSID and password are required" });
  }

  const topic = `farm/${farmId}/pump/${pumpId}/wifi/credentials`; // Specific topic for credentials
  const payload = JSON.stringify({ ssid, password });

  client.publish(topic, payload, (error) => {
    if (error) {
      console.error("MQTT publish error:", error);  // Add error logging
      return res.status(500).json({ error: "Failed to publish MQTT message" });
    }
    res.json({ message: "Wi-Fi credentials sent via MQTT" });
  });
};