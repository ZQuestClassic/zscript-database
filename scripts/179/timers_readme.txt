//An alternative variant of library for creating and managing timers

//

//Unlike Zoria`s timers.zh it has more streamlined timer status management and it`s easier to setup.
//All timers have "seconds" counter and "Frames"(1/60th of second) counter.  

//

Setup:

1. Import header like any other headers.
2. Global script combining: Put "UpdateTimers();"
   before Waitdraw() and Waitframe() in the main loop your global script.
   and put InitTimers(); into your Init global script.
Headers: std.zh and string.zh.

//Functions//

//GLOBAL

void InitTimers()
//Timers initialization routine. Put this into your "init" global script. 

void UpdateTimers()
//Main timer update function. Must be placed in before Waitdraw() command in the main loop of global script.

UpdateTimer(int timer, int speed)
//Local version of timer updating. Best used in FFC scripts.
//Make sure that timer is not global (GlobalTimer[timer] is set to FALSE) otherwise the timer will be 
//updated twice per frame, which will mess up with timer speed.
//"speed" controls the speed of timer running.

//TIMER MANIPULATION

void SetTimer (int timer, int Seconds, int Frames)
//Sets the timer, regardless of it`s previous state. Seconds and frames are set separately.

void AddToTimer(int timer, int Seconds, int Frames, bool AllowNegatives)
//Adds or removes value (seconds and fractions of seconds) from timer.
//Use negative values to reduce time. "AllowNegative" boolean, when
//set to "false" prevents timer from going into negative value.

void FastForwardTimer(int timer, int Seconds, int Frames)
//Fast-forwards timer by adding or removing value/s, depending on timer state.

void RewindTimer(int timer, int Seconds, int Frames)
//Rewinds timer by adding or removing value/s, depending on timer state.

void StartCountingUp(int timer)
//Launch timer counting up.

void StartCountingDown(int timer)
//Launch timer countdown.

void PauseTimer(int timer)
//Pauses the given timer.

void ResumeTimer(int timer)
//Resumes the paused timer.

void StopTimer(int timer)
//Stops and resets the given timer.

void DetonateInstantly(int timer, bool detonatepaused)
//Rigs the given countdown timer, so the desired events will be triggered instantly, as if timer hits 0.
//Just like cutting wrong wire on time bomb causing it to explode immediately.
//"detonatepaused", if set to TRUE, also allow detonation of paused timer.

void SetMaxCountdowntimer(int timer, int Seconds, int Frames)
//Use this function to prevent countdown timer from going above the desired value.
//Just like preventing fuel tank from overfilling with added fuel.

//TIMER EVALUATION

bool TimerIsRunning (int timer)
//Returns TRUE if the timer is running

bool TimerIsPaused (int timer)
//Returns TRUE if the timer is paused.

bool TimerReachValue(int timer, int Seconds, int Frames)
//Returns TRUE if timer has reached specific threshold, depending on it`s state.

//DRAWING

void DrawTimer(int layer, int x, int y, int font, int color, int timer, bool drawframes, bool drawminutes, int opacity)
//Draws the given timer onto screen. Format is similar to Draw functions.
//"layer", "x", "y", "font", "color", & "opacity" arguments are similar to other drawing functions.
//"DrawFrames" boolean draws fractions of second, if TRUE
//"DrawMinutes" boolean converts timer into "mmm:ss:(ff)" format from "ssssss:(ff)".