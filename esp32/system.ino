#include <ArduinoJson.h>
#include <Firebase_ESP_Client.h>
#include <HTTPClient.h>
#include <NTPClient.h>
#include <TimeLib.h>
#include <WebServer.h>
#include <WiFi.h>
#include <WiFiUdp.h>
// #include <addons/RTDBHelper.h>   // 用于调试
#include <addons/TokenHelper.h>  // 用于生成token

// WiFi設定
const char* ssid = "wifi-name";
const char* password = "wifi-password";

// Firebase项目配置
#define API_KEY "firebase api key"
#define FIREBASE_PROJECT_ID "aiot-proj"
#define USER_EMAIL "user-email"
#define USER_PASSWORD "user-password"

// Firebase实例和配置对象
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// NTP客戶端和UDP
WiFiUDP udp;
NTPClient ntpClient(udp, "pool.ntp.org", 28800);  // GMT+8
WebServer server(80);

const int relayPin1 = 2;  // 繼電器連接的GPIO
const int relayPin2 = 4;
const int beePin = 18;
const int switchPin1 = 12;
const int switchPin2 = 13;

// box state variable
int box1 = 0;
int box2 = 0;
int notify15_hour;
int notify15_minute;
int notify30_hour;
int notify30_minute;
int has_15minute = 0;
int has_30minute = 0;
int has_notify30 = 0;
int has_notify = 0;

// firebase variable
const char* breakfast_hour;
const char* breakfast_minute;
const char* dinner_hour;
const char* dinner_minute;

// line notify
const char* lineToken = "line api";

void setup() {
    Serial.begin(115200);
    // 設定電磁鐵
    pinMode(relayPin1, OUTPUT);
    pinMode(relayPin2, OUTPUT);
    pinMode(switchPin1, INPUT_PULLUP);
    pinMode(switchPin2, INPUT_PULLUP);
    // 設定蜂鳴器
    pinMode(beePin, OUTPUT);
    digitalWrite(relayPin1, LOW);
    digitalWrite(relayPin2, LOW);

    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("");
    Serial.print("Connected to WiFi network with IP Address: ");
    Serial.println(WiFi.localIP());

    ntpClient.begin();
    ntpClient.forceUpdate();  // 立即更新時間

    server.on("/relay", handleRelay);
    server.begin();
    Serial.println("HTTP server started");

    // 配置Firebase
    config.api_key = API_KEY;
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;
    config.token_status_callback = tokenStatusCallback;  // 监听token生成过程

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
}

// flutter控制
void handleRelay() {
    if (server.hasArg("state")) {
        int state = server.arg("state").toInt();
        digitalWrite(relayPin1, state);
        digitalWrite(relayPin2, state);
        Serial.print("Received state: ");
        Serial.println(state);
        server.send(200, "text/plain",
                    state == HIGH ? "Relay is ON" : "Relay is OFF");
    } else {
        server.send(400, "text/plain", "Bad Request");
    }
}

// 計算15提醒時間
void addMinutes(int hour, int minute, int add) {
    minute += add;         // 加上15分钟
    if (minute >= 60) {    // 检查分钟是否需要进位
        minute -= 60;      // 从分钟中减去60
        hour += 1;         // 小时加1
        if (hour >= 24) {  // 检查小时是否需要回绕
            hour -= 24;    // 小时回绕至0
        }
    }
    if (add == 1) {
        notify15_hour = hour;
        notify15_minute = minute;
    } else if (add == 2) {
        notify30_hour = hour;
        notify30_minute = minute;
    }
}

// 提示音旋律
void song() {
    int duration = 500;
    int aSo = 392;
    int bDo = 523;
    int bRe = 587;
    int bMi = 659;
    int bFa = 698;
    int bSo = 784;
    int bLa = 880;
    int bSi = 988;
    int bDDo = 1047;
    tone(beePin, bDo, duration);
    delay(600);
    tone(beePin, bRe, duration);
    delay(600);
    tone(beePin, bMi, duration);
    delay(600);
    tone(beePin, bDo, duration);
    delay(800);

    tone(beePin, bDo, duration);
    delay(600);
    tone(beePin, bRe, duration);
    delay(600);
    tone(beePin, bMi, duration);
    delay(600);
    tone(beePin, bDo, duration);
    delay(800);

    tone(beePin, bMi, duration);
    delay(600);
    tone(beePin, bFa, duration);
    delay(600);
    tone(beePin, bSo, duration);
    delay(800);

    tone(beePin, bMi, duration);
    delay(600);
    tone(beePin, bFa, duration);
    delay(600);
    tone(beePin, bSo, duration);
    delay(800);

    tone(beePin, bSo, duration);
    delay(600);
    tone(beePin, bLa, duration);
    delay(600);
    tone(beePin, bSo, duration);
    delay(600);
    tone(beePin, bFa, duration);
    delay(600);
    tone(beePin, bMi, duration);
    delay(700);
    tone(beePin, bDo, duration);
    delay(800);

    tone(beePin, bSo, duration);
    delay(600);
    tone(beePin, bLa, duration);
    delay(600);
    tone(beePin, bSo, duration);
    delay(600);
    tone(beePin, bFa, duration);
    delay(600);
    tone(beePin, bMi, duration);
    delay(700);
    tone(beePin, bDo, duration);
    delay(800);

    tone(beePin, bDo, duration);
    delay(700);
    tone(beePin, aSo, duration);
    delay(700);
    tone(beePin, bDo, duration);
    delay(800);

    tone(beePin, bDo, duration);
    delay(700);
    tone(beePin, aSo, duration);
    delay(700);
    tone(beePin, bDo, duration);
    delay(800);
}

void sendLineNotify(String message) {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Reconnecting to WiFi...");
        WiFi.disconnect();
        WiFi.reconnect();
        delay(5000);  // 等待5秒以便WiFi重新连接
    }

    HTTPClient http;
    http.begin("https://notify-api.line.me/api/notify");
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");
    http.addHeader("Authorization", "Bearer " + String(lineToken));

    String httpRequestData = "message=" + message;
    int httpResponseCode = http.POST(httpRequestData);

    if (httpResponseCode > 0) {
        String response = http.getString();
        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);
        Serial.println(response);
    } else {
        Serial.print("Error on sending POST: ");
        Serial.println(httpResponseCode);
    }
    http.end();
    delay(1000);  // 在发送下一条消息前等待1秒
}

void createRecord(int hour, int minute, int state) {
    if (Firebase.ready()) {
        // String documentId =
        //     String(year()) + "-" + String(month()) + "-" +
        //     String(day());
        // String documentPath = "/record/2024-06-14";
        String documentPath = "record/2024-06-14";

        // 创建文档的JSON内容
        FirebaseJson json;
        json.set("fields/breakfast_hour/integerValue", hour);
        json.set("fields/breakfast_minute/integerValue", minute);
        json.set("fields/breakfast_state/integerValue", state);

        // 创建文档
        if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "",
                                              documentPath, json.raw())) {
            Serial.println("Created Firestore document successfully");
        } else {
            Serial.println("Failed to create Firestore document");
            Serial.println(fbdo.errorReason());
        }
    }
}

void updateRecord(int hour, int minute, int state) {
    if (Firebase.ready()) {
        // 定义Firestore文档路径
        String documentPath = "record/2024-06-14";

        // 读取数据
        if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "",
                                           documentPath.c_str())) {
            // 打印原始JSON字符串
            String jsonStr = fbdo.payload();
            // Serial.println("Raw JSON:");
            // Serial.println(jsonStr);

            // 使用ArduinoJson库解析JSON字符串
            StaticJsonDocument<512> doc;
            DeserializationError error = deserializeJson(doc, jsonStr);

            // 尝试获取字段
            const char* old_hour =
                doc["fields"]["breakfast_hour"]["integerValue"];
            const char* old_minute =
                doc["fields"]["breakfast_minute"]["integerValue"];
            const char* old_state =
                doc["fields"]["breakfast_state"]["integerValue"];

            Serial.print("get document: ");
            Serial.println(old_hour);
            Serial.println(old_minute);
            Serial.println(old_state);

            FirebaseJson json;
            json.set("fields/breakfast_hour/integerValue", atoi(old_hour));
            json.set("fields/breakfast_minute/integerValue", atoi(old_minute));
            json.set("fields/breakfast_state/integerValue", atoi(old_state));
            json.set("fields/dinner_hour/integerValue", hour);
            json.set("fields/dinner_minute/integerValue", minute);
            json.set("fields/dinner_state/integerValue", state);
            if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "",
                                                 documentPath, json.raw(),
                                                 "")) {
                Serial.println("Updated Firestore document successfully");
            } else {
                Serial.println("Failed to update Firestore document");
                Serial.println(fbdo.errorReason());
            }
        } else {
            Serial.println("Failed to get document:");
            Serial.println(fbdo.errorReason());
        }
    }
}

void checkWiFiConnection() {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("WiFi disconnected. Attempting to reconnect...");
        WiFi.reconnect();
        int retryCount = 0;
        while (WiFi.status() != WL_CONNECTED &&
               retryCount < 20) {  // 尝试重新连接，最多重试20次
            delay(500);
            Serial.print(".");
            retryCount++;
        }
        if (WiFi.status() == WL_CONNECTED) {
            Serial.println("\nWiFi reconnected.");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
        } else {
            Serial.println("\nFailed to reconnect WiFi.");
        }
    }
}

void checkFirebaseConnection() {
    if (!Firebase.ready()) {
        Serial.println("Firebase not connected. Attempting to reconnect...");
        Firebase.reconnectWiFi(true);
        Firebase.begin(&config, &auth);  // 重新初始化Firebase连接

        if (Firebase.ready()) {
            Serial.println("Firebase reconnected.");
        } else {
            Serial.println("Failed to reconnect Firebase.");
        }
    }
}

void loop() {
    checkWiFiConnection();
    checkFirebaseConnection();
    Serial.print("box1: ");
    Serial.println(box1);
    Serial.print("box2: ");
    Serial.println(box2);
    // 讀取firebase
    if (Firebase.ready()) {
        // 定义Firestore文档路径
        String documentPath = "/date_and_time_settings/2024-06-14";

        // 读取数据
        if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "",
                                           documentPath.c_str())) {
            // 打印原始JSON字符串
            String jsonStr = fbdo.payload();
            // Serial.println("Raw JSON:");
            // Serial.println(jsonStr);

            // 使用ArduinoJson库解析JSON字符串
            StaticJsonDocument<512> doc;
            DeserializationError error = deserializeJson(doc, jsonStr);

            // 尝试获取字段
            breakfast_hour = doc["fields"]["breakfast_hour"]["arrayValue"]
                                ["values"][0]["integerValue"];
            breakfast_minute = doc["fields"]["breakfast_minute"]["arrayValue"]
                                  ["values"][0]["integerValue"];
            dinner_hour = doc["fields"]["dinner_hour"]["arrayValue"]["values"]
                             [0]["integerValue"];
            dinner_minute = doc["fields"]["dinner_minute"]["arrayValue"]
                               ["values"][0]["integerValue"];
        } else {
            Serial.println("Failed to get document:");
            Serial.println(fbdo.errorReason());
        }
    }

    // 讀取磁簧開關
    int switchState1 = digitalRead(switchPin1);
    int switchState2 = digitalRead(switchPin2);
    if (switchState1 == HIGH) {
        Serial.println("switch1 open");
    }
    if (switchState2 == HIGH) {
        Serial.println("switch2 open");
    }

    server.handleClient();
    ntpClient.update();
    setTime(ntpClient.getEpochTime());

    if (box1 == 1) {
        if (switchState1 == HIGH) {
            delay(500);
            digitalWrite(relayPin1, LOW);
            Serial.println("pin1 turn off");
            // 發送吃藥紀錄
            box1 = 0;
            createRecord(hour(), minute(), has_30minute);
            has_30minute = 0;
            has_15minute = 0;
            has_notify = 0;
            delay(45000);
        } else if (hour() == notify15_hour && minute() == notify15_minute) {
            has_15minute = 1;
            has_notify = 0;
        } else if (hour() == notify30_hour && minute() == notify30_minute) {
            has_15minute = 0;
            has_30minute = 1;
            Serial.println("30 minute");
            if (has_notify30 == 0) {
                sendLineNotify("請記得吃藥");
                has_notify30 = 1;
            }
        }
        if (has_15minute) {
            Serial.println("15 minute");
            song();
        }
    } else if (box2 == 1) {
        if (switchState2 == HIGH) {
            delay(500);
            digitalWrite(relayPin2, LOW);
            Serial.println("pin2 turn off");
            // 發送吃藥紀錄
            updateRecord(hour(), minute(), has_30minute);
            box2 = 0;
            has_30minute = 0;
            has_15minute = 0;
            has_notify = 0;
            delay(45000);
        } else if (hour() == notify15_hour && minute() == notify15_minute) {
            has_15minute = 1;
            has_notify = 0;
        } else if (hour() == notify30_hour && minute() == notify30_minute) {
            has_15minute = 0;
            has_30minute = 1;
            Serial.println("30 minute");
            if (has_notify30 == 0) {
                sendLineNotify("請記得吃藥");
                has_notify30 = 1;
            }
        }
        if (has_15minute) {
            Serial.println("15 minute");
            song();
        }
    }
    if (has_notify == 0) {
        // 使用TimeLib來獲取當前日期和時間
        if (breakfast_hour && breakfast_minute) {
            if (hour() == atoi(breakfast_hour) &&
                minute() == atoi(breakfast_minute)) {
                if (box2 == 1) {
                    box2 = 0;
                    digitalWrite(relayPin2, LOW);
                    Serial.println("pin2 turn off");
                    updateRecord(hour(), minute(), 2);
                }
                has_15minute = 0;
                has_30minute = 0;
                has_notify30 = 0;
                addMinutes(hour(), minute(), 1);
                addMinutes(hour(), minute(), 2);
                Serial.println("breakfast time out");
                digitalWrite(relayPin1, HIGH);
                Serial.println("pin1 turn on");
                box1 = 1;
                sendLineNotify("該吃藥囉");
                has_notify = 1;
                song();
            }
        }
        if (dinner_hour && dinner_minute) {
            if (hour() == atoi(dinner_hour) &&
                minute() == atoi(dinner_minute)) {
                if (box1 == 1) {
                    box1 = 0;
                    digitalWrite(relayPin1, LOW);
                    Serial.println("pin1 turn off");
                    createRecord(hour(), minute(), 2);
                }
                has_15minute = 0;
                has_30minute = 0;
                has_notify30 = 0;
                addMinutes(hour(), minute(), 1);
                addMinutes(hour(), minute(), 2);
                Serial.println("dinner time out");
                digitalWrite(relayPin2, HIGH);
                Serial.println("pin2 turn on");
                box2 = 1;
                sendLineNotify("該吃藥囉");
                has_notify = 1;
                song();
            }
        }
    }
    delay(1000);
}
