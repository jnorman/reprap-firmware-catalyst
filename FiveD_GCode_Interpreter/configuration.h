#ifndef PARAMETERS_H
#define PARAMETERS_H

// Set 1s where you have endstops; 0s where you don't
#define ENDSTOPS_MIN_ENABLED 1
#define ENDSTOPS_MAX_ENABLED 0

//our command string length
#define COMMAND_SIZE 128

// The size of the movement buffer

#define BUFFER_SIZE 4

// Number of microseconds between timer interrupts when no movement
// is happening

#define DEFAULT_TICK (long)1000

// What delay() value to use when waiting for things to free up in milliseconds

#define WAITING_DELAY 1
#define BAUD_RATE 57600
#define INCHES_TO_MM 25.4

// define the parameters of our machine.
#define X_STEPS_PER_MM   314.960629921 //unnecessarily accurate?
#define X_STEPS_PER_INCH (X_STEPS_PER_MM*INCHES_TO_MM)
#define X_MOTOR_STEPS    400
#define INVERT_X_DIR 0

#define Y_STEPS_PER_MM   40.764914893//41.417153531
#define Y_STEPS_PER_INCH (Y_STEPS_PER_MM*INCHES_TO_MM)
#define Y_MOTOR_STEPS    1600
#define INVERT_Y_DIR 0

#define Z_STEPS_PER_MM   320 //314.960629921
#define Z_STEPS_PER_INCH (Z_STEPS_PER_MM*INCHES_TO_MM)
#define Z_MOTOR_STEPS    400
#define INVERT_Z_DIR 0

// For when we have a stepper-driven extruder
// E_STEPS_PER_MM is the number of steps needed to 
// extrude 1mm out of the nozzle.
// 07.07.2010 New extruder drive wheel 18mm diameter
#define E_STEPS_PER_MM   2.704 //0.706 // drive diameter = 4.7 mm, material in:material out = 36:1, 400 steps per revolution
#define E_STEPS_PER_INCH (E_STEPS_PER_MM*INCHES_TO_MM)
#define E_MOTOR_STEPS    400 //half-step

//our maximum feedrates
#define FAST_XY_FEEDRATE 500.0
#define FAST_Z_FEEDRATE  50.0

// Data for acceleration calculations
// Comment out the next line to turn accelerations off
#define ACCELERATION_ON
#define SLOW_XY_FEEDRATE 50.0 // Speed from which to start accelerating
#define SLOW_Z_FEEDRATE 15.0

// Set to 1 if enable pins are inverting
// For RepRap stepper boards version 1.x the enable pins are *not* inverting.
// For RepRap stepper boards version 2.x and above the enable pins are inverting.
#define INVERT_ENABLE_PINS 1

#if INVERT_ENABLE_PINS == 1
#define ENABLE_ON LOW
#else
#define ENABLE_ON HIGH
#endif

// Set to one if sensor outputs inverting (ie: 1 means open, 0 means closed)
// RepRap opto endstops are *not* inverting.
#define X_ENDSTOP_INVERTING true
#define Y_ENDSTOP_INVERTING true
#define Z_ENDSTOP_INVERTING true

// The number of mm below which distances are insignificant (one tenth the
// resolution of the machine is the default value).

#define SMALL_DISTANCE 0.01

// Useful to have its square

#define SMALL_DISTANCE2 (SMALL_DISTANCE*SMALL_DISTANCE)

// The number of 5-second intervals to wait at the target temperature for things to stabilise.
// Too short, and the extruder will jam as only part of it will be hot enough.
// Too long and the melt will extend too far up the insulating tube.
// Default value: 10

#define WAIT_AT_TEMPERATURE 10

//PWM heater settings 0 - 255
#define HEATER_HIGH 255
#define HEATER_LOW 64

// Inline interrupt control functions

inline void enableTimerInterrupt() 
{
   TIMSK1 |= (1<<OCIE1A);
}
	
inline void disableTimerInterrupt() 
{
     TIMSK1 &= ~(1<<OCIE1A);
}
        
inline void setTimerCeiling(unsigned int c) 
{
    OCR1A = c;
}

inline void resetTimer()
{
  TCNT2 = 0;
}

#endif
