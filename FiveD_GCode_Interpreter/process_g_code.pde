
#include "configuration.h"
#include "pins.h"
#include "extruder.h"
#include "vectors.h"
#include "cartesian_dda.h"

/* bit-flags for commands and parameters */
#define GCODE_G	(1<<0)
#define GCODE_M	(1<<1)
#define GCODE_P	(1<<2)
#define GCODE_X	(1<<3)
#define GCODE_Y	(1<<4)
#define GCODE_Z	(1<<5)
#define GCODE_I	(1<<6)
#define GCODE_J	(1<<7)
#define GCODE_K	(1<<8)
#define GCODE_F	(1<<9)
#define GCODE_S	(1<<10)
#define GCODE_Q	(1<<11)
#define GCODE_R	(1<<12)
#define GCODE_E	(1<<13)
#define GCODE_T	(1<<14)


#define PARSE_INT(ch, str, len, val, seen, flag) \
	case ch: \
		len = scan_int(str, &val, &seen, flag); \
		break;

#define PARSE_FLOAT(ch, str, len, val, seen, flag) \
	case ch: \
		len = scan_float(str, &val, &seen, flag); \
		break;

/* gcode line parse results */
struct GcodeParser
{
    unsigned int seen;
    int G;
    int M;
    int T;
    float P;
    float X;
    float Y;
    float Z;
    float E;
    float I;
    float J;
    float F;
    float S;
    float R;
    float Q;
};


//our command string
char cmdbuffer[COMMAND_SIZE];
char c = '?';
byte serial_count = 0;
boolean comment = false;
FloatPoint fp;
FloatPoint sp;
        
// The following three inline functions are used for things like return to 0

inline void specialMoveX(const float& x, const float& feed)
{
  sp = where_i_am;
  sp.x = x;
  sp.f = feed;
  qMove(sp);
}

inline void specialMoveY(const float& y, const float& feed)
{
  sp = where_i_am;
  sp.y = y;
  sp.f = feed;
  qMove(sp);
}

inline void specialMoveZ(const float& z, const float& feed)
{
  sp = where_i_am;
  sp.z = z; 
  sp.f = feed;
  qMove(sp);
}

void zeroX()
{
  where_i_am.f = SLOW_XY_FEEDRATE;
  specialMoveX(where_i_am.x - 5, FAST_XY_FEEDRATE);
  specialMoveX(where_i_am.x - 250, FAST_XY_FEEDRATE);
  where_i_am.x = 0;
  where_i_am.f = SLOW_XY_FEEDRATE;
  specialMoveX(where_i_am.x + 1, SLOW_XY_FEEDRATE);
  specialMoveX(where_i_am.x - 10, SLOW_XY_FEEDRATE);                                
  where_i_am.x = 0;  
}

void zeroY()
{
  specialMoveY(where_i_am.y - 5, FAST_XY_FEEDRATE);
  specialMoveY(where_i_am.y - 250, FAST_XY_FEEDRATE);
  where_i_am.y = 0;
  where_i_am.f = SLOW_XY_FEEDRATE;
  specialMoveY(where_i_am.y + 1, SLOW_XY_FEEDRATE);
  specialMoveY(where_i_am.y - 10, SLOW_XY_FEEDRATE);                                
  where_i_am.y = 0; 
   
}

void zeroZ()
{
  where_i_am.f = SLOW_Z_FEEDRATE;
  specialMoveZ(where_i_am.z - 0.5, FAST_Z_FEEDRATE);
  specialMoveZ(where_i_am.z - 250, FAST_Z_FEEDRATE);
  where_i_am.z = 0;
  where_i_am.f = SLOW_Z_FEEDRATE;
  specialMoveZ(where_i_am.z + 1, SLOW_Z_FEEDRATE);
  specialMoveZ(where_i_am.z - 2, SLOW_Z_FEEDRATE);                                
  where_i_am.z = 0;  
}

//our feedrate variables.
//float feedrate = SLOW_XY_FEEDRATE;

/* keep track of the last G code - this is the command mode to use
 * if there is no command in the current string 
 */
int last_gcode_g = -1;

boolean abs_mode = true; //0 = incremental; 1 = absolute

float extruder_speed = 0;

int scan_int(char *str, int *valp);
int scan_float(char *str, float *valp);

GcodeParser gc;	/* string parse result */


//init our string processing
inline void init_process_string()
{
	serial_count = 0;
        comment = false;
}

// Get a command and process it

bool get_and_do_command()
{
	//read in characters if we got them.
	if (Serial.available())
	{
		c = Serial.read();
                if(c == '\r')
                  c = '\n';
                // Throw away control chars except \n
                if(c >= ' ' || c == '\n')
                {

		  //newlines are ends of commands.
		  if (c != '\n')
		  {
			// Start of comment - ignore any bytes received from now on
			if (c == ';')
				comment = true;
				
			// If we're not in comment mode, add it to our array.
			if (!comment)
				cmdbuffer[serial_count++] = c;
		  }

                }
	}

        // Data runaway?
        if(serial_count >= COMMAND_SIZE)
          init_process_string();

	//if we've got a real command, do it
	if (serial_count && c == '\n')
	{
                // Terminate string
                cmdbuffer[serial_count] = 0;
                
		//process our command!
		bool busy = process_string(cmdbuffer, serial_count);

		//clear command.
		init_process_string();

                // Say we're ready for the next one
                
                if(debugstring[0] != 0)
                {
                  Serial.print("ok ");
                  Serial.println(debugstring);
                  debugstring[0] = 0;
                } else
                  Serial.println("ok");
                  
    return busy;
	}
	else
	{
	  return false;
	}
}



int parse_string(struct GcodeParser * gc, char instruction[ ], int size)
{
	int ind;
	int len;	/* length of parameter argument */

	gc->seen = 0;

	len=0;
	/* scan the string for commands and parameters, recording the arguments for each,
	 * and setting the seen flag for each that is seen
	 */
	for (ind=0; ind<size; ind += (1+len))
	{
		len = 0;
		switch (instruction[ind])
		{
			  PARSE_INT('G', &instruction[ind+1], len, gc->G, gc->seen, GCODE_G);
			  PARSE_INT('M', &instruction[ind+1], len, gc->M, gc->seen, GCODE_M);
			  PARSE_INT('T', &instruction[ind+1], len, gc->T, gc->seen, GCODE_T);
			PARSE_FLOAT('S', &instruction[ind+1], len, gc->S, gc->seen, GCODE_S);
			PARSE_FLOAT('P', &instruction[ind+1], len, gc->P, gc->seen, GCODE_P);
			PARSE_FLOAT('X', &instruction[ind+1], len, gc->X, gc->seen, GCODE_X);
			PARSE_FLOAT('Y', &instruction[ind+1], len, gc->Y, gc->seen, GCODE_Y);
			PARSE_FLOAT('Z', &instruction[ind+1], len, gc->Z, gc->seen, GCODE_Z);
			PARSE_FLOAT('I', &instruction[ind+1], len, gc->I, gc->seen, GCODE_I);
			PARSE_FLOAT('J', &instruction[ind+1], len, gc->J, gc->seen, GCODE_J);
			PARSE_FLOAT('F', &instruction[ind+1], len, gc->F, gc->seen, GCODE_F);
			PARSE_FLOAT('R', &instruction[ind+1], len, gc->R, gc->seen, GCODE_R);
			PARSE_FLOAT('Q', &instruction[ind+1], len, gc->Q, gc->seen, GCODE_Q);
			PARSE_FLOAT('E', &instruction[ind+1], len, gc->E, gc->seen, GCODE_E);
                        default:
			  break;
		}
	}
}


//Read the string and execute instructions
bool process_string(char instruction[], int size)
{
	//the character / means delete block... used for comments and stuff.
	if (instruction[0] == '/')	
		return false;

        float fr;
        bool axisSelected;
        
	fp.x = 0.0;
	fp.y = 0.0;
	fp.z = 0.0;
        fp.e = 0.0;
        fp.f = 0.0;

	//get all our parameters!
	parse_string(&gc, instruction, size);
	/* if no command was seen, but parameters were, then use the last G code as 
	 * the current command
	 */
	if ((!(gc.seen & (GCODE_G | GCODE_M | GCODE_T))) && 
	    ((gc.seen != 0) &&
		(last_gcode_g >= 0))
	)
	{
		/* yes - so use the previous command with the new parameters */
		gc.G = last_gcode_g;
		gc.seen |= GCODE_G;
	}
	//did we get a gcode?
	if (gc.seen & GCODE_G)
	{
		last_gcode_g = gc.G;	/* remember this for future instructions */
		fp = where_i_am;
		if (abs_mode)
		{
			if (gc.seen & GCODE_X)
				fp.x = gc.X;
			if (gc.seen & GCODE_Y)
				fp.y = gc.Y;
			if (gc.seen & GCODE_Z)
				fp.z = gc.Z;
			if (gc.seen & GCODE_E)
				fp.e = gc.E;
		}
		else
		{
			if (gc.seen & GCODE_X)
				fp.x += gc.X;
			if (gc.seen & GCODE_Y)
				fp.y += gc.Y;
			if (gc.seen & GCODE_Z)
				fp.z += gc.Z;
			if (gc.seen & GCODE_E)
				fp.e += gc.E;
		}

		// Get feedrate if supplied - feedrates are always absolute???
		if ( gc.seen & GCODE_F )
			fp.f = gc.F;
               
                // Process the buffered move commands first
                // If we get one, return immediately

		switch (gc.G)
                {
			//Rapid move
			case 0:
                                fr = fp.f;
                                fp.f = FAST_XY_FEEDRATE;
                                qMove(fp);
                                fp.f = fr;
                                return true;
                                
                        // Controlled move
			case 1:
                                qMove(fp);
                                return true;
                                
                        //go home.
			case 28:
                                axisSelected = false;
                                if(gc.seen & GCODE_X)
                                {
                                  zeroX();
                                  axisSelected = true;
                                }
                                if(gc.seen & GCODE_Y)
                                {
                                  zeroY();
                                  axisSelected = true;
                                }                                
                                if(gc.seen & GCODE_Z)
                                {
                                  zeroZ();
                                  axisSelected = true;
                                }
                                if(!axisSelected)
                                {
                                  zeroX();
                                  zeroY();
                                  zeroZ();
                                }
                                where_i_am.f = SLOW_XY_FEEDRATE;     // Most sensible feedrate to leave it in                    

				return true;


                  default:
                                break;
                }
                
		// Non-buffered G commands
                // Wait till the buffer q is empty first
                    
                  while(!qEmpty()) delay(WAITING_DELAY);
		  switch (gc.G)
		  {

  			 //Dwell
			case 4:
				delay((int)(gc.P + 0.5));  
				break;

			//Inches for Units
			case 20:
                                setUnits(false);
				break;

			//mm for Units
			case 21:
                                setUnits(true);
				break;

			//Absolute Positioning
			case 90: 
				abs_mode = true;
				break;

			//Incremental Positioning
			case 91: 
				abs_mode = false;
				break;

			//Set position as fp
			case 92: 
                                setPosition(fp);
				break;

			default:
				Serial.print("huh? G");
				Serial.println(gc.G, DEC);
		  }
	}



        
	//find us an m code.
	if (gc.seen & GCODE_M)
	{
            // Wait till the q is empty first
            while(!qEmpty()) delay(WAITING_DELAY);
            
		switch (gc.M)
		{
			//TODO: this is a bug because search_string returns 0.  gotta fix that.
			case 0:
				break;
				/*
				 case 0:
				 //todo: stop program
				 break;

				 case 1:
				 //todo: optional stop
				 break;

				 case 2:
				 //todo: program end
				 break;
				 */

// jglauche: re-activate M101-M103 and M108 codes to support both 3d & 5d code


			//turn extruder on, forward
			case 101:
				ex[extruder_in_use]->set_direction(0);
				//ex[extruder_in_use]->set_speed(extruder_speed);
				break;

			//turn extruder on, reverse
			case 102:
				ex[extruder_in_use]->set_direction(1);
				//ex[extruder_in_use]->set_speed(extruder_speed);
				break;

			//turn extruder off
			case 103:
				//ex[extruder_in_use]->set_speed(0);
				break;

			//custom code for temperature control
			case 104:
				if (gc.seen & GCODE_S)
				{
					ex[extruder_in_use]->set_target_temperature((int)gc.S);
				}
				break;

			//custom code for temperature reading
			case 105:
				Serial.print("T:");
				Serial.println(ex[extruder_in_use]->get_temperature());
				break;

			//turn fan on
			case 106:
				ex[extruder_in_use]->set_cooler(255);
				break;

			//turn fan off
			case 107:
				ex[extruder_in_use]->set_cooler(0);
				break;

			//set max extruder speed, 0-255 PWM
			case 108:
				if (gc.seen & GCODE_S)
					extruder_speed = gc.S;
				break;
			//changed 109 to extruder heater
			//added case 140: heater bed
			//both from Gcodes generated by reprap host Jnfischer 07222010
			case 109: //extruder temperature
				if (gc.seen & GCODE_S)
				{
					ex[extruder_in_use]->set_target_temperature((int)gc.S);
				}
				break;
			case 110:
                                //set current line number
                                break;
                                
                        //custom code to wait until temperature is reached
                        /*case 111:
                                ex[extruder_in_use]->wait_for_temperature();
                                break;
*/
                        case 111:
                                //set Debug Level
                                //M111 S6 -set debug to level 6
                                break;
                        case 112:
                                //emergency stop
                                break;
                        case 113:
                                //stop extruder
                                extruder_speed = 0;
                                break;
                        case 114:
                                //Get current position
                                break;
                        case 115:
                                //Get firmware version and capabilities
                                break;
                        case 116:
                                //Wait for all temperatures and other slowly-changing variables to arrive at their set values
                                //see also deprecated M111
                                ex[extruder_in_use]->wait_for_temperature();
                                break;
                        case 117:
                                //get Zero position in steps
                                break;
                                
 			case 140: // Base plate heater on/off 
 				/*if (gc.seen & GCODE_S)
 				  digitalWrite(BASE_HEATER_PIN, gc.S != 0);*/
                                Serial.println("what base heater?");
 				break;
                        case 141:
                                 //chamber temperature
                                 break;
                        case 142:
                                 //holding pressure... 
                                 break;
                        case 226:
                                 //Gcode initiated pause
                                 break;
                        case 227:
                                 //enable automatic reverse and prime
                                 break;
                        case 228:
                                 //disable automatic reverse and prime
                                 break;
                        case 229:
                                 //enable automatic reverse and prime
                                 break;
                        case 230:
                                 //disable / enable wait for temperature change
                                 break;
                         

			default:
				Serial.print("[FIRMWARE WARNING] invalid M-Code received: M");
				Serial.println(gc.M, DEC);
		}

                

	}

// Tool (i.e. extruder) change?
                
        if (gc.seen & GCODE_T)
        {
           /* while(!qEmpty()) delay(WAITING_DELAY);
            new_extruder(gc.T);
            return false;*/
        }
        
        return true;
}

int scan_float(char *str, float *valp, unsigned int *seen, unsigned int flag)
{
	float res;
	int len;
	char *end;
     
	res = (float)strtod(str, &end);
      
	len = end - str;

	if (len > 0)
	{
		*valp = res;
		*seen |= flag;
	}
	else
		*valp = 0;
          
	return len;	/* length of number */
}

int scan_int(char *str, int *valp, unsigned int *seen, unsigned int flag)
{
	int res;
	int len;
	char *end;

	res = (int)strtol(str, &end, 10);
	len = end - str;

	if (len > 0)
	{
		*valp = res;
		*seen |= flag;
	}
	else
		*valp = 0;
          
	return len;	/* length of number */
}



