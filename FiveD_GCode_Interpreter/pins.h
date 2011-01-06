#ifndef PINS_H
#define PINS_H


#define X_STEP_PIN (byte)3
#define X_DIR_PIN (byte)2
#define X_MIN_PIN (byte)15
#define X_MAX_PIN (byte)-1
#define X_ENABLE_PIN (byte)-1

#define Y_STEP_PIN (byte)5
#define Y_DIR_PIN (byte)4
#define Y_MIN_PIN (byte)16
#define Y_MAX_PIN (byte)-1
#define Y_ENABLE_PIN (byte)-1

#define Z_STEP_PIN (byte)18
#define Z_DIR_PIN (byte)7
#define Z_MIN_PIN (byte)17
#define Z_MAX_PIN (byte)-1
#define Z_ENABLE_PIN (byte)-1

//where's the BASE temperature pin?
//#define BASE_HEATER_PIN   (byte)-1 //and 13... have to do something about that

//extruder pins
#define EXTRUDER_0_MOTOR_SPEED_PIN   (byte)11
#define EXTRUDER_0_MOTOR_DIR_PIN     (byte)8
#define EXTRUDER_0_HEATER_PIN        (byte)13
#define EXTRUDER_0_FAN_PIN           (byte)-1
#define EXTRUDER_0_TEMPERATURE_PIN  (byte)0   // Analogue input
#define EXTRUDER_0_VALVE_DIR_PIN     (byte)-1
#define EXTRUDER_0_VALVE_ENABLE_PIN  (byte)-1  // Valve needs to be redesigned not to need this
#define EXTRUDER_0_STEP_ENABLE_PIN  (byte)12  // was set to 11... crap, probably have to fix this

#define EXTRUDER_1_MOTOR_SPEED_PIN   (byte)-1
#define EXTRUDER_1_MOTOR_DIR_PIN    (byte)-1
#define EXTRUDER_1_HEATER_PIN        (byte)-1
#define EXTRUDER_1_FAN_PIN           (byte)-1
#define EXTRUDER_1_TEMPERATURE_PIN  (byte)-1  // Analogue input
#define EXTRUDER_1_VALVE_DIR_PIN    (byte)-1
#define EXTRUDER_1_VALVE_ENABLE_PIN (byte)-1   // Valve needs to be redesigned not to need this 
#define EXTRUDER_1_STEP_ENABLE_PIN  (byte)-1  // 7 - Conflicts with the fan; set -ve if no stepper


#endif
