///////////////////////////////////
//Alternative Timers Library v1.1//
///////////////////////////////////

//import "std.zh"
//import "string.zh"

//These constants determine timer states. Don`t change them.
const int TIMER_STATE_STOPPED = 0; //Timer is stopped
const int TIMER_STATE_COUNTING_UP = 1; //Timer is counting up
const int TIMER_STATE_COUNTING_DOWN = 2; //Timer is counting down
const int TIMER_STATE_PAUSED_COUNTUP = 3; //The timer counting up is paused
const int TIMER_STATE_HIT_ZERO = 4; //The countdown timer has just recently hit 0
const int TIMER_STATE_PAUSED_COUNTDOWN = 5; //The timer counting down is paused

//Main timer global arrays. Expand as you want. But make sure, that all 4 arrays have the same size.
int TimerSeconds[5];
int TimerFrames[5];
int TimerState[5];
//You can set any of booleans of this array to "FALSE" to prevent UpdateTimers() command from affecting specific timers.
bool GlobalTimer[5];

//Example of how the global script should be combined with other global scripts.
global script Timers{
	void run(){
		while (true){
			UpdateTimers();
			Waitdraw();
			Waitframe();
		}
	}
}

//Timers initialization routine. Put this into your "init" global script. 
void InitTimers(){
	int numtimers = SizeOfArray(TimerSeconds);
	for (int i=0; i<=numtimers; i++){
		TimerSeconds[i]=0;
		TimerFrames[i]=0;
		TimerState[i]=0;
		GlobalTimer[i]=true;
	}
}

//Main timer update function. Must be placed in before Waitdraw() command in the main loop
//of global script.
void UpdateTimers(){
	int NumTimers = SizeOfArray(TimerState);
	for (int i=0; i<NumTimers; i++){
		if (!GlobalTimer[i]) continue;
		if (TimerState[i]==TIMER_STATE_STOPPED) continue;
		if (TimerState[i]==TIMER_STATE_PAUSED_COUNTUP) continue;
		if (TimerState[i]==TIMER_STATE_PAUSED_COUNTDOWN) continue;
		if (TimerState[i]==TIMER_STATE_HIT_ZERO){
			TimerSeconds[i]=0;
			TimerFrames[i]=0;
			TimerState[i]=TIMER_STATE_STOPPED;
		}
		if (TimerState[i]==TIMER_STATE_COUNTING_UP){
			TimerFrames[i]++;
			if (TimerFrames[i]>=60){
				TimerSeconds[i]++;
				TimerFrames[i]=0;
			}
		}
		if (TimerState[i]==TIMER_STATE_COUNTING_DOWN){
			TimerFrames[i]--;
			if (TimerFrames[i]<0){
					TimerSeconds[i]--;
					TimerFrames[i]=59;
			}
			if (TimerSeconds[i]<0){
					TimerFrames[i] = 0;
					TimerSeconds[i] = 0;
					TimerState[i]=TIMER_STATE_HIT_ZERO;
			}
		}
	}
}

//Local version of timer updating. Best used in FFC scripts, if you don`t want to combine global scripts.
void UpdateTimer(int timer, int speed){
	if (TimerState[timer]==TIMER_STATE_STOPPED) return;
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTUP) return;
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTDOWN) return;
	if (TimerState[timer]==TIMER_STATE_HIT_ZERO){
		TimerSeconds[timer]=0;
		TimerFrames[timer]=0;
		TimerState[timer]=TIMER_STATE_STOPPED;
	}
	if (TimerState[timer]==TIMER_STATE_COUNTING_UP){
		TimerFrames[timer]+=speed;
		if (TimerFrames[timer]>=60){
			TimerSeconds[timer]++;
			TimerFrames[timer]=0;
		}
	}
	if (TimerState[timer]==TIMER_STATE_COUNTING_DOWN){
		TimerFrames[timer]-=speed;
		if (TimerFrames[timer]<0){
				TimerSeconds[timer]--;
				TimerFrames[timer]=59;
		}
		if (TimerSeconds[timer]<0){
				TimerFrames[timer] = 0;
				TimerSeconds[timer] = 0;
				TimerState[timer]=TIMER_STATE_HIT_ZERO;
		}
	}
}

//Sets the timer, regardless of it`s previous state.
void SetTimer (int timer, int Seconds, int Frames){
	TimerFrames[timer] = Frames;
	TimerSeconds[timer] = Seconds;
}

//Adds or removes value (seconds and fractions of seconds) from timer.
//Use negative values to reduce time. "AllowNegative" boolean, when
//set to "false" prevents timer from going into negative value.
void AddToTimer(int timer, int Seconds, int Frames, bool AllowNegatives){
	TimerFrames[timer] += Frames;
	TimerSeconds[timer] += Seconds;
	if (TimerFrames[timer]>= 60){
		while (TimerFrames[timer]>= 60){
			TimerSeconds[timer] ++;
			TimerFrames[timer] -= 60; 
		}
	}
	if (TimerFrames[timer]<= 0){
		while (TimerFrames[timer]<= 60){
			TimerSeconds[timer] --;
			TimerFrames[timer] += 60; 
		}
	}
	if (!AllowNegatives){
			if (TimerSeconds[timer]<= 0)TimerSeconds[timer] = 0;
	}
}

//Fast-forwards timer by adding or removing value/s, depending on timer state.
void FastForwardTimer(int timer, int Seconds, int Frames){
	if (TimerState[timer]==TIMER_STATE_COUNTING_UP) AddToTimer(timer, Seconds, Frames, false);
	if (TimerState[timer]==TIMER_STATE_COUNTING_DOWN) AddToTimer(timer, (-(Seconds)),(-(Frames)), false);
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTUP) AddToTimer(timer, Seconds, Frames, false);
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTDOWN) AddToTimer(timer, (-(Seconds)),(-(Frames)), false);
}

//Rewinds timer by adding or removing value/s, depending on timer state.
void RewindTimer(int timer, int Seconds, int Frames){
	if (TimerState[timer]==TIMER_STATE_COUNTING_UP) AddToTimer(timer, (-(Seconds)),(-(Frames)), false);
	if (TimerState[timer]==TIMER_STATE_COUNTING_DOWN) AddToTimer(timer, Seconds, Frames, false);
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTUP) AddToTimer(timer, (-(Seconds)),(-(Frames)), false);
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTDOWN) AddToTimer(timer, Seconds, Frames, false);
}

//Launch timer counting up. 
void StartCountingUp(int timer){
	TimerState[timer] = TIMER_STATE_COUNTING_UP;
}

//Launch timer countdown.
void StartCountingDown(int timer){
	TimerState[timer] = TIMER_STATE_COUNTING_DOWN;
}

//Pauses the given timer.
void PauseTimer(int timer){
	if (TimerState[timer]==TIMER_STATE_COUNTING_UP) TimerState[timer] = TIMER_STATE_PAUSED_COUNTUP;
	if (TimerState[timer]==TIMER_STATE_COUNTING_DOWN) TimerState[timer] = TIMER_STATE_PAUSED_COUNTDOWN;
}

//Resumes the paused timer.
void ResumeTimer(int timer){
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTUP) TimerState[timer] = TIMER_STATE_COUNTING_UP;
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTDOWN) TimerState[timer] = TIMER_STATE_COUNTING_DOWN;
}

//Stops and resets the given timer.
void StopTimer(int timer){
	TimerFrames[timer] = 0;
	TimerSeconds[timer] = 0;
	TimerState[timer] = TIMER_STATE_STOPPED;
}

//Sets countdown timer, so the desired events will be triggered instantly, as if timer hits 0.
//Just like cutting wrong wire on time bomb causing it to explode immediately.
//"detonatepaused", if set to TRUE, also allow detonation of paused timer.
void DetonateInstantly(int timer, bool detonatepaused){
	if ((TimerState[timer]==TIMER_STATE_PAUSED_COUNTDOWN)&&(!detonatepaused)) return;
	if (TimerState[timer] != TIMER_STATE_COUNTING_DOWN) return;
	TimerFrames[timer] = 0;
	TimerSeconds[timer] = 0;
}

//Use this function to prevent countdown timer from going beyond desired value.
//Just like preventing fuel tank from overfilling with added fuel.
void SetMaxCountdowntimer(int timer, int Seconds, int Frames){
	if ((TimerState[timer] != TIMER_STATE_COUNTING_DOWN)&&
		(TimerState[timer]!=TIMER_STATE_PAUSED_COUNTDOWN)) return;
	if(TimerSeconds[timer] > Seconds){
		TimerSeconds[timer] = Seconds;
		TimerFrames [timer] = Frames;
	}
	else if (TimerSeconds[timer] == Seconds){
		if (TimerFrames [timer] > Frames) TimerFrames [timer] = Frames;
	}
}

//Returns TRUE if the timer is still active (either running or paused).
bool TimerIsActive(int timer){
	if (TimerState[timer]==TIMER_STATE_STOPPED) return false;
	return true;
}

//Returns TRUE if the timer is running.
bool TimerIsRunning (int timer){
	if (TimerState[timer]==TIMER_STATE_COUNTING_UP) return true;
	if (TimerState[timer]==TIMER_STATE_COUNTING_DOWN) return true;
	return false;
}

//Returns TRUE if the timer is paused.
bool TimerIsPaused (int timer){
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTUP) return true;
	if (TimerState[timer]==TIMER_STATE_PAUSED_COUNTDOWN) return true;
	return false;
}

//Returns TRUE if timer has reached specific threshold, depending on it`s state.
bool TimerReachValue(int timer, int Seconds, int Frames){
	if (TimerState[timer]==TIMER_STATE_COUNTING_UP){
		if(TimerSeconds[timer] > Seconds) return true;
		if(TimerSeconds[timer] < Seconds) return false;
		if(TimerFrames [timer] >= Frames) return true;
		return false;
	}
	if (TimerState[timer]==TIMER_STATE_COUNTING_DOWN){
		if(TimerSeconds[timer] < Seconds) return true;
		if(TimerSeconds[timer] > Seconds) return false;
		if(TimerFrames [timer] <= Frames) return true;
		return false;
	}
	return false;
}

//Draws the given timer onto screen. Format is similar to Draw functions.
//"layer", "x", "y", "font", "color", & "opacity" arguments are similar to other drawing functions.
//"DrawFrames" boolean draws fractions of second, if TRUE
//"DrawMinutes" boolean converts timer into "mmm:ss:(ff)" format from "ssssss:(ff)".
void DrawTimer(int layer, int x, int y, int font, int color, int timer, bool drawframes, bool drawminutes, int opacity){
	int frames = TimerFrames[timer];
	int seconds = TimerSeconds[timer];
	int curseconds = seconds%60;
	int minutes = Floor(seconds/60);
	int source[24] = "%d:0%d:0%d";
	int string[256];
	if (drawframes){
		if (drawminutes){
			if (curseconds>9) remnchr(source, 3, 1);
			if (frames>9){
				int remchar = 7;
				if (curseconds>9) remchar = 6;
				remnchr(source, remchar, 1);
			}
			sprintf(string, source, minutes, curseconds, frames);
		}
		else{
			int newstr[] ="%d:0%d";
			if (frames>9) remnchr(newstr, 3, 1); 
			strcpy(source, newstr);
			sprintf(string, source, seconds, frames);
		}
	}
	else {
		if (drawminutes){
			int newstr[] ="%d:0%d";
			if (curseconds>9) remnchr(newstr, 3, 1); 
			strcpy(source, newstr);
			sprintf(string, source, minutes, curseconds);
		}
		else{
			int newstr[] ="%d"; 
			strcpy(source, newstr);
			sprintf(string, source, seconds);
		}
	}
	Screen->DrawString(layer, x, y, font, color, -1, TF_NORMAL, string, opacity);
}

//Test script. Creates generic time bomb. When timer expires, bomb explodes.
//Stepping on bomb results in an instant explosion. 
//Set the combo to look like bomb.
// D0: "Seconds" part of init timer.
// D1: "Frames" part of init timer.
// D2: Damage dealt to Link if he was too close to bomb, when it goes boom.
ffc script TimerTest{
	void run(int seconds, int frames, int damage){
		if (!TimerIsActive(0))SetTimer (0, seconds, frames);
		StartCountingDown(0);
		while (true){
			if (LinkCollision(this)) DetonateInstantly(0, true);
			if(TimerState[0]==TIMER_STATE_HIT_ZERO){ //KA-BOOM!!
				eweapon explosion = Screen->CreateEWeapon(EW_BOMBBLAST);
				explosion->X=this->X;
				explosion->Y=this->Y;
				explosion->Damage = damage;
				if (damage==0) explosion->CollDetection=false;
				this->Data=0;
				Quit();
			}
			int drawx = this->X - 16;
			int drawy = this->Y - 16;
			DrawTimer(0, drawx, drawy, 0, 1, 0, true, true, OP_OPAQUE);
			Waitframe();
		}
	}
}