# 🌾 Farmer App with ESP32 IoT Control

This project allows wireless control of IoT devices like motors, lights, or pumps using an **ESP32 microcontroller** and a **Flutter-based mobile app**. It's ideal for smart farming and home automation where devices are controlled over Wi-Fi.

**Demo Video -** - https://www.youtube.com/watch?v=bEw0-vhC0tY

## 📱 Features

- 🔌 Turn motor or light ON/OFF from mobile
- 📶 ESP32 and mobile communicate via Wi-Fi
- 📲 Clean and responsive Flutter app


## 🔧 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: NodeJs, Express
- **IoT Controller**: ESP32
- **Communication**: Wi-Fi (AP or same LAN)/ MQTT
- **Firmware**: Arduino C++ (ESP32 sketch)


### ⚙️ ESP32 Setup

1. Power ESP32 via USB or 5V adapter  
2. Flash the Arduino code (`control_motor.ino`) to ESP32  
3. Connect a relay to ESP32 GPIO to control a motor/light

