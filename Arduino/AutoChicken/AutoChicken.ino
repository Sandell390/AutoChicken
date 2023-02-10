// TODO:
// Make general method for temperatur sensors
// Make general method for https request
// Check Heater is working
// Check pump activity when float switch is down (Time limit on pump)
// Split code in more files

#include <WiFiClientSecure.h>
#include <cJSON.h>

#include "arduino_secrets.h"

const int ARRAY_SIZE = 100;
const int WATERARRAY_SIZE = 20;

int BOWLTEMP_A_PIN = 34;
int WATERTANKTEMP_A_PIN = 35;
int WATERLEVEL_A_PIN = 33;

int HEATINGPLATE_D_PIN = 21;
int PUMP_D_PIN = 26;
int SWITCHFLOAT_D_PIN = 18;
int WATERLEVEL_D_PIN = 25;

bool TankHeater = false;
bool BowlHeater = false;

float TankTemps[ARRAY_SIZE];
float BowlTemps[ARRAY_SIZE];

float WaterLevels[WATERARRAY_SIZE];
float LastWaterLevels[WATERARRAY_SIZE];

byte tankTempIndex = 0;
byte BowlTempIndex = 0;
byte waterLevelIndex = 0;

bool tankTempError = false;
bool bowlTempError = false;
bool pump_watersensor_error = false;

bool pumpActive = false;
//bool floatSwitchActive = false;

char ssid[] = SECRET_SSID;        // your network SSID (name)
char pass[] = SECRET_OPTIONAL_PASS;    // your network password (use for WPA, or use as key for WEP)
int status = WL_IDLE_STATUS;  

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

WiFiClientSecure client;

int    HTTP_PORT   = 80;
String HTTP_METHOD = "POST";
char   HOST_NAME[] = "maker.ifttt.com";
String PATH_NAME   = "/trigger/test_changed/with/key/cBVIa6HjPNjoUHxpAr3qx9";
String queryString = "";

String HTTP_METHOD1 = "POST";
char   HOST_NAME1[] = "firestore.googleapis.com";
String PATH_NAME1   = "/v1beta1/projects/autochicken-552bf/databases/(default)/documents:commit";
String queryString1 = "";

void setup()
{
  // Initialize serial and wait for port to open:
  Serial.begin(9600);
  // This delay gives the chance to wait for a Serial Monitor without blocking if none is found
  ConnectToWIFI();
  delay(1500);
  client.setInsecure();//skip verification

  pinMode(BOWLTEMP_A_PIN, INPUT);
  pinMode(WATERTANKTEMP_A_PIN, INPUT);
  pinMode(WATERLEVEL_A_PIN, INPUT);

  pinMode(HEATINGPLATE_D_PIN, OUTPUT);
  pinMode(PUMP_D_PIN, OUTPUT);
  pinMode(SWITCHFLOAT_D_PIN, INPUT_PULLUP);
  pinMode(WATERLEVEL_D_PIN, OUTPUT);

  digitalWrite(PUMP_D_PIN, HIGH);


  CheckWarnings();

  delay(40000);
}

void loop()
{
  TankTemperatur();
  BowlTemperatur();
  WaterLevel();
  delay(100);
}

void TankTemperatur(){
  int tempRaw = analogRead(WATERTANKTEMP_A_PIN);
  float temp = mapfloat(tempRaw, 0.0, 4095.0, -10.0, 50.0);

  // Checks if there is an error on the tank temparetur sensor
  if (!tankTempError)
  {

    // Adds the temperatur to an array
    TankTemps[tankTempIndex] = temp;
    tankTempIndex++;

    //Checks if the array is as big as ARRAY_SIZE
    if (tankTempIndex == ARRAY_SIZE)
    {
      tankTempIndex = 0;

      // Analyse the Array
      bool isArrayOkay = AnalyseArray(TankTemps);
      if (!isArrayOkay)
      {
        // Sends Error to firebase
        Serial.println("ERROR to app TANK");
        FireStoreTest("WaterReservoirTempSensor","true","booleanValue", "Warnings");
        tankTempError = true;
      }
      else
      {
        // Sends averageTemp to firebase
        float averageTemp = FindAverage(TankTemps);
        FireStoreTest("WaterReservoirTempValue",String(averageTemp),"doubleValue", "WaterReservoir");
        Serial.println("Average Temp Tank: " + String(averageTemp));

        // Checks if the heatingplate is already on
        if (digitalRead(HEATINGPLATE_D_PIN) == HIGH)
        {
          if (averageTemp > 10)
          {
            Serial.println("Turn off tank heater");
            digitalWrite(HEATINGPLATE_D_PIN, LOW);
            FireStoreTest("WaterReservoirHeaterOn","false","booleanValue", "WaterReservoir");
          }
        }
        else
        {
          if (averageTemp < 5)
          {
            Serial.println("Turn on tank heater");
            digitalWrite(HEATINGPLATE_D_PIN, HIGH);
            FireStoreTest("WaterReservoirHeaterOn","true","booleanValue", "WaterReservoir");
          }
        }
      }

      // Fills the array with 0's
      for (int i = 0; i < ARRAY_SIZE; i++)
      {
        TankTemps[i] = 0;
      }
    }
  }
}

void BowlTemperatur(){
    // Bowl Temparetur

  int tempRaw1 = analogRead(BOWLTEMP_A_PIN);
  float temp1 = mapfloat(tempRaw1, 0.0, 4095.0, -10.0, 50.0);

  // Checks if there is an error on the bowl temparetur sensor
  if (!bowlTempError)
  {

    // Adds the temperatur to an array
    BowlTemps[BowlTempIndex] = temp1;
    BowlTempIndex++;

    //Checks if the array is as big as ARRAY_SIZE
    if (BowlTempIndex == ARRAY_SIZE)
    {
      BowlTempIndex = 0;

      // Analyse the Array
      bool isArrayOkay = AnalyseArray(BowlTemps);
      if (!isArrayOkay)
      {
        // Sends Error to firebase
        Serial.println("ERROR to app BOWL");
        FireStoreTest("WaterBowlTempSensor","true","booleanValue", "Warnings");
        bowlTempError = true;
      }
      else
      {
        // Sends averageTemp to firebase
        float averageTemp = FindAverage(BowlTemps);
        FireStoreTest("WaterBowlTempValue",String(averageTemp),"doubleValue", "WaterBowl");
        Serial.println("Average Temp Bowl: " + String(averageTemp));

        // Checks if the bowlHeater is already on
        if (BowlHeater)
        {
          if (averageTemp > 10)
          {
            Serial.println("Turn off Bowl heater");
            BowlHeater = false;
            TogglePowerSwitch();
            FireStoreTest("WaterBowlHeaterOn","false","booleanValue", "WaterBowl");
          }
        }
        else
        {
          if (averageTemp < 5)
          {
            Serial.println("Turn on Bowl heater");
            BowlHeater = true;
            TogglePowerSwitch();
            FireStoreTest("WaterBowlHeaterOn","true","booleanValue", "WaterBowl");
          }
        }
      }

      // Fills the array with 0's
      for (int i = 0; i < ARRAY_SIZE; i++)
      {
        BowlTemps[i] = 0;
      }
    }
  }
}

void WaterLevel(){
  // Water Level
  int waterLevelMapped = 100 - map(readSensor(), 1800, 4095, 0, 100);

  if (!pump_watersensor_error){

    WaterLevels[waterLevelIndex] = waterLevelMapped;
    waterLevelIndex++;

    if(waterLevelIndex == WATERARRAY_SIZE){

      waterLevelIndex = 0;
      float lastAverage = FindAverage(LastWaterLevels);
      float average = FindAverage(WaterLevels);
      Serial.println("Average WaterLevel: " + String(average));
      FireStoreTest("WaterBowlLevelValue",String(average),"doubleValue", "WaterBowl");
      if (pumpActive){
        if (average > lastAverage * 0.98 || average != lastAverage || lastAverage != 0){
          if(digitalRead(SWITCHFLOAT_D_PIN) == HIGH){
            // Send warning to app
            FireStoreTest("WaterReservoirMinimumLevel","true","booleanValue", "WaterReservoir");
            Serial.println("FloatSwitch ON");

            TogglePump(false);
            // Check if pump has been active in 30 sec

          }else{
            FireStoreTest("WaterReservoirMinimumLevel","false","booleanValue", "WaterReservoir");

            if(average > 90){
              //Turn off pump
              TogglePump(false);
            }

          }

        }else{
          // Send Pump/WaterLevel sensor Error
          //pump_watersensor_error = true;
          FireStoreTest("WaterPumpOrLevel","true","booleanValue", "Warnings");
          Serial.println("pump_watersensor_error ON");
          TogglePump(false);
        }
      }else{
        if(average < 10){
          // Turn on pump
          TogglePump(true);
        }
      }

      // Fills the array with 0's and save the value in another array
      for (int i = 0; i < WATERARRAY_SIZE; i++)
      {
        LastWaterLevels[i] = WaterLevels[i];
        WaterLevels[i] = 0;
      }
    }

  }

}


// Checks every value in the array if the value is 20% away. 
// if 20% of the array is 20% away then return as error.
// if 95% of the array is the same then return as error.
bool AnalyseArray(float array[])
{
  // Finds the average value in the array
  float averageValue = FindAverage(array);

  for (int i = 0; i < ARRAY_SIZE; i++)
  {
    int notAverageCount = 0;
    int count = 0;


    if (array[i] / averageValue < 0.8)
    {
      notAverageCount++;

      if(notAverageCount > ARRAY_SIZE/100 * 20){
      return false;        
      }
      
    }

    for (int j = 0; j < ARRAY_SIZE; j++)
    {
      if (array[i] == array[j])
      {
        count++;

        if (count > ARRAY_SIZE / 100 * 95)
        {
          return false;
        }
      }
    }
  }

  return true;
}

// Finds the average value in an float array
float FindAverage(float array[])
{
  float averageValue;
  for (int i = 0; i < sizeof(array) / sizeof(int); i++)
  {
    averageValue += array[i];
  }
  return averageValue / (sizeof(array) / sizeof(int));
}

void ConnectToWIFI(){
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(10000);
  }

  // you're connected now, so print out the data:
  Serial.print("You're connected to the network");
  printCurrentNet();
}

void printCurrentNet() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());
}

void TogglePowerSwitch(){
  if(client.connect(HOST_NAME, 443)) {
    // if connected:
    // make a HTTP request:
    // send HTTP header
    client.println(HTTP_METHOD + " " + PATH_NAME + " HTTP/1.1");
    client.println("Host: " + String(HOST_NAME));
    client.println("Connection: close");
    client.println(); // end HTTP header

    // send HTTP body
    client.println(queryString);

    while(client.connected()) {
      if(client.available()){
        // read an incoming byte from the server and print it to serial monitor:
        char c = client.read();
      }
    }
    // the server's disconnected, stop the client:
    client.stop();
  }
}

void FireStoreTest(String variable, String value, String type, String document){

  
  queryString1 = "{\"writes\":[{\"update\":{\"name\":\"projects/autochicken-552bf/databases/(default)/documents/AutoChicken/" + document +"\",\"fields\":{\""+ variable +"\":{\""+ type +"\": " +value+"}}},\"updateMask\":{\"fieldPaths\":[\""+ variable +"\"]}}]}";  

  const char* str = queryString1.c_str();

  if(client.connect(HOST_NAME1, 443)) {
    // if connected:
    // make a HTTP request:
    // send HTTP header
    client.println(HTTP_METHOD1 + " " + PATH_NAME1 + " HTTP/1.1");
    client.println("Host: " + String(HOST_NAME1));
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.println("Content-Length: " + String(strlen(str)));
    client.println("Connection: close");
    client.println(); // end HTTP header
    // send HTTP body
    client.println(queryString1);

    while(client.connected()) {
      if(client.available()){
        // read an incoming byte from the server and print it to serial monitor:
        char c = client.read();
      }
    }

    // the server's disconnected, stop the client:
    client.stop();;
  }
}

float mapfloat(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

String s;


void CheckWarnings(){

  if(client.connect(HOST_NAME1, 443)) {
    // if connected:
    // make a HTTP request:
    // send HTTP header
    client.println("GET /v1beta1/projects/autochicken-552bf/databases/(default)/documents/AutoChicken/Warnings HTTP/1.1");
    client.println("Host: " + String(HOST_NAME1));
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.println("Connection: close");
    client.println(); // end HTTP header
    while(client.connected()) {
      if(client.available()){
        // read an incoming byte from the server and print it to serial monitor:
        char c = client.read();
        s = client.readString();
      }
    }
    // the server's disconnected, stop the client:
    client.stop();

    const char* str = s.c_str();

    if (strlen(str) > 1){
      cJSON* json = cJSON_Parse(str);

      const cJSON *name = NULL;
      const cJSON *field = NULL;
      const cJSON *fields = NULL;
        
      name = cJSON_GetObjectItemCaseSensitive(json, "name");
      if (cJSON_IsString(name) && (name->valuestring != NULL))
      {
        Serial.print("Name: ");
        Serial.println(name->valuestring);
      }


    fields = cJSON_GetObjectItemCaseSensitive(json, "fields");
    cJSON_ArrayForEach(field, fields)
    {
      if (cJSON_IsString(field) && (field->valuestring != NULL))
      {
        Serial.print("Field: ");
        Serial.println(field->valuestring);
      }
    }

      cJSON_Delete(json);
    }

  }
}

// Reads the WaterLevel Sensor
int readSensor() {
    digitalWrite(WATERLEVEL_D_PIN, HIGH);    // Turn the sensor ON
    delay(10);                            // wait 10 milliseconds
    int val = analogRead(WATERLEVEL_A_PIN);        // Read the analog value form sensor
    digitalWrite(WATERLEVEL_D_PIN, LOW);        // Turn the sensor OFF
    return val;                            // send current reading
}

void TogglePump(bool state) {
  digitalWrite(PUMP_D_PIN, int(state));
  FireStoreTest("WaterReservoirPumpOn",String(state),"booleanValue", "WaterReservoir");
  Serial.println("Pump " + String(state));
  pumpActive = state;
  
}

