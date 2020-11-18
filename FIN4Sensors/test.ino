#include "LiquidCrystal.h"
#include "ESP8266WiFi.h"
#include "ESP8266HTTPClient.h"


//Pins and LCD setup
LiquidCrystal lcd (12,11,5,4,3,2);
const int RED_PIN = 6; // number of the pin changing the Dflop state
int SENSOR_PIN = A0;   //don't really need it

//Compute variables
float average = 0 ;
boolean token = false;

//Network parameters
char ssid[] = ""; //SSID of your Wi-Fi router
char pass[]= "";
char accessToken[] = "";

void setup() {
  
  //Setup LED
  pinMode(RED_PIN, OUTPUT); // we set the green led pin as an output pin
  
  
  //Setup Serial
  Serial.begin(9600);

  //LCD setup
  lcd.begin(16,2) ;
  lcd.print("-----SaveMe-----");
  lcd.setCursor(0,1);
  lcd.print("Token for Health");

  //Setup Wifi Connection
  Serial.println("-----SaveMe-----");
  Serial.println(" A Token for Health");
  Serial.println();
  Serial.println();
  Serial.print("Connecting to...");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("Wi-Fi connected successfully");
  
 
}

void loop() {
int average = 0 ;
//Find average after 5 testings
for( int i=0 ; i<6 ; i++){
 delay(6000);
 //Serial.println(" On ");
 digitalWrite(RED_PIN , HIGH);
 //int sensor_value = analogRead(SENSOR_PIN) ;
 //float voltage = (sensor_value/1024.0)*5.0;
 //float celsius = (voltage - 0.5)*100;
 delay(2000);
 digitalWrite(RED_PIN, LOW);//do nothing 
 double measurement = (random(100,1500))/100; // the normal range is between 4-10.5
 Serial.println("The measurement taken at "+ String()+ " is " + String(measurement)); // Add some Internet time here
 lcd.setCursor(0,0);
 lcd.print("-----SaveMe-----");
 lcd.setCursor(0,1);
 lcd.print("Last:"+ String(measurement)+"           ");
 average = average+measurement;
}
lcd.clear();
float total_average = average/6;

//Decide if a token is awarded
if(total_average>10.5){token =false;}
else{ if(total_average<4.0){token=false;}
else{token=true;}}

//Print results to LCD screen and Serial
Serial.println("Glucose Level Avg 1 h is "+String(total_average));
lcd.print("Avg Gl is "+String(total_average));
lcd.setCursor(0,1); //Change line

if (token)
{
    lcd.print("Token Awarded"); 
    Serial.println("Token Awarded");
    verifyClaim();
}
else 
{
    lcd.print("No Token Awarded"); 
    Serial.println("No Token Awarded");
    rejectClaim();
}

  }


// Ping Server
void ping() {
  
  // Declare object of class HTTPClient
  HTTPClient http;

  // Specify Ping destination
  http.begin(pingAddress + String("?id=PlantWateringSensor&data=ThePlantSaysThanksForWatering"));

  // Specify Content type and authenticate as Oracle
  http.addHeader("Content-Type", "application/json");

  // Send Request and receive http Code
  int httpCode = http.POST(""); //String("{\"accessToken\": \"") + accessToken + String("\"}"));

  // Logging
  if (httpCode == 200) {
    Serial.println("\n Ping! ------ \n");
  } else {
    Serial.println("\n server not available \n");
  }
  
  // Close connection
  http.end();
}

// Send Verification of Claim to Server and award token
void verifyClaim() {

  // Declare object of class HTTPClient
  HTTPClient http;

  // Specify request destination
  http.begin(verificationAddress + String("?id=PlantWateringSensor&data=ThePlantSaysThanksForWatering"));

  // Specify content-type header and "log in" as Oracle
  http.addHeader("Content-Type", "application/json");

  // Actually send the request
  int httpCode = http.POST("");//String("{\"isAccepted\": true, \"accessToken\": \"") + accessToken + String("\"}"));

  // Get the response payload
  String payload = http.getString();

  // Logging
  Serial.print("httpCode = ");
  Serial.println(httpCode);
  Serial.print("payload is = ");
  Serial.println(payload);

  // Close connection
  http.end();
}



// Send Claim rejection to the server and remove 2 tokens
void rejectClaim() {

  // Declare object of class HTTPClient
  HTTPClient http;

  // Specify request destination
  http.begin(verificationAddress + String("?id=PlantWateringSensor&data=ThePlantSaysThanksForWatering"));

  // Specify content-type header and "log in" as Oracle
  http.addHeader("Content-Type", "application/json");

  // Actually send the request
  int httpCode = http.POST("");//String("{\"isAccepted\": false, \"accessToken\": \"") + accessToken + String("\"}"));

  // Get the response payload
  String payload = http.getString();

  // Logging
  Serial.print("httpCode = ");
  Serial.println(httpCode);
  Serial.print("payload is = ");
  Serial.println(payload);

  // Close connection
  http.end();
}
