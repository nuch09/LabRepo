#include <stdio.h>
#include "system.h"
#include "includes.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "sys/alt_alarm.h"

#define DEBUG 1

#define HW_TIMER_PERIOD 100 /* 100ms */

/* Button Patterns */

#define GAS_PEDAL_FLAG      0x08
#define BRAKE_PEDAL_FLAG    0x04
#define CRUISE_CONTROL_FLAG 0x02
/* Switch Patterns */

#define TOP_GEAR_FLAG       0x00000002
#define ENGINE_FLAG         0x00000001

/* LED Patterns */

#define LED_RED_0 0x00000001 // Engine
#define LED_RED_1 0x00000002 // Top Gear

#define LED_RED_17 0x00020000 // Starting Position
#define LED_RED_TRACK_MASK 0x0003F000   // Mask for all LEDs involved in position 

#define LED_GREEN_0 0x0001 // Cruise Control activated
#define LED_GREEN_2 0x0002 // Cruise Control Button
#define LED_GREEN_4 0x0010 // Brake Pedal
#define LED_GREEN_6 0x0040 // Gas Pedal

/*
 * Definition of Tasks
 */

#define TASK_STACKSIZE 2048

OS_STK StartTask_Stack[TASK_STACKSIZE]; 
OS_STK ControlTask_Stack[TASK_STACKSIZE]; 
OS_STK VehicleTask_Stack[TASK_STACKSIZE];
OS_STK ButtonIOTask_Stack[TASK_STACKSIZE];
OS_STK SwitchIOTask_Stack[TASK_STACKSIZE];

// Task Priorities
 
#define STARTTASK_PRIO     5
#define VEHICLETASK_PRIO  10
#define CONTROLTASK_PRIO  12
#define BUTTONIOTASK_PRIO  15
#define SWITCHIOTASK_PRIO  18

// Task Periods

#define CONTROL_PERIOD  300
#define VEHICLE_PERIOD  300

/*
 * Definition of Kernel Objects 
 */

// Mailboxes
OS_EVENT *Mbox_Throttle;
OS_EVENT *Mbox_Velocity;

// Semaphores
OS_EVENT *ctrl_timer_semaphore;
OS_EVENT *vehicle_timer_semaphore;

// SW-Timer
OS_TMR *ctrl_timer;
OS_TMR *vehicle_timer;

/*
 * Types
 */
enum active {on, off};

enum active gas_pedal = off;
enum active brake_pedal = off;
enum active top_gear = off;
enum active engine = off;
enum active cruise_control = off; 

/*
 * Global variables
 */
int delay; // Delay of HW-timer 
INT16U led_green = 0; // Green LEDs
INT32U led_red = 0;   // Red LEDs
volatile INT32S global_velocity = 0;

int buttons_pressed(void)
{
  return ~IORD_ALTERA_AVALON_PIO_DATA(DE2_PIO_KEYS4_BASE);    
}

int switches_pressed(void)
{
  return IORD_ALTERA_AVALON_PIO_DATA(DE2_PIO_TOGGLES18_BASE);    
}

/*
 * ISR for HW Timer
 */
alt_u32 alarm_handler(void* context)
{
  OSTmrSignal(); /* Signals a 'tick' to the SW timers */
  
  return delay;
}

void control_sw_alarm_handler(void* ptmr, void* callback_arg)
{
    //sw timer control timeout
    OSSemPost(ctrl_timer_semaphore);
}

void vehicle_sw_alarm_handler(void* ptmr, void* callback_arg)
{
    //sw timer vehicle timeout
    OSSemPost(vehicle_timer_semaphore);
}

static int b2sLUT[] = {0x40, //0
                 0x79, //1
                 0x24, //2
                 0x30, //3
                 0x19, //4
                 0x12, //5
                 0x02, //6
                 0x78, //7
                 0x00, //8
                 0x18, //9
                 0x3F, //-
};

/*
 * convert int to seven segment display format
 */
int int2seven(int inval){
    return b2sLUT[inval];
}

/*
 * output current velocity on the seven segement display
 */
void show_velocity_on_sevenseg(INT16S velocity){
  int tmp = velocity;
  int out;
  INT8U out_high = 0;
  INT8U out_low = 0;
  INT8U out_sign = 0;

  if(velocity < 0){
     out_sign = int2seven(10);
     tmp *= -1;
  }else{
     out_sign = int2seven(0);
  }

  out_high = int2seven(tmp / 10);
  out_low = int2seven(tmp - (tmp/10) * 10);
  
  out = int2seven(0) << 21 |
            out_sign << 14 |
            out_high << 7  |
            out_low;
  IOWR_ALTERA_AVALON_PIO_DATA(DE2_PIO_HEX_LOW28_BASE,out);
}

/*
 * shows the target velocity on the seven segment display (HEX5, HEX4)
 * when the cruise control is activated (0 otherwise)
 */
void show_target_velocity(INT32U target_vel)
{
  int tmp = target_vel;
  int out;
  INT8U out_high = 0;
  INT8U out_low = 0;

  out_high = int2seven(tmp / 10);
  out_low = int2seven(tmp - (tmp/10) * 10);
  
  out = int2seven(0) << 21 |
        int2seven(0) << 14 |
            out_high << 7  |
            out_low;
  IOWR_ALTERA_AVALON_PIO_DATA(DE2_PIO_HEX_HIGH28_BASE,out);
    
}

/*
 * indicates the position of the vehicle on the track with the four leftmost red LEDs
 * LEDR17: [0m, 400m)
 * LEDR16: [400m, 800m)
 * LEDR15: [800m, 1200m)
 * LEDR14: [1200m, 1600m)
 * LEDR13: [1600m, 2000m)
 * LEDR12: [2000m, 2400m]
 */
void show_position(INT16U position)
{
    if(position > 24000) position -= 24000;
    if(position == 24000) position -= 1;
    
    position /= 4000; // scale into interval [0,5]
    led_red&=~LED_RED_TRACK_MASK;       // reset all track-leds
    led_red|=LED_RED_17 >> position;    // set the led of the current position
}

/*
 * The function 'adjust_position()' adjusts the position depending on the
 * acceleration and velocity.
 */
 INT16U adjust_position(INT16U position, INT16S velocity,
                        INT8S acceleration, INT16U time_interval)
{
  INT16S new_position = position + velocity * time_interval / 1000
    + acceleration / 2  * (time_interval / 1000) * (time_interval / 1000);

  if (new_position > 24000) {
    new_position -= 24000;
  } else if (new_position < 0){
    new_position += 24000;
  }
  
  show_position(new_position);
  return new_position;
}
 
/*
 * The function 'adjust_velocity()' adjusts the velocity depending on the
 * acceleration.
 */
INT16S adjust_velocity(INT16S velocity, INT8S acceleration,  
		       enum active brake_pedal, INT16U time_interval)
{
  INT16S new_velocity;
  INT8U brake_retardation = 200;

  if (brake_pedal == off)
    new_velocity = velocity  + (float) (acceleration * time_interval) / 1000.0;
  else {
    if (brake_retardation * time_interval / 1000 > velocity)
      new_velocity = 0;
    else
      new_velocity = velocity - brake_retardation * time_interval / 1000;
  }
  
  return new_velocity;
}

/*
 * The task 'ButtonIO' updates the state of cruise_control, gas_pedal and brake_pedal
 */
void ButtonIOTask(void *pdata)
{
    int buttons;
    while(1)
    {
        buttons=buttons_pressed();
        if(buttons & GAS_PEDAL_FLAG)
        {
            gas_pedal = on;
            led_green|=LED_GREEN_6;
        }  
        else
        {
            gas_pedal = off;
            led_green&=~LED_GREEN_6;
        }
        if(buttons & BRAKE_PEDAL_FLAG)
        {
            brake_pedal = on;
            led_green|=LED_GREEN_4;
        }  
        else
        {
            brake_pedal = off;
            led_green&=~LED_GREEN_4;
        }
        if(buttons & CRUISE_CONTROL_FLAG)
        {
            cruise_control = on;
            led_green|=LED_GREEN_2;
        }  
        else
        {
            cruise_control = off;
            led_green&=~LED_GREEN_2;
        }
        OSTimeDlyHMSM(0,0,0,20);
        IOWR_ALTERA_AVALON_PIO_DATA(DE2_PIO_GREENLED9_BASE, led_green);
    }
}

/*
 * The task 'SwitchIO' updates the state of cruise_control, gas_pedal and brake_pedal
 */
void SwitchIOTask(void *pdata)
{
    int switches;
    
    while(1)
    {
        switches=switches_pressed();
        if(switches & TOP_GEAR_FLAG)
        {
            top_gear = on;
            led_red|=LED_RED_1;
        }
        else
        {
            top_gear = off;;
            led_red&=~LED_RED_1;
        }
        
        if(switches & ENGINE_FLAG) 
        {
            engine = on; 
            led_red|=LED_RED_0;
        }
        else
        {
            if(global_velocity == 0) {
                engine = off; 
                led_red&=~LED_RED_0;
            }
        }
        IOWR_ALTERA_AVALON_PIO_DATA(DE2_PIO_REDLED18_BASE, led_red);
        OSTimeDlyHMSM(0,0,0,20);
    }
}
/*
 * The task 'VehicleTask' updates the current velocity of the vehicle
 */
void VehicleTask(void* pdata)
{ 
  INT8U err;  
  void* msg;
  INT8U* throttle; 
  INT8S acceleration;  /* Value between 40 and -20 (4.0 m/s^2 and -2.0 m/s^2) */
  INT8S retardation;   /* Value between 20 and -10 (2.0 m/s^2 and -1.0 m/s^2) */
  INT16U position = 0; /* Value between 0 and 20000 (0.0 m and 2000.0 m)  */
  INT16S velocity = 0; /* Value between -200 and 700 (-20.0 m/s amd 70.0 m/s) */
  INT16S wind_factor;   /* Value between -10 and 20 (2.0 m/s^2 and -1.0 m/s^2) */

  printf("Vehicle task created!\n");

  while(1)
    {
      err = OSMboxPost(Mbox_Velocity, (void *) &velocity);

      //OSTimeDlyHMSM(0,0,0,VEHICLE_PERIOD); 
       OSSemPend(vehicle_timer_semaphore,0,&err);
       
       
      /* Non-blocking read of mailbox: 
	   - message in mailbox: update throttle
	   - no message:         use old throttle
      */
      msg = OSMboxPend(Mbox_Throttle, 1, &err); 
      if (err == OS_NO_ERR) 
	     throttle = (INT8U*) msg;

      /* Retardation : Factor of Terrain and Wind Resistance */
      if (velocity > 0)
	     wind_factor = velocity * velocity / 10000 + 1;
      else 
	     wind_factor = (-1) * velocity * velocity / 10000 + 1;
         
      if (position < 4000) 
         retardation = wind_factor; // even ground
      else if (position < 8000)
          retardation = wind_factor + 15; // traveling uphill
        else if (position < 12000)
            retardation = wind_factor + 25; // traveling steep uphill
          else if (position < 16000)
              retardation = wind_factor; // even ground
            else if (position < 20000)
                retardation = wind_factor - 10; //traveling downhill
              else
                  retardation = wind_factor - 5 ; // traveling steep downhill
                  
      acceleration = *throttle / 2 - retardation;	  
      position = adjust_position(position, velocity, acceleration, 300); 
      velocity = adjust_velocity(velocity, acceleration, brake_pedal, 300); 
      printf("Position: %dm\n", position / 10);
      printf("Velocity: %4.1fm/s\n", velocity /10.0);
      printf("Throttle: %dV\n", *throttle / 10);
      show_velocity_on_sevenseg((INT8S) (velocity / 10));
      show_position(position);
    }
} 
 
/*
 * The task 'ControlTask' is the main task of the application. It reacts
 * on sensors and generates responses.
 */

void ControlTask(void* pdata)
{
  INT8U err;
  INT8U throttle = 40; /* Value between 0 and 80, which is interpreted as between 0.0V and 8.0V */
  void* msg;
  INT16S* current_velocity;

  printf("Control Task created!\n");
  int cruise_control_guard;
  int cruise_control_state = 0;
  int target_velocity;
  int ctrl_p = 3;
  int ctrl_i = 100;
  int ctrl_err = 0;
  while(1)
    {
      msg = OSMboxPend(Mbox_Velocity, CONTROL_PERIOD, &err);
      current_velocity = (INT16S*) msg;
      global_velocity = *current_velocity;
      cruise_control_guard = top_gear==on && 
                             *current_velocity >= 200 && 
                             gas_pedal==off && 
                             brake_pedal==off;
      if(cruise_control_guard) {
        if(cruise_control==on) {
            cruise_control_state = 1;
            target_velocity = *current_velocity;
            led_green |= LED_GREEN_0;
        }
      } else {
        cruise_control_state = 0;
        led_green &= ~LED_GREEN_0;
      }
      
      if(cruise_control_state) {
        // PI-Controller
        ctrl_err += (target_velocity - *current_velocity); 
        throttle = ctrl_p * (target_velocity - *current_velocity) + ctrl_i*ctrl_err/1000;
      }
      
      if(gas_pedal==on) {
        throttle++;
      }
      
      err = OSMboxPost(Mbox_Throttle, (void *) &throttle);
      show_target_velocity(target_velocity/10);
      printf("Target Velocity: %d\n", target_velocity);
      OSSemPend(ctrl_timer_semaphore, 0, &err);
      //OSTimeDlyHMSM(0,0,0, CONTROL_PERIOD);
    }
}

/* 
 * The task 'StartTask' creates all other tasks kernel objects and
 * deletes itself afterwards.
 */ 

void StartTask(void* pdata)
{
  INT8U err;
  void* context;

  static alt_alarm alarm;     /* Is needed for timer ISR function */
  
  /* Base resolution for SW timer : HW_TIMER_PERIOD ms */
  delay = alt_ticks_per_second() * HW_TIMER_PERIOD / 1000; 
  printf("delay in ticks %d\n", delay);

  /* 
   * Create Hardware Timer with a period of 'delay' 
   */
  if (alt_alarm_start (&alarm,
      delay,
      alarm_handler,
      context) < 0)
      {
          printf("No system clock available!n");
      }

  ctrl_timer_semaphore = OSSemCreate(0);
  vehicle_timer_semaphore = OSSemCreate(0);
  /* 
   * Create and start Software Timer 
   */
   
  ctrl_timer = OSTmrCreate(0,   // initial delay
                           CONTROL_PERIOD/100, // period
                           OS_TMR_OPT_PERIODIC,
                           control_sw_alarm_handler,
                           (void*)NULL,
                           "CntrlSWTimer",
                           &err);
                           
   
    vehicle_timer = OSTmrCreate(0,   // initial delay
                           VEHICLE_PERIOD/100, // period
                           OS_TMR_OPT_PERIODIC,
                           vehicle_sw_alarm_handler,
                           (void*)NULL,
                           "VehicleSWTimer",
                           &err);   
    
    OSTmrStart(ctrl_timer,&err);
    OSTmrStart(vehicle_timer,&err);
                  

  /*
   * Creation of Kernel Objects
   */
  
  // Mailboxes
  Mbox_Throttle = OSMboxCreate((void*) 0); /* Empty Mailbox - Throttle */
  Mbox_Velocity = OSMboxCreate((void*) 0); /* Empty Mailbox - Velocity */
   
  /*
   * Create statistics task
   */

  OSStatInit();

  /* 
   * Creating Tasks in the system 
   */


  err = OSTaskCreateExt(
	   ControlTask, // Pointer to task code
	   NULL,        // Pointer to argument that is
	                // passed to task
	   &ControlTask_Stack[TASK_STACKSIZE-1], // Pointer to top
							 // of task stack
	   CONTROLTASK_PRIO,
	   CONTROLTASK_PRIO,
	   (void *)&ControlTask_Stack[0],
	   TASK_STACKSIZE,
	   (void *) 0,
	   OS_TASK_OPT_STK_CHK);

  err = OSTaskCreateExt(
	   VehicleTask, // Pointer to task code
	   NULL,        // Pointer to argument that is
	                // passed to task
	   &VehicleTask_Stack[TASK_STACKSIZE-1], // Pointer to top
							 // of task stack
	   VEHICLETASK_PRIO,
	   VEHICLETASK_PRIO,
	   (void *)&VehicleTask_Stack[0],
	   TASK_STACKSIZE,
	   (void *) 0,
	   OS_TASK_OPT_STK_CHK);
  
    err = OSTaskCreateExt(
       ButtonIOTask, // Pointer to task code
       NULL,        // Pointer to argument that is
                    // passed to task
       &ButtonIOTask_Stack[TASK_STACKSIZE-1], // Pointer to top
                             // of task stack
       BUTTONIOTASK_PRIO,
       BUTTONIOTASK_PRIO,
       (void *)&ButtonIOTask_Stack[0],
       TASK_STACKSIZE,
       (void *) 0,
       OS_TASK_OPT_STK_CHK);
       
  err = OSTaskCreateExt(
       SwitchIOTask, // Pointer to task code
       NULL,        // Pointer to argument that is
                    // passed to task
       &SwitchIOTask_Stack[TASK_STACKSIZE-1], // Pointer to top
                             // of task stack
       SWITCHIOTASK_PRIO,
       SWITCHIOTASK_PRIO,
       (void *)&SwitchIOTask_Stack[0],
       TASK_STACKSIZE,
       (void *) 0,
       OS_TASK_OPT_STK_CHK);
  printf("All Tasks and Kernel Objects generated!\n");

  /* Task deletes itself */

  OSTaskDel(OS_PRIO_SELF);
}

/*
 *
 * The function 'main' creates only a single task 'StartTask' and starts
 * the OS. All other tasks are started from the task 'StartTask'.
 *
 */

int main(void) {

  printf("Lab: Cruise Control\n");
 
  OSTaskCreateExt(
	 StartTask, // Pointer to task code
         NULL,      // Pointer to argument that is
                    // passed to task
         (void *)&StartTask_Stack[TASK_STACKSIZE-1], // Pointer to top
						     // of task stack 
         STARTTASK_PRIO,
         STARTTASK_PRIO,
         (void *)&StartTask_Stack[0],
         TASK_STACKSIZE,
         (void *) 0,  
         OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR);
         
  OSStart();
  
  return 0;
}