#include <AccelStepper.h>

// steps per rotation = 200 for all steppers

// Constants
// Arduino connections
const int STEPPER0_STEP = 22;
const int STEPPER0_DIR = 23;
const int FAN0 = 6;

// Buttons
const int STEPPER0_EXTENDED = 28;

struct Instrument {
  int extendedButton;
  AccelStepper *stepper;
  int speed;
  int dir;
  int moveTo;
  bool stepperCtlChanged;
  int fanPort;
};

AccelStepper stepper0(1, STEPPER0_STEP, STEPPER0_DIR);  //args: MotorInterfaceType:"1=Driver", step, dir
struct Instrument instr0 = { STEPPER0_EXTENDED, &stepper0, 1000, -1, 0, false, FAN0};

// Function declarations
void moveStepper(struct Instrument *instr);
void mapInput(int ctlAndId, int value);
void calibrateMotorPos(struct Instrument *instr);

// Global variables
bool calibrateMotorPos_bool = true;

void setup() {
  Serial.begin(115200);
  pinMode(instr0.extendedButton, INPUT);
  instr0.stepper->setMaxSpeed(1000);
  for(int i = 6; i <= 13; i++) {  // Temporary until all instruments are built
    pinMode(i, OUTPUT);
  }
}

void loop() {
  bool test = false;
  if (calibrateMotorPos_bool) {
    calibrateMotorPos(&instr0);
    test = true;
  }
  
  while (Serial.available() > 0) {     // get serial input (from SuperCollider)
    int ctlAndId = Serial.parseInt();  // look for the next valid integer in the incoming serial stream
    int value = Serial.parseInt();     // do it again, now the value

    if (Serial.read() == '\n') {              // newline: the end of the sentence
      ctlAndId = constrain(ctlAndId, 0, 27);  // constrain the values
      value = constrain(value, 0, 255);
    }

    mapInput(ctlAndId, value);
  }

  if (test) { // for simulating one serial input
    mapInput(0, 100);    
    test = false;    
  }

  if (instr0.moveTo != instr0.stepper->currentPosition() ) moveStepper(&instr0); 
  // TODO: lägg till övriga instrument
}

void mapInput(int ctlAndId, int value) {
  switch(ctlAndId) {
    case 0:
      instr0.moveTo = map(value, 0, 255, 0, 3300);
      instr0.stepperCtlChanged = true;
      break;
    case 10:
      instr0.speed = map(value, 0, 255, 0, 1000);
      instr0.stepperCtlChanged = true;
      break;
    case 20:
      analogWrite(instr0.fanPort, value ); // map not needed here
      break;
    case 9:
      calibrateMotorPos_bool = true; // re-calibrate motor pos
      break;
  }
  // TODO: implementera för alla instrument
}

void moveStepper(struct Instrument *instr) {
  if (instr->stepperCtlChanged) {
    if (instr->moveTo > instr->stepper->currentPosition())
      instr->dir = 1;
    else
      instr->dir = -1;
      
    instr->stepper->moveTo(instr->moveTo);
    instr->stepper->setSpeed(instr->dir * instr->speed);
    instr->stepperCtlChanged = false;
  }
  
  instr->stepper->runSpeed();
}

void calibrateMotorPos(struct Instrument *instr) {
  instr->stepper->moveTo(0);
  instr->stepper->setSpeed(-instr->speed);

  while (calibrateMotorPos_bool) {
    bool extended_state = digitalRead(instr->extendedButton);

    if (extended_state) {
      instr->stepper->setCurrentPosition(0);
      //instr->dir = 1;
      calibrateMotorPos_bool = false;
      break;
    }

    instr->stepper->runSpeed();
  }
  delay(2000);
}