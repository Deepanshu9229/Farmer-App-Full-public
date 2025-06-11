const express = require("express");
const router = express.Router();
const mqtt = require("mqtt");
const fs = require("fs");
const path = require("path");

// Paths to Certificate Files
const CERT_PATH = path.join(__dirname, "../../certificate/cert.pem"); // Move up two levels

// Read the Certificate File
const caCert = fs.readFileSync(CERT_PATH);

// MQTT Broker Details
const MQTT_BROKER = "mqtts://376utyjgh88ughjhtytt769818681a.s1.eu.hivemq.cloud";
const MQTT_PORT = 8883;
const MQTT_USERNAME = "87656yhgg";
const MQTT_PASSWORD = "rtgsfb87";

// MQTT Client Setup with Certificate
const client = mqtt.connect(MQTT_BROKER, {
  port: MQTT_PORT,
  username: MQTT_USERNAME,
  password: MQTT_PASSWORD,
  protocol: "mqtts",
  ca: caCert, // ✅ Attach Certificate
  rejectUnauthorized: true, // Set to false for testing (not recommended in production)
});

// Handle Connection Events
client.on("connect", () => {
  console.log("✅ Connected to MQTT Broker with SSL Certificate");
});

client.on("error", (err) => {
  console.error("❌ MQTT Connection Error:", err.message);
  client.end();
});

// Endpoint to Send WiFi Credentials
router.post("/api/farmer/farm/:farmId/pump/:pumpId/wifi/credentials", async (req, res) => {
  const { farmId, pumpId } = req.params;
  const { ssid, password } = req.body;

  if (!ssid || !password) {
    return res.status(400).json({ error: "SSID and password are required" });
  }

  const topic = `farm/${farmId}/pump/${pumpId}/wifi/credentials`;
  const payload = JSON.stringify({ ssid, password });

  if (!client.connected) {
    console.error("❌ MQTT is not connected. Cannot publish message.");
    return res.status(500).json({ error: "MQTT is not connected" });
  }

  client.publish(topic, payload, (error) => {
    if (error) {
      console.error("❌ MQTT Publish Error:", error);
      return res.status(500).json({ error: "Failed to publish MQTT message" });
    }
    res.json({ message: "✅ Wi-Fi credentials sent via MQTT" });
  });
});

module.exports = router;
