#ifndef THERMISTORTABLE_H_
#define THERMISTORTABLE_H_


// Uncomment the next line if you are using a thermistor; leave it if you have a thermocouple
#define USE_THERMISTOR

// How many temperature samples to take for an average.  each sample takes about 100 usecs.
#define TEMPERATURE_SAMPLES 3

// How accurately do we maintain the temperature?
#define HALF_DEAD_ZONE 5

// 06.14.2010 jnf thermistorTable.h changed to  EPCOS 100K Thermistor (B57540G0104F000) from; http://reprap.org/wiki/Thermistor
// Thermistor lookup table for RepRap Temperature Sensor Boards (http://make.rrrf.org/ts)
// Made with createTemperatureLookup.py (http://svn.reprap.org/trunk/reprap/firmware/Arduino/utilities/createTemperatureLookup.py)
// ./createTemperatureLookup.py --r0=100000 --t0=25 --r1=0 --r2=4700 --beta=4066 --max-adc=1023
// r0: 100000
// t0: 25
// r1: 0
// r2: 4700
// beta: 4066
// max adc: 1023
#define NUMTEMPS 20
short temptable[NUMTEMPS][2] = {
   {1, 571},
   {17, 253},
   {33, 208},
   {49, 183},
   {65, 166},
   {81, 152},
   {97, 141},
   {113, 131},
   {129, 123},
   {145, 115},
   {161, 107},
   {177, 100},
   {193, 92},
   {209, 85},
   {225, 77},
   {241, 68},
   {257, 58},
   {273, 46},
   //{289, 28}
   {955, 37},
   {1008, 4}
};

//November 17, 2010
// Thermistor lookup table for RepRap Temperature Sensor Boards (http://make.rrrf.org/ts)
// Made with createTemperatureLookup.py (http://svn.reprap.org/trunk/reprap/firmware/Arduino/utilities/createTemperatureLookup.py)
// ./createTemperatureLookup.py --r0=121800 --t0=20 --r1=0 --r2=4200 --beta=3949 --max-adc=1023
// r0: 121800
// t0: 20
// r1: 0
// r2: 4200
// beta: 3949
// max adc: 1023
/*#define NUMTEMPS 20
short temptable[NUMTEMPS][2] = {
   {1, 971},
   {54, 274},
   {107, 223},
   {160, 196},
   {213, 177},
   {266, 162},
   {319, 150},
   {372, 140},
   {425, 131},
   {478, 122},
   {531, 114},
   {584, 107},
   {637, 99},
   {690, 91},
   {743, 83},
   {796, 74},
   {849, 64},
   {902, 53},
   {955, 37},
   {1008, 4}
};
*/

#define NUMTEMPS (sizeof(temptable) / sizeof(temptable[0]))

#endif
