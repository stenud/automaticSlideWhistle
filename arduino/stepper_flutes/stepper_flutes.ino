#include <AccelStepper.h>

// steps per rotation = 200 for all steppers

// Constants
// Arduino connections
const int STEPPER0_STEP = 22;
const int STEPPER0_DIR = 23;
const int STEPPER1_STEP = 24;
const int STEPPER1_DIR = 25;
const int STEPPER2_STEP = 26;
const int STEPPER2_DIR = 27;
const int STEPPER3_STEP = 28;
const int STEPPER3_DIR = 29;
const int STEPPER4_STEP = 30;
const int STEPPER4_DIR = 31;
const int STEPPER5_STEP = 32;
const int STEPPER5_DIR = 33;
const int STEPPER6_STEP = 34;
const int STEPPER6_DIR = 35;
const int STEPPER7_STEP = 36;
const int STEPPER7_DIR = 37;
const int FAN0 = 6;
const int FAN1 = 7;
const int FAN2 = 8;
const int FAN3 = 9;
const int FAN4 = 10;
const int FAN5 = 11;
const int FAN6 = 12;
const int FAN7 = 13;

// Buttons
const int STEPPER0_EXTENDED = 38;
const int STEPPER1_EXTENDED = 39;
const int STEPPER2_EXTENDED = 40;
const int STEPPER3_EXTENDED = 41;
const int STEPPER4_EXTENDED = 42;
const int STEPPER5_EXTENDED = 43;
const int STEPPER6_EXTENDED = 44;
const int STEPPER7_EXTENDED = 45;

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
AccelStepper stepper1(1, STEPPER1_STEP, STEPPER1_DIR);
AccelStepper stepper2(1, STEPPER2_STEP, STEPPER2_DIR);
AccelStepper stepper3(1, STEPPER3_STEP, STEPPER3_DIR);
AccelStepper stepper4(1, STEPPER4_STEP, STEPPER4_DIR);
AccelStepper stepper5(1, STEPPER5_STEP, STEPPER5_DIR);
AccelStepper stepper6(1, STEPPER6_STEP, STEPPER6_DIR);
AccelStepper stepper7(1, STEPPER7_STEP, STEPPER7_DIR);
struct Instrument instr0 = { STEPPER0_EXTENDED, &stepper0, 1000, -1, 0, false, FAN0};
struct Instrument instr1 = { STEPPER1_EXTENDED, &stepper1, 1000, -1, 0, false, FAN1};
struct Instrument instr2 = { STEPPER2_EXTENDED, &stepper2, 1000, -1, 0, false, FAN2};
struct Instrument instr3 = { STEPPER3_EXTENDED, &stepper3, 1000, -1, 0, false, FAN3};
struct Instrument instr4 = { STEPPER4_EXTENDED, &stepper4, 1000, -1, 0, false, FAN4};
struct Instrument instr5 = { STEPPER5_EXTENDED, &stepper5, 1000, -1, 0, false, FAN5};
struct Instrument instr6 = { STEPPER6_EXTENDED, &stepper6, 1000, -1, 0, false, FAN6};
struct Instrument instr7 = { STEPPER7_EXTENDED, &stepper7, 1000, -1, 0, false, FAN7};

// Function declarations
void testFans(int value);
void moveStepper(struct Instrument *instr);
void mapInput(int ctlAndId, int value);
void calibrateMotorPos(struct Instrument *instr);

// Global variables
bool calibrateMotorPos_bool = true;
bool init_test = true;

void setup() {
  Serial.begin(115200);
  pinMode(instr0.extendedButton, INPUT_PULLUP);
  pinMode(instr1.extendedButton, INPUT_PULLUP);
  pinMode(instr2.extendedButton, INPUT_PULLUP);
  pinMode(instr3.extendedButton, INPUT_PULLUP);
  pinMode(instr4.extendedButton, INPUT_PULLUP);
  pinMode(instr5.extendedButton, INPUT_PULLUP);
  pinMode(instr6.extendedButton, INPUT_PULLUP);
  pinMode(instr7.extendedButton, INPUT_PULLUP);
  instr0.stepper->setMaxSpeed(1000);
  instr1.stepper->setMaxSpeed(1000);
  instr2.stepper->setMaxSpeed(1000);
  instr3.stepper->setMaxSpeed(1000);
  instr4.stepper->setMaxSpeed(1000);
  instr5.stepper->setMaxSpeed(1000);
  instr6.stepper->setMaxSpeed(1000);
  instr7.stepper->setMaxSpeed(1000);
  for(int i = 6; i <= 13; i++) {  // FAN0-7
    pinMode(i, OUTPUT);
  }
}

void loop() {
  bool test = false;
  if (calibrateMotorPos_bool) {
    calibrateMotorPos(&instr0);
    calibrateMotorPos(&instr1);
    calibrateMotorPos(&instr2);
    calibrateMotorPos(&instr3);
    calibrateMotorPos(&instr4);
    calibrateMotorPos(&instr5);
    calibrateMotorPos(&instr6);
    calibrateMotorPos(&instr7);
    test = init_test;
    init_test = false;
    calibrateMotorPos_bool = false;
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
    int testPos = 100;
    testFans(255);
    delay(5000);
    testFans(0);
    mapInput(0, testPos);
    mapInput(1, testPos);
    mapInput(2, testPos);
    mapInput(3, testPos);
    mapInput(4, testPos);
    mapInput(5, testPos);
    mapInput(6, testPos);
    mapInput(7, testPos);    
    test = false;    
  }

  if (instr0.moveTo != instr0.stepper->currentPosition() ) moveStepper(&instr0);
  if (instr1.moveTo != instr1.stepper->currentPosition() ) moveStepper(&instr1);
  if (instr2.moveTo != instr2.stepper->currentPosition() ) moveStepper(&instr2);
  if (instr3.moveTo != instr3.stepper->currentPosition() ) moveStepper(&instr3);
  if (instr4.moveTo != instr4.stepper->currentPosition() ) moveStepper(&instr4);
  if (instr5.moveTo != instr5.stepper->currentPosition() ) moveStepper(&instr5);
  if (instr6.moveTo != instr6.stepper->currentPosition() ) moveStepper(&instr6);
  if (instr7.moveTo != instr7.stepper->currentPosition() ) moveStepper(&instr7);
}

void testFans(int value) {
  analogWrite(instr0.fanPort, value);
  analogWrite(instr1.fanPort, value);
  analogWrite(instr2.fanPort, value);
  analogWrite(instr3.fanPort, value);
  analogWrite(instr4.fanPort, value);
  analogWrite(instr5.fanPort, value);
  analogWrite(instr6.fanPort, value);
  analogWrite(instr7.fanPort, value);
}

void mapInput(int ctlAndId, int value) {
  switch(ctlAndId) {
    case 0:
      instr0.moveTo = map(value, 0, 255, 0, 3250);
      instr0.stepperCtlChanged = true;
      break;
    case 1:
      instr1.moveTo = map(value, 0, 255, 0, 3250);
      instr1.stepperCtlChanged = true;
      break;
    case 2:
      instr2.moveTo = map(value, 0, 255, 0, 3250);
      instr2.stepperCtlChanged = true;
      break;
    case 3:
      instr3.moveTo = map(value, 0, 255, 0, 3250);
      instr3.stepperCtlChanged = true;
      break;
    case 4:
      instr4.moveTo = map(value, 0, 255, 0, 3250);
      instr4.stepperCtlChanged = true;
      break;
    case 5:
      instr5.moveTo = map(value, 0, 255, 0, 3250);
      instr5.stepperCtlChanged = true;
      break;
    case 6:
      instr6.moveTo = map(value, 0, 255, 0, 3250);
      instr6.stepperCtlChanged = true;
      break;
    case 7:
      instr7.moveTo = map(value, 0, 255, 0, 3250);
      instr7.stepperCtlChanged = true;
      break;
    case 10:
      instr0.speed = map(value, 0, 255, 0, 1000);
      instr0.stepperCtlChanged = true;
      break;
    case 11:
      instr1.speed = map(value, 0, 255, 0, 1000);
      instr1.stepperCtlChanged = true;
      break;
    case 12:
      instr2.speed = map(value, 0, 255, 0, 1000);
      instr2.stepperCtlChanged = true;
      break;
    case 13:
      instr3.speed = map(value, 0, 255, 0, 1000);
      instr3.stepperCtlChanged = true;
      break;
    case 14:
      instr4.speed = map(value, 0, 255, 0, 1000);
      instr4.stepperCtlChanged = true;
      break;
    case 15:
      instr5.speed = map(value, 0, 255, 0, 1000);
      instr5.stepperCtlChanged = true;
      break;
    case 16:
      instr6.speed = map(value, 0, 255, 0, 1000);
      instr6.stepperCtlChanged = true;
      break;
    case 17:
      instr7.speed = map(value, 0, 255, 0, 1000);
      instr7.stepperCtlChanged = true;
      break;
    case 20:
      analogWrite(instr0.fanPort, value ); // map not needed here
      break;
    case 21:
      analogWrite(instr1.fanPort, value ); // map not needed here
      break;
    case 22:
      analogWrite(instr2.fanPort, value ); // map not needed here
      break;
    case 23:
      analogWrite(instr3.fanPort, value ); // map not needed here
      break;
    case 24:
      analogWrite(instr4.fanPort, value ); // map not needed here
      break;
    case 25:
      analogWrite(instr5.fanPort, value ); // map not needed here
      break;
    case 26:
      analogWrite(instr6.fanPort, value ); // map not needed here
      break;
    case 27:
      analogWrite(instr7.fanPort, value ); // map not needed here
      break;
    case 9:
      calibrateMotorPos_bool = true; // re-calibrate motor pos
      break;
  }
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
    bool inv_extended_state = digitalRead(instr->extendedButton);

    if (!inv_extended_state) {
      instr->stepper->setCurrentPosition(0);
      break;
    }

    instr->stepper->runSpeed();
  }
  delay(10);
}