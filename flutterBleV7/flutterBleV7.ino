/*
  HC05 - Bluetooth AT-Command mode
  modified on 10 Feb 2019
  by Saeed Hosseini
  https://electropeak.com/learn/
*/
#include <SoftwareSerial.h>
#include <WiFiNINA.h> // Wi-Fi connection
#include <ArduinoMqttClient.h>  // MQTT

#include "arduino_secrets.h"
#include "DHT.h"
#define DHTPIN 8     // Digital pin connected to the DHT sensor
// Feather HUZZAH ESP8266 note: use pins 3, 4, 5, 12, 13 or 14 --
// Pin 15 can work but DHT must be disconnected during program upload.

// Uncomment whatever type you're using!
#define DHTTYPE DHT11


DHT dht(DHTPIN, DHTTYPE);



SoftwareSerial MyBlue(2, 3); // RX | TX
bool flag = false;
char Incoming_value = 0;
int LED = 13;

char msgCharArray[10];
int msgInCounter = 0;
bool msgInDoneFlag = false;


// 1 - Lavender | 2 - tea tree | 3 - sweet orange
int S1_PIN = 7;
int S2_PIN = 6;
int S3_PIN = 5;
int sendMsgCounter = 0;

int spCounter = 0; // switch pwm counter
int spSet1 = 100; // switch pwm set value (0-100) || default 100 (Always on)
int spSet2 = 100;
int spSet3 = 100;

bool s1_major_flag = false;
bool s2_major_flag = false;
bool s3_major_flag = false;
bool s1_minor_flag = true;
bool s2_minor_flag = true;
bool s3_minor_flag = true;



bool isS1On = false;
bool isS2On = false;
bool isS3On = false;

unsigned int modeIndex = 0;

float h = 0;
float t = 0;



char mqttCharArray[10];
int mqttInCounter = 0;
bool mqttInDoneFlag = false;


String s1_status = "0000";
String s2_status = "0000";
String s3_status = "0000";
// ------------------ Wi-Fi and MQTT connection ----------------------------------------------------
char ssid[] = SECRET_SSID;        // your network SSID
char pass[] = SECRET_PASS;    // your network password
const char* mqttuser = SECRET_MQTTUSER;
const char* mqttpass = SECRET_MQTTPASS;

int keyIndex = 0;                 // your network key Index number (needed only for WEP)
int status = WL_IDLE_STATUS;      //connection status

WiFiClient wifiClient;
MqttClient mqttClient(wifiClient);


const char broker[] = "mqtt.cetools.org";
int        port     = 1884;
const char topic1_temperature[]  = "student/CASA0021/project/ucfnmz0/temperature";
const char topic1_receive[]  = "student/CASA0021/project/ucfnmz0/receive";
const char topic2_humidity[]  = "student/CASA0021/project/ucfnmz0/humidity";
const char topic3_s1_status[]  = "student/CASA0021/project/ucfnmz0/s1";
const char topic4_s2_status[]  = "student/CASA0021/project/ucfnmz0/s2";
const char topic5_s3_status[]  = "student/CASA0021/project/ucfnmz0/s3";
//const char topic6_sound[]  = "student/CASA0016/project/ucfnmz0/soundStatus";
//const char topic7_uv[]  = "student/CASA0016/project/ucfnmz0/uvValue";

// -------------------------------------------



void setup()
{
  Serial.begin(9600);
  MyBlue.begin(9600);
  pinMode(LED, OUTPUT);

  pinMode(S1_PIN, OUTPUT);
  pinMode(S2_PIN, OUTPUT);
  pinMode(S3_PIN, OUTPUT);
  digitalWrite(S1_PIN, LOW);
  digitalWrite(S2_PIN, LOW);
  digitalWrite(S3_PIN, LOW);

  Serial.println("Ready to connect\nDefualt password is 1234 or 000");
  Serial.println("Goodnight moon!");


  // ------------- WIFI & MQTT init --------------------


  // attempt to connect to Wifi network:
  Serial.print("Attempting to connect to SSID: ");
  Serial.println(ssid);

  //  lcd.clear();
  //  lcd.print("Connecting to:");
  //  lcd.setCursor(0,1);
  //  lcd.print(ssid);
  //  lcd.setCursor(0,0);
  //  setupPixelDisplay(2);
  while (WiFi.begin(ssid, pass) != WL_CONNECTED) {
    // failed, retry
    Serial.print(".");
    delay(5000);
  }

  Serial.println("You're connected to the network");
  Serial.println();

  //  lcd.clear();
  //  lcd.print("Wi-Fi Connected");
  //  lcd.setCursor(0,1);
  //  lcd.print("IP:");
  //  lcd.setCursor(3,1);
  //  lcd.print(WiFi.localIP());
  //  setupPixelDisplay(3);
  delay(1000);

  Serial.print("Attempting to connect to the MQTT broker: ");
  Serial.println(broker);

  //  lcd.clear();
  //  lcd.print("Connect to MQTT");
  //  setupPixelDisplay(4);
  mqttClient.setUsernamePassword(mqttuser, mqttpass);
  if (!mqttClient.connect(broker, port)) {
    Serial.print("MQTT connection failed! Error code = ");
    Serial.println(mqttClient.connectError());

    while (1);
  }

  Serial.println("You're connected to the MQTT broker!");
  Serial.println();

  // set the message receive callback
  mqttClient.onMessage(onMqttMessage);
  Serial.print("Subscribing to topic: ");
  Serial.println(topic1_receive);
  Serial.println();
  // subscribe to a topic
  mqttClient.subscribe(topic1_receive);
  //  lcd.setCursor(0,1);
  //  lcd.print("Successful");
  //  setupPixelDisplay(5);
  delay(1000);

  //  lcd.clear();
  //  lcd.print("Setup......");


  // ==================================================================
  dht.begin();
  manualSwitchOutcome();
  controlSwitch();
}


void loop() {

  mqttClient.poll();


  if (MyBlue.available()) {

    char tempChar = MyBlue.read();
    if (tempChar == '\r') {
      Serial.println("[r]received");
    }
    else if (tempChar == '\n') {
      Serial.println("Incomming msg received DONE");
      msgInDoneFlag = true;
    }
    else {
      msgCharArray[msgInCounter] = tempChar;
      msgInCounter++;
    }
  }

  if (msgInDoneFlag) {
    Serial.print("msgCounter: ");
    Serial.println(msgInCounter);
    Serial.println("-----------------------");

    for (int i = 0; i < msgInCounter; i++) {
      Serial.print(msgCharArray[i]);
    }
    Serial.print("\n");

    if (msgCharArray[0] == '%') {
      switch (msgCharArray[1]) {
        case 'A':
          modeIndex = 0;
          break;
        case 'M':
          modeIndex = 1;
          break;
        case 'S':
          modeIndex = 2;
          break;
        default:
          break;
      }
    }




    if (msgCharArray[0] == '#') {
      if (msgCharArray[3] == 'e') {
        switch (msgCharArray[2]) {
          case '1':
            s1_major_flag = true;
            break;
          case '2':
            s2_major_flag = true;
            break;
          case '3':
            s3_major_flag = true;
            break;
          default:
            break;
        }
      }

      else if (msgCharArray[3] == 'd') {
        switch (msgCharArray[2]) {
          case '1':
            s1_major_flag = false;
            break;
          case '2':
            s2_major_flag = false;
            break;
          case '3':
            s3_major_flag = false;
            break;
          default:
            break;
        }
      }

      else if (msgCharArray[3] == 'v') {
        switch (msgCharArray[2]) {
          case '1':
            if (msgCharArray[4] != '1') {
              spSet1 = (int) msgCharArray[4] - 48;
              spSet1 = spSet1 * 10;
            }
            else if (msgCharArray[4] == '1' && msgCharArray[6] == '.') {
              spSet1 = 10;
            }
            else if (msgCharArray[4] == '1' && msgCharArray[6] == '0') {
              spSet1 = 100;
            }

            break;
          case '2':
            if (msgCharArray[4] != '1') {
              spSet2 = (int) msgCharArray[4] - 48;
              spSet2 = spSet2 * 10;
            }
            else if (msgCharArray[4] == '1' && msgCharArray[6] == '.') {
              spSet2 = 10;
            }
            else if (msgCharArray[4] == '1' && msgCharArray[6] == '0') {
              spSet2 = 100;
            }

            break;
          case '3':
            if (msgCharArray[4] != '1') {
              spSet3 = (int) msgCharArray[4] - 48;
              spSet3 = spSet3 * 10;
            }
            else if (msgCharArray[4] == '1' && msgCharArray[6] == '.') {
              spSet3 = 10;
            }
            else if (msgCharArray[4] == '1' && msgCharArray[6] == '0') {
              spSet3 = 100;
            }
            break;
          default:
            break;

        }

        Serial.print("spSet Update: set1 = ");
        Serial.print(spSet1);
        Serial.print("\tset2 = ");
        Serial.print(spSet2);
        Serial.print("\tset3 = ");
        Serial.println(spSet3);

      }

      spCounter = 0;
      s1_minor_flag = true;
      s2_minor_flag = true;
      s3_minor_flag = true;
    }



    msgInCounter = 0;
    msgInDoneFlag = false;


  }

  //  DHT======================================================

  if (sendMsgCounter > 20) {
    h = dht.readHumidity();
    t = dht.readTemperature();
    Serial.print(F("Humidity: "));
    Serial.print(h);
    Serial.print(F("%  Temperature: "));
    Serial.print(t);

    sendFloatMsg(h, 'h');
    delay(200);
    sendFloatMsg(t, 't');
    sendMsgCounter = 0;
    sendMQTT();
  }
  else {
    sendMsgCounter++;
  }

  // ==========


  switch (modeIndex) {
    case 0:

      // 1 - Lavender | 2 - tea tree | 3 - sweet orange
      if (h >= 15) {
        if (t >= 25) {
          isS1On = false;
          isS2On = true;
          isS3On = false;
        }
        else if (t >= 15 && t < 25) {
          isS1On = true;
          isS2On = false;
          isS3On = false;
        }
        else {
          isS1On = false;
          isS2On = false;
          isS3On = true;
        }
      }
      else {
        if (t >= 25) {
          isS1On = true;
          isS2On = true;
          isS3On = false;
        }
        else if (t >= 15 && t < 25) {
          isS1On = true;
          isS2On = false;
          isS3On = false;
        }
        else {
          isS1On = true;
          isS2On = false;
          isS3On = true;
        }
      }


      break;

    case 1:
      if (spCounter <= 100) {
        if (spCounter >= spSet1) {
          s1_minor_flag = false;
        }
        if (spCounter >= spSet2) {
          s2_minor_flag = false;
        }
        if (spCounter >= spSet3) {
          s3_minor_flag = false;
        }
        spCounter++;

      }

      else {
        spCounter = 0;
        s1_minor_flag = true;
        s2_minor_flag = true;
        s3_minor_flag = true;

      }
      manualSwitchOutcome();
      break;

    case 2:
      if (mqttInDoneFlag) {

        if (mqttCharArray[0] == '#') {
          if (mqttCharArray[3] == 'e') {
            switch (mqttCharArray[2]) {
              case '1':
                isS1On = true;
                break;
              case '2':
                isS2On = true;
                break;
              case '3':
                isS3On = true;
                break;
              default:
                break;
            }
          }

          else if (mqttCharArray[3] == 'd') {
            switch (mqttCharArray[2]) {
              case '1':
                isS1On = false;
                break;
              case '2':
                isS2On = false;
                break;
              case '3':
                isS3On = false;
                break;
              default:
                break;
            }
          }
        }
        mqttInDoneFlag = false;
      }

      break;

    default:
      break;
  }



  controlSwitch();

  //  receiveMQTT();
  delay(100);
}

//void checkSwitchStatus() {
//  if (s1_major_flag) {
//    if (s1_minor_flag) {
//      digitalWrite(S1_PIN, HIGH);
//    } else {
//      digitalWrite(S1_PIN, LOW);
//    }
//  } else {
//    digitalWrite(S1_PIN, LOW);
//  }
//
//  if (s2_major_flag) {
//    if (s2_minor_flag) {
//      digitalWrite(S2_PIN, HIGH);
//    } else {
//      digitalWrite(S2_PIN, LOW);
//    }
//  } else {
//    digitalWrite(S2_PIN, LOW);
//  }
//
//  if (s3_major_flag) {
//    if (s3_minor_flag) {
//      digitalWrite(S3_PIN, HIGH);
//    } else {
//      digitalWrite(S3_PIN, LOW);
//    }
//  } else {
//    digitalWrite(S3_PIN, LOW);
//  }
//
//}

void manualSwitchOutcome() {
  if (s1_major_flag) {
    if (s1_minor_flag) {
      isS1On = true;
    } else {
      isS1On = false;
    }
  } else {
    isS1On = false;
  }

  if (s2_major_flag) {
    if (s2_minor_flag) {
      isS2On = true;
    } else {
      isS2On = false;
    }
  } else {
    isS2On = false;
  }

  if (s3_major_flag) {
    if (s3_minor_flag) {
      isS3On = true;
    } else {
      isS3On = false;
    }
  } else {
    isS3On = false;
  }

}

void controlSwitch() {
  if (isS1On) {
    digitalWrite(S1_PIN, HIGH);
    s1_status = "#s1e";
  } else {
    digitalWrite(S1_PIN, LOW);
    s1_status = "#s1d";
  }

  if (isS2On) {
    digitalWrite(S2_PIN, HIGH);
    s2_status = "#s2e";
  } else {
    digitalWrite(S2_PIN, LOW);
    s2_status = "#s2d";
  }

  if (isS3On) {
    digitalWrite(S3_PIN, HIGH);
    s3_status = "#s3e";
  } else {
    digitalWrite(S3_PIN, LOW);
    s3_status = "#s3d";
  }
}

float createRandomFloat() {
  float tempDecimal = random(0, 99) / 100.0;
  int tempInt = random(0, 99);
  return tempInt + tempDecimal;
}


void sendFloatMsg(float inputFloat, char inputType) { // Used to serially push out a String with Serial.write()

  if (inputType == 't') {
    String tempString = 't' + String(inputFloat, 2);
    unsigned int tempLength = tempString.length();
    char tempStr[tempLength + 3];
    tempString.toCharArray(tempStr, tempLength + 1);
    //
    tempStr[tempLength + 1] = '\r';
    tempStr[tempLength + 2] = '\n';
    Serial.println(tempStr);
    MyBlue.write(tempStr, sizeof(tempStr));
  }

  else if (inputType == 'h') {
    String tempString = 'h' + String(inputFloat, 2);
    unsigned int tempLength = tempString.length();
    char tempStr[tempLength + 3];
    tempString.toCharArray(tempStr, tempLength + 1);
    //
    tempStr[tempLength + 1] = '\r';
    tempStr[tempLength + 2] = '\n';
    Serial.println(tempStr);
    MyBlue.write(tempStr, sizeof(tempStr));
  }


}




// ------------------------------------------------------------------------------------
//                                    send MQTT
// ------------------------------------------------------------------------------------
void sendMQTT() {



  // call poll() regularly to allow the library to send MQTT keep alive which
  // avoids being disconnected by the broker
  mqttClient.poll();

  if (mqttClient.connected()) {
    // send message, the Print interface can be used to set the message contents
    mqttClient.beginMessage(topic1_temperature);
    mqttClient.print(t);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic2_humidity);
    mqttClient.print(h);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic3_s1_status);
    mqttClient.print(s1_status);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic4_s2_status);
    mqttClient.print(s2_status);
    mqttClient.endMessage();

    mqttClient.beginMessage(topic5_s3_status);
    mqttClient.print(s3_status);
    mqttClient.endMessage();
    //
    //    mqttClient.beginMessage(topic6_sound);
    //    mqttClient.print(soundDetectorStatus);
    //    mqttClient.endMessage();
    //
    //    mqttClient.beginMessage(topic7_uv);
    //    mqttClient.print(uvValue);
    //    mqttClient.endMessage();

    Serial.println("Sending messages to MQTT done!");
    Serial.println();
    //    lcd.clear();
    //    lcd.print("To MQTT @");
    //    lcd.setCursor(10,0);
    //    lcd.print(GB.dateTime("H:i"));
    //    lcd.setCursor(0,1);
    //    lcd.print("CASA0016-Minghao");
    //    mqttUploadPixelDisplay();
  }

  else { // if the client has been disconnected,
    Serial.println("Client disconnected, attempting reconnection");
    Serial.println();
    //    lcd.clear();
    //    lcd.print("MQTT Send Error");
    //    lcd.setCursor(0,1);
    //    lcd.print("Reconnect..");

    if (!attemptReconnect()) { // try reconnecting
      Serial.print("Client reconnected!");
      Serial.println();
      //      lcd.setCursor(11,1);
      //      lcd.print("done");
    }

  }

}


void onMqttMessage(int messageSize) {
  // we received a message, print out the topic and contents
  Serial.println("Received a message with topic '");
  Serial.print(mqttClient.messageTopic());
  Serial.print("', length ");
  Serial.print(messageSize);
  Serial.println(" bytes:");
  //  memset(0, mqttCharArray, sizeof(mqttCharArray));
  mqttCharArray[0] = 0;
  mqttInCounter = 0;
  // use the Stream interface to print the contents
  while (mqttClient.available()) {
    char tempRead = (char)mqttClient.read();
    mqttCharArray[mqttInCounter] = tempRead;

    mqttInCounter++;
    Serial.print(tempRead);

  }
  Serial.println();

  Serial.println();

  mqttInDoneFlag = true;
}

//
//void receiveMQTT() {
//  int messageSize = mqttClient.parseMessage();
//  if (messageSize) {
//    // we received a message, print out the topic and contents
//    Serial.print("Received a message with topic '");
//    Serial.print(mqttClient.messageTopic());
//    Serial.print("', length ");
//    Serial.print(messageSize);
//    Serial.println(" bytes:");
//  }
//}


int attemptReconnect() {
  if (!mqttClient.connect(broker, port)) {
    Serial.print("MQTT connection failed! Error code = ");
    Serial.println(mqttClient.connectError());

  }
  return mqttClient.connectError(); // return status
}
