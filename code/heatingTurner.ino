#include <Wire.h>
#include <Adafruit_INA219.h>
#include "Adafruit_SHT31.h"
Adafruit_INA219 ina219;
#include <SDS011.h>

#define LCD_ADDRES 0x3C
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#define OLED_RESET D0

Adafruit_SHT31 sht31 = Adafruit_SHT31();
Adafruit_SHT31 sht31ambient = Adafruit_SHT31();
Adafruit_SSD1306 display(D0);

void setup(void) 
{
  Wire.begin(D1,D5);

  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3D (for the 128x64)
  display.clearDisplay();
  display.setTextColor(WHITE);
  display.setTextSize(1);
  display.setCursor(0,20);
  display.println("Initialising");
  //display.flip();
  display.display();
  
  Serial.begin(115200);
  while (!Serial) {
      // will pause Zero, Leonardo, etc until serial console opens
      delay(1);
  }

  if (! sht31.begin(0x44)) {   // Set to 0x45 for alternate i2c addr
    Serial.println("Couldn't find SHT31");
    while (1) delay(1);
  }
  if (! sht31ambient.begin(0x45)) {   // Set to 0x45 for alternate i2c addr
    Serial.println("Couldn't find SHT31 ambient");
    while (1) delay(1);
  }
 
  
  uint32_t currentFrequency;
    
  Serial.println("Hello!");
  
  // Initialize the INA219.
  // By default the initialization will use the largest range (32V, 2A).  However
  // you can call a setCalibration function to change this range (see comments).
  ina219.begin();
  // To use a slightly lower 32V, 1A range (higher precision on amps):
  ina219.setCalibration_32V_1A();
  // Or to use a lower 16V, 400mA range (higher precision on volts and amps):
  //ina219.setCalibration_16V_400mA();

  Serial.println("Measuring voltage and current with INA219 ...");
  pinMode(D6, OUTPUT);
  pinMode(D7, OUTPUT);

}

void measureEnvironment(){

  float tempHeat = sht31.readTemperature();
  float humHeat = sht31.readHumidity();
  float tempAmb = sht31ambient.readTemperature();
  float humAmb = sht31ambient.readHumidity();
  
  Serial.print("TEMPHEAT:");Serial.print(tempHeat);Serial.print(",HUMHEAT:");Serial.println(tempHeat);
  Serial.print("TEMPAMB:");Serial.print(tempAmb);Serial.print(",HUMAMB:");Serial.println(humAmb);

   display.clearDisplay();

  display.setTextSize(3);
  display.setCursor(0,0);
  display.print(tempAmb); display.setTextSize(2); display.print(" C"); display.setTextSize(3); display.println();
  display.print(tempHeat); display.setTextSize(2); display.print(" C"); display.setTextSize(3); display.println();

  display.display();
}

void loop(void) 
{
  float shuntvoltage = 0;
  float busvoltage = 0;
  float current_mA = 0;
  float loadvoltage = 0;
  float power_mW = 0;
  

  
  //Serial.println(current_mA); 

  if(Serial.available()){
     delay(3);
     //Example command: 1000,1,1000,5,500.0,2006
     int power = Serial.parseInt() ;
     int sign = Serial.parseInt() ; 
     int t = Serial.parseInt();
     int climitAmount = Serial.parseInt();
     float climit = Serial.parseFloat() ;
     int chk = Serial.parseInt();
     int chksum= power+sign+t+climitAmount;
     Serial.read();
     Serial.print("EXEC:");
     Serial.print(power);Serial.print(",");
     Serial.print(sign);Serial.print(",");
     Serial.print(t);Serial.print(",");
     Serial.print(climitAmount);Serial.print(",");
     Serial.print(climit);Serial.print(",");
     Serial.println(chk);
     

     if(chk!=chksum){
      Serial.print("ERROR: CHK:");Serial.print(chksum);Serial.print(" GOT:");Serial.println(chk);
      return;
     }
     if(sign==3){
      measureEnvironment();
      return;
     }else if(sign){
      analogWrite(D6, power);
      analogWrite(D7, 0);
     }else{
      analogWrite(D7, power);
      analogWrite(D6, 0);
     }

     float waited = 0;
     long prev=millis();
     int overlimit = 0; 
     while(waited<(float)t && !Serial.available()){
        delay(1);
        shuntvoltage = ina219.getShuntVoltage_mV();
        busvoltage = ina219.getBusVoltage_V();
        current_mA = ina219.getCurrent_mA();
        power_mW = ina219.getPower_mW();
        loadvoltage = busvoltage + (shuntvoltage / 1000);
        Serial.println(current_mA);
        if(current_mA>=abs(climit)){
          overlimit+=1;
        } else {
          overlimit=0;
        }
        if(overlimit>=climitAmount){
          Serial.println("Current limited");
          break;
        }
        waited+=(float)(millis()-prev);
        prev=millis();
     }
     if(Serial.available()){
      Serial.print("HALTED DUE TO NEW DATA IN");
     }
     analogWrite(D7, 0);
     analogWrite(D6, 0);
  } 

}
