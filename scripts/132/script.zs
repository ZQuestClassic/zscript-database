import "std.zh"

import "ItemHandling.zh" //Requires v6.7 or higher.
import "Timers.zh" //Requires v1.0 or higher.


//////////////////////////////
/// Automatic Item ///////////
/// v2.1 6th May, 2017     ///
/// Creator: ZoriaRPG      ///
//////////////////////////////

///Variables, Arrays, and Constants

const int I_REPEAT = 14; //Default repeating item.

//Timers.zh array, timer ID. 
const int TI_REPEAT = 0;

//int AutoFireStoredItem; //Holds the value of the B-Slot item, between automatic activations.

//An array for the repeating item. 
int AutoFire[10] = { 0, 0, 0, 0, 0, 0, 0, 0, 100, 1 }; 

//AutoFire Indices:
const int AUTOFIRE_REPEAT_TIME = 8;
const int AUTOFIRE_SPEED = 9; //Index for array. 
const int AUTOFIRE_ENABLED = 7; 
const int AUTOFIRE_STOREDITEM = 6; 
const int AUTOFIRE_ITEM = 5; 

const int AUTOFIRE_R_DISABLES = 1; //If set to '1', and autofiring, the player may press R to turn off autofire. 

//! Accessors

//Set or get the item to autofire. 
void SetRepeatingItem(int itm) { AutoFire[AUTOFIRE_ITEM] = itm; }
int GetRepeatingItem() { return AutoFire[AUTOFIRE_ITEM]; }

//Set or get a custom rate of timer decrement. Default is 1. 
void SetAutoFireDecrementRate(int v) { AutoFire[AUTOFIRE_SPEED] = v; }
int GetAutoFireDecrementRate() { return AutoFire[AUTOFIRE_SPEED]; }

//Sets or get a custom delay. Default is 100. 
void SetAutoFireDelay(int v) { AutoFire[AUTOFIRE_REPEAT_TIME] = v; }
int GetAutoFireDelay() { return AutoFire[AUTOFIRE_REPEAT_TIME]; }

//Set or get autofire status. 
bool isAutoFire(){  return ( AutoFire[AUTOFIRE_ENABLED] != 0 ); }
void isAutoFire(bool a){
	if ( a ) AutoFire[AUTOFIRE_ENABLED] = 1;
	else AutoFire[AUTOFIRE_ENABLED] = 0;
}

//Set or get the stored equipment item. 
int AutoFireStoredItem() { return AutoFire[AUTOFIRE_STOREDITEM]; }
void AutoFireStoredItem(int a){ AutoFire[AUTOFIRE_STOREDITEM] = a; }

///Global Scripts

global script Init{
    void run(){
        setTimer(TI_REPEAT, 0);
    }
}
    
global script onExit{
	void run(){
		setTimer(TI_REPEAT, 0);
	}
}

global script activeRepeatingItem{
	void run(){
		while(true){
			setTimer(TI_REPEAT,GetAutoFireDelay());
			startTimer(TI_REPEAT);
			setRepeatOff();
			reduceTimer(TI_REPEAT,GetAutoFireDecrementRate());
			AutofireInitiate(LW_ARROW);

			Waitdraw();
			RevertItemAfterFiring();
			//Trace(returnTimer(TI_REPEAT)); //Print value to allegro.log.
			//AutofireUpdate(); //Disabled, not needed for this version.
		    
			Waitframe();
			}
		}
}

//Item Scripts

//This item simply triggers the boolean isAutoFire to true, or false. You can expand on this by using a boolean array.

//D0 is the item to autofire.
//D1 is the delay in frames before firing. 
//D2 is the timer decrement value (as an optional override to the default of '1')
item script repeatingWeapon{
	void run(int repeat, int timer, int decrement){
		//Sanity check for the item. 
		if ( repeat > 0 && repeat < 256 ) SetRepeatingItem(repeat); 
		//Default
		else SetRepeatingItem(I_REPEAT); 
		if ( timer > 0 ) { 
			timer = timer << 0; //Truncate
			SetAutoFireDelay(timer);
		}
		if ( decrement > 0 && decrement < timer ) {
			decrement = decrement << 0; 
			SetAutoFireDecrementRate(decrement);
		}

		isAutoFire(!isAutoFire()); //Flip the state.  
		//int ss[]="Tracing isAutoFire(): ";
		//TraceS(ss); TraceB(isAutoFire());
	}
}

//Functions

//Initiates autofiring mode. 
void AutofireInitiate(int lType){
	if ( isAutoFire() && !lWeaponExists(lType) && checkTimer(TI_REPEAT) ){
		AutoFireStoredItem(GetEquipmentB());
		SetItemB(GetRepeatingItem());
		Link->InputB = true;
		Waitframe();
		if ( GetEquipmentB() == GetRepeatingItem() ) {
		    SetItemB(AutoFireStoredItem());
		}
	}
        else { 
		AutoFireStoredItem(GetEquipmentB());
		if ( GetEquipmentB() != AutoFireStoredItem() ) {
			SetItemB(AutoFireStoredItem());
		}
        }
}

//Called after firing, to restore the item in slot B. 
void RevertItemAfterFiring(){
	if ( GetEquipmentB() == GetRepeatingItem() ) {
		SetItemB(AutoFireStoredItem());
        }
        else { 
		AutoFireStoredItem(GetEquipmentB());
		if ( GetEquipmentB() != AutoFireStoredItem() ) {
			SetItemB(AutoFireStoredItem());
		}
        }
}

//Initialises automatic firing of a weapon, or automatic use of an item that is not an lweapon. 
void AutofireInitiate(int repeatingItem, bool notLType){
	if ( isAutoFire() && checkTimer(TI_REPEAT) ){
		AutoFireStoredItem(GetEquipmentB());
		SetItemB(repeatingItem);
		Link->InputB = true;
		Waitframe();
		if ( GetEquipmentB() == repeatingItem ) {
			SetItemB(AutoFireStoredItem());
		}
	}
        else { 
		AutoFireStoredItem(GetEquipmentB());
		if ( GetEquipmentB() != AutoFireStoredItem() ) {
			SetItemB(AutoFireStoredItem());
		}
        }
}

//Emergency function to turn boolean off by pressing R.
void setRepeatOff(){
	if ( AUTOFIRE_R_DISABLES && Link->PressR && isAutoFire() ){
		isAutoFire(false);
	}
}