#ifndef WIFI_HANDLER_H
#define WIFI_HANDLER_H

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ======================
// WiFi Configuration
// ======================
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// ======================
// API Endpoints  
// ======================
String SERVER_BASE = "https://smartdustbin-guflums4.b4a.run";   // replace with your backend URL
String POST_URL    = SERVER_BASE + "/bin/update-fill-level/";
String GET_URL     = SERVER_BASE + "/bin/get-fill-level/002";
String CONTROL_URL = SERVER_BASE + "/bin/control";

// ======================
// Bin Configuration
// ======================
const char* BIN_ID = "002";
const float BIN_HEIGHT_CM = 25.0; // constant height of bin cm

// ======================
// Timing (non-blocking)
// ======================
unsigned long lastPostTime = 0;
const unsigned long postInterval = 30000;  // 30 seconds

// ======================
// WiFi Setup
// ======================
void wifiSetup() {
  Serial.println("\n[WiFi] Connecting...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  unsigned long startAttempt = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttempt < 15000) {
    Serial.print(".");
    delay(500);
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n❌ WiFi connection failed!");
  }
}

// ======================
// Send Data to Server (POST)
// ======================
void sendFillData(float distance_cm) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[WiFi] Disconnected — attempting reconnect...");
    WiFi.reconnect();
    delay(2000);
    return;
  }

  HTTPClient http;
  http.begin(POST_URL);
  http.addHeader("Content-Type", "application/json");

  // --- JSON Payload ---
  String payload = "{";
  payload += "\"bin_id\":\"" + String(BIN_ID) + "\",";
  payload += "\"distance_cm\":" + String(distance_cm, 1) + ",";
  payload += "\"bin_height_cm\":" + String(BIN_HEIGHT_CM, 1);
  payload += "}";

  Serial.println("\n[POST] Sending data:");
  Serial.println(payload);

  int httpCode = http.POST(payload);

  if (httpCode > 0) {
    Serial.print("[POST] Response code: ");
    Serial.println(httpCode);
    if (httpCode == 200) {
      String resp = http.getString();
      Serial.println("[POST] Server reply:");
      Serial.println(resp);
    }
  } else {
    Serial.print("[POST] Failed, error: ");
    Serial.println(http.errorToString(httpCode));
  }

  http.end();
}

// ======================
// Fetch Bin State (GET)
// ======================
void fetchServerData() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(GET_URL);
  int httpCode = http.GET();
  if (httpCode == 200) {
    String payload = http.getString();
    Serial.println("[GET] Server data:");
    Serial.println(payload);
  } else {
    Serial.print("[GET] Error: ");
    Serial.println(httpCode);
  }
  http.end();
}

// ======================
// Fetch Control Commands (GET)
// ======================
void fetchControlCommands() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(CONTROL_URL + "?bin_id=" + String(BIN_ID));
  int httpCode = http.GET();

  if (httpCode == 200) {
    String payload = http.getString();
    Serial.println("[GET Control] Server data:");
    Serial.println(payload);

    // Parse JSON (requires ArduinoJson library)
    StaticJsonDocument<256> doc;
    DeserializationError err = deserializeJson(doc, payload);
    if (!err) {
      bool vacuum_on = doc["vacuum_on"];
      bool lid_open  = doc["lid_open"];

      // Apply relay
      digitalWrite(RELAY_PIN, vacuum_on ? HIGH : LOW);
      relayState = vacuum_on;

      // Apply lid servo
      if (lid_open && !doorOpen) {
        moveServos(startAngle, stopAngle, servoStepDelay);
        doorOpen = true;
      } else if (!lid_open && doorOpen) {
        moveServos(stopAngle, startAngle, servoStepDelay);
        doorOpen = false;
      }
    }
  } else {
    Serial.print("[GET Control] Error: ");
    Serial.println(httpCode);
  }
  http.end();
}

// ======================
// WiFi Periodic Handler
// ======================
void wifiLoop(float distance_cm) {
  if (millis() - lastPostTime >= postInterval) {
    lastPostTime = millis();
    Serial.println("\n🌐 Posting data to server...");
    sendFillData(distance_cm);

    // Also fetch control commands
    fetchControlCommands();
  }
}

#endif
