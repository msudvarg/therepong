//Initialize Variables
 
import processing.serial.*; //Import serial port libraries for Processing 
Serial myPort; //Initialize variable myPort of type Serial

//Initialize float values for ball speed in two axes
float xSpeed;
float ySpeed;

//Initialize integer values for ball position in two axes
int ballX;
int ballY;

float xRat; //Creates a value for a ratio of xSpeed to ySpeed

//A function to reset the ball after a player scores
void ballInit() {
  //Speed in both axes is randomly assigned to be positive or negative so the
  //ball starts moving in a random direction
  ySpeed = round(random(0,1));
  if (ySpeed==0) { ySpeed = -1; }
  xSpeed = round(random(0,1));
  if (xSpeed==0) { xSpeed = -1; }
  xRat = random(0,1)*2;
  
  //Defines initial ball position
  ballX = 100;
  ballY = 300;
  
  //Defines initial scores
  int player1Score = 0;
  int player2Score = 0;
}
 
void setup () {
  //Set window size and drawing mode
  size(200, 600);   
  ellipseMode(CENTER);
  rectMode(CENTER);
  colorMode(HSB,360,100,100);
   
  //Lists available serial ports. This is commented out for actual use, but
  //when first running the game, we may need this to change the port we are
  //reading
  //println(Serial.list());
  //Typically the first serial port will be the Arduino, so we open
  //Serial.list()[0].
  //Change to Serial.list()[i] where i is the Arduino port if necessary
  myPort = new Serial(this, Serial.list()[0], 9600);
  
  //Buffer serial input to newline, then run serialEvent
  myPort.bufferUntil('\n');
  
  //Set initial background to white and initialize ball
  background(0,0,100);   
  ballInit();
}

void draw () {
//Everything happens in the serialEvent()
}
 
 
void serialEvent (Serial myPort) {
  // Get a single line as and ASCII string from serial input
  String inString = myPort.readStringUntil('\n');
   
  if (inString != null) {
    //Trim off any whitespace and split CSV
    inString = trim(inString);
    String[] inStringSplit = split(inString,',');
    
    //Convert first 2 values to integers and map the typical range of values
    //for each Theremin output to the screen width. Note that we use xcoord
    //and ycoord for the x-axis position of the two different paddles. When
    //we initially worked with having each Theremin plate control a different
    //axis, we defined these variables as xcoord and ycoord. When we switched
    //to control of two paddles moving on the same axis, we kept the same
    //variable names
    float xcoord = float(inStringSplit[0]);
    xcoord = map(xcoord, 250, 450, 0, 200);
    float ycoord = float(inStringSplit[1]);
    ycoord = map(ycoord, 250, 370, 0, 200);
    //Convert third value to an integer. If this is a 1 the game is reset
    //(code for this farther down)
    float tracer = float(inStringSplit[2]);
    //We convert the fourth value to a float value and use this to determine
    //game color
    float hueval = float(inStringSplit[3]);
    hueval = map(hueval, 0, 1023, 0, 360);
    //We convert the fifth value to a float value and map it to ball speed,
    //from 2 to 20
    float speedval = float(inStringSplit[4]);
    speedval = map(speedval, 0, 1023, 2, 20);
    
    //Brightness is set at 100
    float brightval = 100;
    
    //Speeds are now set as speedval (set by serial input) with initial
    //direction maintained. xRat is used to scale xSpeed
    //to a ratio of ySpeed so our ball is not always traveling at a 45 degree
    //angle
    ySpeed = int(speedval) * ySpeed/abs(ySpeed);
    xSpeed = int(speedval) * xSpeed/abs(xSpeed) * xRat;
    
    //If the ball strikes the left or right edge of the screen, it bounces
    //off
    if (ballX<=(0+abs(xSpeed)/2)) {xSpeed = -xSpeed;}
    if (ballX>=(200-abs(xSpeed)/2) ) {xSpeed = -xSpeed;}
    
    //If the ball strikes either paddle, it bounces off. We have a 2 pixel
    //buffer on each side of the paddles
    if ( ballY<=(500+abs(ySpeed)/2) && ballY>(500-abs(ySpeed)/2) && (abs(ballX - ycoord) <= 27) ) {ySpeed = -ySpeed;}
    if ( ballY<=(100+abs(ySpeed)/2) && ballY>(100-abs(ySpeed)/2) && (abs(ballX - xcoord) <= 27) ) {ySpeed = -ySpeed;}
    
    //If the ball goes past the top or bottom edge of the screen, a player
    //scores and the ball is reset
    if ( ballY>=0 && ballY<abs(ySpeed) ) { player1Score++; ballInit(); }
    if ( ballY<=600 && ballY>abs(600-ySpeed) ) { player2Score++; ballInit(); }
    
    //Clear drawing to allow for new positions to be drawn
    background(0,0,100);
      
    //Code to reset the game
    if(tracer == 1) {
      player1Score = 0;
      player2Score = 0; 
      ballInit();
    }
       
      //Draw game on canvas
      
      //Colors are set based on hueval
      fill(hueval,100,brightval);
      stroke(hueval,100,brightval);
      
      //Draw paddles based on input from Theremin plates. Paddles get thicker
      //with higher ball speed
      rect(xcoord,100,50,abs(ySpeed));
      rect(ycoord,500,50,abs(ySpeed));
      
      ellipse(ballX,ballY,6,6); //Draw the ball
      
      //Draw the scores
      String p1 = "Player 1 Score: " + player2Score;
      String p2 = "Player 2 Score: " + player1Score;
      text(p1,5,20);
      text(p2,5,580);
      
      //Increment ball position based on speed
      ballX += xSpeed;
      ballY += ySpeed;
   
  }
}

