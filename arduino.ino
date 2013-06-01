//This allows the Arduino to read five inputs from our circuit and print their values to a serial line input to the computer.
//A Processing sketch then uses this information to control a ping pong game.

#include <math.h> //Include library of necessary math functions

//Define Arduino pins
int sensorPinY = A0; //A0 receives the output value from our second Theremin setup
int sensorPinX = A1; //A1 receives the output value from our first Theremin setup
int colorPin = A2; //A2 receives a voltage value from the potentiometer controlling color
int saturPin = A3; //A3 receives a voltage value from the potentiometer controlling speed.
                   //Note that initially this potentiometer controlled color saturation but
                   //when it became useful to make it control speed, we neglected to change
                   //variable name
int drawPin = 2; //Digital input 2 receives the output value from our two switches that reset the game

//Initialize string for the variable that passes information about whether or not to reset the game based on readout from digital input 2
String isDraw = "";

//Setup serial connection at 9600 baud
void setup()
{
  Serial.begin(9600);
}

void loop(){
  if (digitalRead(drawPin) == HIGH) {
    isDraw = String("1");
  }
  else {
    if (digitalRead(drawPin) == LOW) {
      isDraw = String("0");
    }
  }
  
  //Initialize positions of each paddle. As stated in the Processing sketch, we initially used each Theremin
  //setup to control position on two axes. When we changed to two paddles we did not change variable names
  long xcoord = analogRead(sensorPinX);
  long ycoord = analogRead(sensorPinY);
  
  //Print input values as a string of comma separated values
  Serial.println(xcoord + String(",") + ycoord + String(",") + isDraw + String(",") + analogRead(colorPin) + String(",") + analogRead(saturPin));
  
  //Delay loop so game runs in 100ms (0.1s) iterations
  delay(100);
}
  
