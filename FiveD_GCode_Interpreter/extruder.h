
// Class for controlling each extruder
//
// Adrian Bowyer 14 May 2009

#ifndef EXTRUDER_H
#define EXTRUDER_H

#define EXTRUDER_COUNT 1

void manage_all_extruders();

void new_extruder(byte e);

class extruder
{
private:

//these our the default values for the extruder.
    byte e_speed;
    int target_celsius;
    int max_celsius;
    byte heater_low;
    byte heater_high;
    byte heater_current;
    int extrude_step_count;

// These are used for temperature control    
    byte count ;
    int oldT, newT;
    
    bool e_direction;
    bool valve_open;

// The pins we control
    byte motor_dir_pin, motor_speed_pin, heater_pin, fan_pin, temp_pin, valve_dir_pin, valve_en_pin;
    signed int step_en_pin;
    
     byte wait_till_hot();
     //byte wait_till_cool();
     void temperature_error(); 
     int sample_temperature();
     
public:

   extruder(byte md_pin, byte ms_pin, byte h_pin, byte f_pin, byte t_pin, byte vd_pin, byte ve_pin, signed int se_pin);
   void wait_for_temperature();
   void valve_set(bool open, int dTime);

   void set_direction(bool direction);
   //void set_speed(float es);
   void set_cooler(byte e_speed);
   void set_target_temperature(int temp);
   int get_target_temperature();
   int get_temperature();
   void manage();
// Interrupt setup and handling functions for stepper-driven extruders
   
   //void interrupt();
   void step();

   void enableStep();
   void disableStep();
   
};

inline void extruder::enableStep()
{
  if(step_en_pin < 0)
    return;
  digitalWrite(step_en_pin, ENABLE_ON); 
}

inline void extruder::disableStep()
{
  if(step_en_pin < 0)
    return;
  digitalWrite(step_en_pin, !ENABLE_ON);
}

inline void extruder::step()
{
   digitalWrite(motor_speed_pin, HIGH);
   delayMicroseconds(5);
   digitalWrite(motor_speed_pin, LOW);
}

inline void extruder::temperature_error()
{
      Serial.print("E: ");
      Serial.println(get_temperature());  
}

inline void extruder::set_cooler(byte sp)
{
  if(step_en_pin >= 0) // Step enable conflicts with the fan
    return;
  analogWrite(fan_pin, sp);
}

inline void extruder::set_direction(bool dir)
{
	e_direction = dir;
	digitalWrite(motor_dir_pin, e_direction);
}


extern extruder* ex[];
extern byte extruder_in_use;

#endif
