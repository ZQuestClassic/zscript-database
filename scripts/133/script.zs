///////////////////////////////
/// Timers.zh | v1.5        ///
/// 24th September, 2014    ///
////////////////////////////////////////////
/// Created, and maintained by: ZoriaRPG ///
////////////////////////////////////////////


//Array to hold timer values.  The index size of each of all of the following arrays MUST be identical.

int Timers[10]={0,0,0,0,0,0,0,0,0,0};
//Expand as needed.

bool TimersRunning[10]={false,false,false,false,false,false,false,false,false,false};
//Expand as needed.

//int TimersStatus[10]={0,0,0,0,0,0,0,0,0,0}; 
//Reserved for future use. (0 = stopped, 1 = running, 2 = paused).


//Timer Type Constants

//Set up constants for your timers; remember that the array index starts at '0'.

const int TI_MYTIMER_1 = 0;
const int TI_MYTIMER_2 = 1;
const int TI_MYTIMER_3 = 2;
const int TI_MYTIMER_4 = 3;
const int TI_MYTIMER_5 = 4;
const int TI_MYTIMER_6 = 5;
const int TI_MYTIMER_7 = 6;
const int TI_MYTIMER_8 = 7;
const int TI_MYTIMER_9 = 8;
const int TI_MYTIMER_0 = 9;


//Timer Standard Duration Values

const int TD_TENTH_SECOND = 6;
const int TD_QUARTER_SECOND = 15;
const int TD_HALF_SECOND = 30;
const int TD_ONE_SECOND = 60;
const int TD_FIVE_SECONDS = 300;
const int TD_SIX_SECONDS = 360;
const int TD_TEN_SECONDS = 600;
const int TD_FIFTEEN_SECONDS = 900;
const int TD_THIRTY_SECONDS = 1800;
const int TD_1_MINUTE = 3600;
const int TD_2_MINUTES = 7200;
const int TD_3_MINUTES = 10800;
const int TD_4_MINUTES = 14400;
const int TD_5_MINUTES = 18000;

////////////////////////////////////////
//Initialisation and Value Manipulation


void initTimer(int timer, int value){
    if ( Timers[timer] <= 0 ) {
        Timers[timer] = value;
    }
    if ( TimersRunning[timer] == false ) {
        TimersRunning[timer] = true;
    }
}


//Initialises a timer, settign its value, and starting it. If the timer value is not zero, this will fail.

void initTimer(int timer, int value, bool forced){
    if ( forced == false ) {
        if ( Timers[timer] <= 0 ) {
            Timers[timer] = value;
        }
    }
    else if ( forced == true ) {
        Timers[timer] = value;
    }
    if ( TimersRunning[timer] == false ) {
        TimersRunning[timer] = true;
    }
}

//Initialises a timer, settign its value, and starting it. Can force-set a value.

void setTimer(int timer, int value){
    if ( Timers[timer] <= 0 ) {
        Timers[timer] = value;
    }
}

//Sets the value of a specific timer, if it is zero. 
//Used to initialise a timer, and to re-set it onced its count reaches zero. 

void setTimer(int timer, int value, bool forced){
    if ( forced == false ) {
        if ( Timers[timer] <= 0 ) {
            Timers[timer] = value;
        }
    }
    else if ( forced == true ) {
        Timers[timer] = value;
    }
}

//Sets the value of a specific timer, if it is zero. May be forced to set any value, even if the timer is not zero.



void startTimer(int timer){
    TimersRunning[timer] = true;
}

//Starts a timer, without setting, or changing its value.

void resumeTimer(int timer){
    TimersRunning[timer] = true;
}

//Resumes a suspended timer; identical to startTimer() in all but name.


void suspendTimer(int timer){
    TimersRunning[timer]= false;
}

//Suspends (pauses) a timmer. A suspended timer will not lose value with frame counts. 

////////////////////////////////////
///Timer numeric value manipulation.

void reduceTimer(int timer){
    if (TimersRunning[timer] == true ){
        if ( Timers[timer] > 0 ) {
            Timers[timer] -= 1;
        }
    }
}

//Reduce a specific, running timer by '1'. Use before Waitdraw();

void reduceTimer(int timer, int value){
    if (TimersRunning[timer] == true ){
        if ( Timers[timer] > 0 ) {
            Timers[timer] -= value;
        }
    }
}

//Reduce a specific, running timer by 'value'. Use before Waitdraw();



void clearTimer(int timer){
    Timers[timer] = 0;
    TimersRunning[timer] = false;
}

//Resets the value of a timer (to zero), and disables it. The opposite of initTimer.


void changeTimer(int timer, int value){
    Timers[timer] = value;
}

//Changs the value of a timer to any arbitrary value, with no regard to its present value.


void increaseTimer(int timer, int value){
    Timers[timer] += value;
}

//Adds an arbitrary amount to a timer

void shrinkTimer(int timer, int value){
    Timers[timer] -= value;
    int timerTotal = Timers[timer];
    if ( timerTotal == 0 ) {
        Timers[timer] = 0;
    }
}

//Reduces a timer by an arbitrary amount, even if it is not running. If the reduction would cause the timer to be a negative value, this sets its value to '0'.

void shrinkTimer(int timer, int value, bool ignore){
    Timers[timer] -= value;
    if ( ignore == false ) {
        int timerTotal = Timers[timer];
        if ( timerTotal == 0 ) {
            Timers[timer] = 0;
        }
    }
}

//.Reduces a timer by an arbitrary amount, and allows for a ignoring negative values. 




//////////////////////////////////////
//Check value and operation of timers.


//Values of Timer

int returnTimer(int timer){
    int value = Timers[timer];
    return value;
}

//Returns the value of timer as an integer. 
//Useful for comparisons, ro events that occur at specific conts of a timer. 

bool checkTimer(int timer){
    if ( Timers[timer] <= 1 ) {
        return true;
    }
    else {
        return false;
    }
}

//Boolean returns true when timer reaches '1', or less.

bool checkTimer(int timer, bool precise){
    if ( precise == false ) {
        if ( Timers[timer] <= 1 ) {
            return true;
        }
        else {
            return false;
        }
    }
    else if ( precise == true ) {
        if ( Timers[timer] == 0 ) {
            return true;
        }
        else {
            return false;
        }
    }
}

//Boolean returns true when timer reaches 1, or less. May be forced to be sensitive to exactly zero.



bool zeroTimer(int timer){
    if ( Timers[timer] == 0 ) {
        return true;
    }
    else {
        return false;
    }
}

//Boolean returns true when timer reaches exactly '0'.

bool checkTimer(int timer, int value){
    if ( Timers[timer] == value ) {
        return true;
    }
    else {
        return false;
    }
}

//Boolean returns true when timer reaches a specific value.

bool checkTimer(int timer, int value, bool orLess){
    if ( orLess == true ) {
        if ( Timers[timer] <= value ) {
            return true;
        }
        else {
            return false;
        }
    }
    else if ( orLess == false ) {
        if ( Timers[timer] == value ) {
            return true;
        }
        else {
            return false;
        }
    }

}

//Boolean returns true when timer reaches a specific value, or less.




///Booleans for Timer Status

bool timerRunning(int timer){
    bool value = TimersRunning[timer];
    return value;
}

//Returns true is a timer is running, false if 'tisn't.

bool timerOn(int timer){
    bool value = TimersRunning[timer];
    return value;
}

//Returns true is a timer IS running (ON), false if 'tisn't.

bool timerOff(int timer){
    bool tOff;
    bool value = TimersRunning[timer];
    if ( value == false ) { 
        tOff = true;
    }
    else {
        tOff = false;
    }
    return tOff;
}

//Returns true is a timer is NOT running (OFF), false if 'tis.

////////////////////////
//Multiple Timer Actions

///////////////////////////////////
//Reduce - Decrease Multiple Timers

void decreaseAllTimers(int value){
    int range = SizeOfArray(Timers);
    int presentValue;
    for ( int i = 0; 1 < range; i++) {
        if ( Timers[i] > 0 ) {
            Timers[i] -= value;
        }
    }
}

//Reduces all timers by value specified; will not reduce a timer below zero.

void decreaseAllTimers(int value, bool allowNegative){
    int range = SizeOfArray(Timers);
    int presentValue;
    for ( int i = 0; 1 < range; i++) {
        Timers[i] -= value;
        presentValue = Timers[i];
        if ( allowNegative == false && presentValue < 0 ) {
                Timers[i] = 0;
        }
    }
}

//Reduces all timers, and allows for values below zero.

void decreaseRunningTimers(int amount){
    int range = SizeOfArray(Timers);
    bool active;
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == true ) {
            if ( Timers[i] > 0 ) {
                Timers[i] -= amount;
            }
        }
    }
}

//Decrease RUNNING timers by arbitrary amount. This will not permnit a timer to drop below zero.


void decreaseRunningTimers(int amount, bool allowNegative){
    int range = SizeOfArray(Timers);
    bool active;
    int presentValue;
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == true ) {
            Timers[i] -= amount;
            presentValue = Timers[i];
            if ( allowNegative == false && presentValue < 0 ) {
                Timers[i] = 0;
            }
        }
    }
}

//Decrease RUNNING timers by arbitrary amount. This allows you to permit timers to drop below zero.


void decreaseRangeOfTimers(int min, int max, int value){
    for ( int i = min; i < max; i++ ){
        if ( Timers[i] > 0 ) {
            Timers[i] -= value;
        }
    }
}

//Reduces range of timers, from timer min, to timer max, by amount value.

void decreaseRangeOfTimers(int min, int max, int value, bool allowNegative){
    int presentValue;
    for ( int i = min; i < max; i++ ){
        Timers[i] -= value;
        presentValue = Timers[i];
        if ( allowNegative == false && presentValue < 0 ) {
            Timers[i] = 0;
        }
    }
}

//Reduces range of timers, from timer min, to timer max, by amount value, with option to permit negative values.

////////////////////////////
//Increase Multiple Timers

void increaseAllTimers(int value){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        if ( Timers[i] > 0 ) {
            Timers[i] += value;
        }
    }
}

//Increases all timers by arbitrary amount.

void increaseRunningTimers(int amount){
    int range = SizeOfArray(Timers);
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == true ) {
            Timers[i] += amount;
        }
    }
}

//Increase all RUNNING timers by an arbitrary amount.

void increaseRangeOfTimers(int min, int max, int value){
    for ( int i = min; i < max; i++ ){
        if ( Timers[i] > 0 ) {
            Timers[i] += value;
        }
    }
}

//Increases range of timers, from timer min, to timer max, by amount value.

////////////////
//Clear Commands

void clearAllTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        Timers[i] = 0;
    }
}

//Clears all timers back to a value of zero.

void clearRunningTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == true ) {
            Timers[i] = 0;
        }
    }
}

//Clears all RUNNING timers, back to a value of zero.


void clearSuspendedTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == false ) {
            Timers[i] = 0;
        }
    }
}

//Clears all SUSPENDED timers, back to a value of zero.

void clearPausedTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == false ) {
            Timers[i] = 0;
        }
    }
}

//Clears all PAUSED timers, back to a value of zero.

void clearStoppedTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == false ) {
            Timers[i] = 0;
        }
    }
}

//Clears all STOPPED timers, back to a value of zero.

void clearRangeOfTimers(int min, int max){
    for ( int i = min; i < max; i++ ){
        if ( Timers[i] > 0 ) {
            Timers[i] = 0;
        }
    }
}

//Clears specific range of timers, from timer min,to timer max, back to a value of zero

////////////////
///Set Commands

void setAllTimers(int value){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        Timers[i] = value;
    }
}

//Sets all timers to an arbitrary amount.

void setRunningTimers(int amount){
    int range = SizeOfArray(Timers);
    for ( int i = 0; i < range; i++ ){
        if ( TimersRunning[i] == true ) {
            Timers[i] = amount;
        }
    }
}

//Sets all RUNNING timers, to an arbitrary value.

void setRangeOfTimers(int min, int max, int value){
    for ( int i = min; i < max; i++ ){
        if ( Timers[i] > 0 ) {
            Timers[i] = value;
        }
    }
}

//Sets specific range of timers, to an arbitrary value.

////////////////////////////////
//Multiple Timer Status Commands


void startAllTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        if ( TimersRunning[i] == false ) {
            TimersRunning[i] = true;
        }
    }
}

//Starts all timers - Call this if you have set multiple timers individually.


void startRangeOfimers(int min, int max){
    for ( int i = min; 1 < max; i++) {
        if ( TimersRunning[i] == false ) {
            TimersRunning[i] = true;
        }
    }
}

//Starts range of timers, from timer min, to timer max.


void suspendAllTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        if ( TimersRunning[i] == true ) {
            TimersRunning[i] = false;
        }
    }
}

//Suspends all timers.

void suspendRangeOfTimers(int min, int max){
    for ( int i = min; 1 < max; i++) {
        if ( TimersRunning[i] == true ) {
            TimersRunning[i] = false;
        }
    }
}

//Suspends range of timers, from timer min, to timer max.

void stopAllTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        if ( TimersRunning[i] == true ) {
            TimersRunning[i] = false;
        }
    }
}

//Stops all timers. Reserved for future expansion.

void stopRangeOfTimers(int min, int max){
    for ( int i = min; 1 < max; i++) {
        if ( TimersRunning[i] == true ) {
            TimersRunning[i] = false;
        }
    }
}

//Stops range of timers, from timer min, to timer max. Reserved for future expansion,

void resumeAllTimers(){
    int range = SizeOfArray(Timers);
    for ( int i = 0; 1 < range; i++) {
        if ( TimersRunning[i] == false ) {
            TimersRunning[i] = true;
        }
    }
}

//Resumes all timers. Reserved for future use with TimersPaused[] array.

void resumeRangeOfTimers(int min, int max){
    for ( int i = min; 1 < max; i++) {
        if ( TimersRunning[i] == false ) {
            TimersRunning[i] = true;
        }
    }
}

//Resumes range of timers, from timer min, to timer max.





/////////
//Scripts

///////////////////////
//Global Script Example

global script activeSample{
    void run(){
    int swap;
        while(true){
            
            initTimer(TI_MYTIMER_1,( (TD_ONE_SECOND * 3) + TD_HALF_SECOND ) );
            reduceTimer(TI_MYTIMER_1,1);
            Waitdraw();
            if ( timerOn(TI_MYTIMER_1) && Link->PressR ) {
                suspendTimer(TI_MYTIMER_1);
            }
            else if ( timerOff(TI_MYTIMER_1)  && Link->PressR ) {
                resumeTimer(TI_MYTIMER_1);
            }
            //Trace(returnTimer(TI_MYTIMER_1)); //Prints vale of timer TI_MYTIMER_1 to allegro.log
            //TraceB(timerRunning(TI_MYTIMER_1)); //Check timer status of TI_MYTIMER_1.
            Waitframe();
        }
    }
}

//Copyright (C) 2014 TMGS
//Licensed Under: GLPL v2 (Read: https://www.gnu.org/licenses/old-licenses/lgpl-2.0.html)