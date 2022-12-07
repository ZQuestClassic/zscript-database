const int DAYNIGHT_USE_SYSTEM_CLOCK = 0; //Set to 1 to use the system clock instead of a simulated one

const int DMF_TIME_CAN_ADVANCE = DMF_SCRIPT1; //DMap flag used to flag DMaps where time advances

//Hour to start the clock on
const int DAYNIGHT_STARTING_HOUR = 8;

//Timing for sunset transitions
const int DAYNIGHT_SUNSET_START_HOUR = 16;
const int DAYNIGHT_SUNSET_MID_HOUR = 18;
const int DAYNIGHT_SUNSET_END_HOUR = 20;

//Timing for sunrise transitions
const int DAYNIGHT_SUNRISE_START_HOUR = 4;
const int DAYNIGHT_SUNRISE_MID_HOUR = 6;
const int DAYNIGHT_SUNRISE_END_HOUR = 8;

//Timing for midi change
//The mid time needs to be set because otherwise a night period of >12 hours would break
const int DAYNIGHT_MIDI_NIGHT_START_HOUR = 18;
const int DAYNIGHT_MIDI_NIGHT_MID_HOUR = 24;
const int DAYNIGHT_MIDI_NIGHT_END_HOUR = 6;

//Number of transitional palettes for the sunrise and sunset transitions. Negative numbers mean the palettes with cycle backwards
const int SUNSET_START_PALETTES = 7;
const int SUNSET_END_PALETTES = 7;

const int SUNRISE_START_PALETTES = -7;
const int SUNRISE_END_PALETTES = -7; 

//How often to increment the clock in frames
const int DAYNIGHT_TIME_INCREMENT_FRAMES = 5;
//How long in seconds, minutes, and hours to increment it by
const int DAYNIGHT_TIME_INCREMENT_SECONDS = 0;
const int DAYNIGHT_TIME_INCREMENT_MINUTES = 1;
const int DAYNIGHT_TIME_INCREMENT_HOURS = 0;

//Position for the timer onscreen (Top of the subscreen is at Y = -56)
const int DAYNIGHT_DRAW_CLOCK = 1; 
const int DAYNIGHT_CLOCK_LAYER = 7;
const int DAYNIGHT_CLOCK_X = 88;
const int DAYNIGHT_CLOCK_Y = -56;
const int DAYNIGHT_CLOCK_PLACES = 1; //0 - Hours only, 1 - Hours:Minutes, 2 - Hours:Minutes:Seconds
const int DAYNIGHT_CLOCK_HIDE_AM_PM = 0; //0 - AM and PM are visible, 1 - AM and PM are not visible, 2 - Military time

//Font, colors, and shadow type for drawing the clock
const int FONT_DAYNIGHT_CLOCK = FONT_Z1;
const int C_DAYNIGHT_CLOCK = 0x01;
const int C_DAYNIGHT_CLOCK_SHADOW = 0x0F;
const int SHD_DAYNIGHT_CLOCK_SHADOWTYPE = SHD_NORMAL; 

int DayNight[_DN_START + 512 * _DN_BLOCK];

const int _DN_HOUR = 0;
const int _DN_MINUTE = 1;
const int _DN_SECOND = 2;
const int _DN_FRAMECOUNTER = 3;
const int _DN_FIRSTLOAD = 4;

//Start index of the 2D part of the global array and block size
const int _DN_START = 16;
const int _DN_BLOCK = 8;

const int _DN_DAYPAL = 0;
const int _DN_SUNSETPAL = 1;
const int _DN_NIGHTPAL = 2;
const int _DN_SUNRISEPAL = 3;
const int _DN_MIDIDAY = 4;
const int _DN_MIDINIGHT = 5;
const int _DN_MIDICURRENT = 6;

global script DayNight_Example{
	void run(){
		DayNight_Init();
		while(true){
			DayNight_Update();
			
			Waitdraw();
			Waitframe();
		}
	}
}

void DayNight_Init(){
	unless(DayNight[_DN_FIRSTLOAD]){
		DayNight[_DN_HOUR] = DAYNIGHT_STARTING_HOUR;
		
		DayNight[_DN_FIRSTLOAD] = 1;
	}
}

void DayNight_Update(){
	int i;
	int tmpDMap;
	
	if(Game->DMapFlags[Game->GetCurDMap()]&DMF_TIME_CAN_ADVANCE){
		if(DAYNIGHT_USE_SYSTEM_CLOCK){
			DayNight[_DN_HOUR] = GetSystemTime(RTC_HOUR);
			DayNight[_DN_MINUTE] = GetSystemTime(RTC_MINUTE);
			DayNight[_DN_SECOND] = GetSystemTime(RTC_SECOND);
		}
		else{
			++DayNight[_DN_FRAMECOUNTER];
			if(DayNight[_DN_FRAMECOUNTER]>=DAYNIGHT_TIME_INCREMENT_FRAMES){
				DayNight[_DN_HOUR] += DAYNIGHT_TIME_INCREMENT_HOURS;
				DayNight[_DN_MINUTE] += DAYNIGHT_TIME_INCREMENT_MINUTES;
				DayNight[_DN_SECOND] += DAYNIGHT_TIME_INCREMENT_SECONDS;
				
				while(DayNight[_DN_SECOND]>=60){
					DayNight[_DN_SECOND] -= 60;
					++DayNight[_DN_MINUTE];
				}
				while(DayNight[_DN_MINUTE]>=60){
					DayNight[_DN_MINUTE] -= 60;
					++DayNight[_DN_HOUR];
				}
				while(DayNight[_DN_HOUR]>=25){
					DayNight[_DN_HOUR] -= 24;
				}
				
				DayNight[_DN_FRAMECOUNTER] = 0;
			}
		}
	}


	//Update the palette for the current DMap
	DayNight_UpdateDMapPalette(Game->GetCurDMap());
	//Also update for side warp and tile warp DMaps
	for(i=0; i<4; ++i){
		tmpDMap = Screen->GetSideWarpDMap(i);
		DayNight_UpdateDMapPalette(tmpDMap);
		tmpDMap = Screen->GetTileWarpDMap(i);
		DayNight_UpdateDMapPalette(tmpDMap);
	}
	
	if(DAYNIGHT_DRAW_CLOCK){
		DayNight_DrawClock();
	}
}

void DayNight_UpdateDMapPalette(int whichDMap){
	int h = DayNight[_DN_HOUR];
	int m = DayNight[_DN_MINUTE];
	int s = DayNight[_DN_SECOND];
	
	int curTime;
	int chunkTime;
	int newPal;
	int newMid;

	int i = _DN_START+_DN_BLOCK*whichDMap;
	//Updating Palettes
	if(DayNight[i+_DN_DAYPAL]){
		//Day
		if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_END_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_START_HOUR, 0, 0)<0){
			newPal = DayNight[i+_DN_DAYPAL];
		}
		//Start of sunset
		else if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_START_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_MID_HOUR, 0, 0)<0){
			if(Abs(SUNSET_START_PALETTES)>0){
				curTime = Abs(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_START_HOUR, 0, 0));
				chunkTime = Abs(DayNight_GetTimeDifference(DAYNIGHT_SUNSET_START_HOUR, 0, 0, DAYNIGHT_SUNSET_MID_HOUR, 0, 0))/(Abs(SUNSET_START_PALETTES)+1);
				newPal = DayNight[i+_DN_DAYPAL]+Sign(SUNSET_START_PALETTES)*Floor(curTime/chunkTime);
			}
			else{
				newPal = DayNight[i+_DN_SUNSETPAL];
			}
		}
		//End of sunset
		else if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_MID_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_END_HOUR, 0, 0)<0){
			if(Abs(SUNSET_END_PALETTES)>0){
				curTime = Abs(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_MID_HOUR, 0, 0));
				chunkTime = Abs(DayNight_GetTimeDifference(DAYNIGHT_SUNSET_MID_HOUR, 0, 0, DAYNIGHT_SUNSET_END_HOUR, 0, 0))/(Abs(SUNSET_END_PALETTES)+1);
				newPal = DayNight[i+_DN_SUNSETPAL]+Sign(SUNSET_END_PALETTES)*Floor(curTime/chunkTime);
			}
			else{
				newPal = DayNight[i+_DN_SUNSETPAL];
			}
		}
		//Night
		else if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNSET_END_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_START_HOUR, 0, 0)<0){
			newPal = DayNight[i+_DN_NIGHTPAL];
		}
		//Start of sunrise
		else if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_START_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_MID_HOUR, 0, 0)<0){
			if(Abs(SUNRISE_START_PALETTES)>0){
				curTime = Abs(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_START_HOUR, 0, 0));
				chunkTime = Abs(DayNight_GetTimeDifference(DAYNIGHT_SUNRISE_START_HOUR, 0, 0, DAYNIGHT_SUNRISE_MID_HOUR, 0, 0))/(Abs(SUNRISE_START_PALETTES)+1);
				newPal = DayNight[i+_DN_NIGHTPAL]+Sign(SUNRISE_START_PALETTES)*Floor(curTime/chunkTime);
			}
			else{
				newPal = DayNight[i+_DN_SUNRISEPAL];
			}
		}
		//End of sunrise
		else if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_MID_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_END_HOUR, 0, 0)<0){
			if(Abs(SUNRISE_END_PALETTES)>0){
				curTime = Abs(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_SUNRISE_MID_HOUR, 0, 0));
				chunkTime = Abs(DayNight_GetTimeDifference(DAYNIGHT_SUNRISE_MID_HOUR, 0, 0, DAYNIGHT_SUNRISE_END_HOUR, 0, 0))/(Abs(SUNRISE_END_PALETTES)+1);
				newPal = DayNight[i+_DN_SUNRISEPAL]+Sign(SUNRISE_END_PALETTES)*Floor(curTime/chunkTime);
			}
			else{
				newPal = DayNight[i+_DN_SUNRISEPAL];
			}
		}
		
		if(newPal!=0){
			if(Game->DMapPalette[whichDMap]!=newPal)
				Game->DMapPalette[whichDMap] = newPal;
		}
	}
	//Updating Music
	if(DayNight[i+_DN_MIDIDAY]!=0){
		//Night
		if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_MIDI_NIGHT_START_HOUR, 0, 0)>0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_MIDI_NIGHT_MID_HOUR, 0, 0)<=0){
			newMid = DayNight[i+_DN_MIDINIGHT];
		}
		else if(DayNight_GetTimeDifference(h, m, s, DAYNIGHT_MIDI_NIGHT_MID_HOUR, 0, 0)>=0&&DayNight_GetTimeDifference(h, m, s, DAYNIGHT_MIDI_NIGHT_END_HOUR, 0, 0)<0){
			newMid = DayNight[i+_DN_MIDINIGHT];
		}
		//Day
		else{
			newMid = DayNight[i+_DN_MIDIDAY];
		}
		
		//If the midi has changed, update things
		if(newMid!=DayNight[i+_DN_MIDICURRENT]){
			//Updating midi
			if(newMid>0){
				Game->DMapMIDI[whichDMap] = newMid;
				if(whichDMap==Game->GetCurDMap())
					Game->PlayMIDI(newMid);
			}
			//Updating enhanced music
			else if(newMid<0){
				int enhMusic = Floor(Abs(newMid));
				int enhTrack = (Abs(newMid)-enhMusic)*10000;
				int buf[256];
				GetMessage(enhMusic, buf);
				Game->SetDMapEnhancedMusic(whichDMap, buf, enhTrack);
				if(Game->GetCurDMap()==whichDMap)
					Game->PlayEnhancedMusic(buf, enhTrack);
			}
			
			DayNight[i+_DN_MIDICURRENT] = newMid;
		}
	}
}

int DayNight_GetTimeDifference(int h1, int m1, int s1, int h2, int m2, int s2){
	--h1; --h2;
	int hDiff = h1-h2;
	int mDiff = m1-m2;
	int sDiff = s1-s2;
	
	while(hDiff>=12)
		hDiff -= 24;
	while(hDiff<=-12)
		hDiff += 24;

	return hDiff*3600+mDiff*60+sDiff;
}

void DayNight_DrawClock(){
	int h = DayNight[_DN_HOUR]-1;
	int m = DayNight[_DN_MINUTE];
	int s = DayNight[_DN_SECOND];
	
	int militaryTimeOffset;
	if(DAYNIGHT_CLOCK_HIDE_AM_PM==2){
		militaryTimeOffset = -1;
		if(h>11)
			militaryTimeOffset = 11;
	}
	
	int clockStr[12] = "00:00:00 AM";
	
	clockStr[0] = '0'+Floor(((h%12)+1+militaryTimeOffset)/10);
	clockStr[1] = '0'+(((h%12)+1+militaryTimeOffset)%10);
	clockStr[3] = '0'+Floor(m/10);
	clockStr[4] = '0'+(m%10);
	clockStr[6] = '0'+Floor(s/10);
	clockStr[7] = '0'+(s%10);
	
	int clrPos;
	switch(DAYNIGHT_CLOCK_PLACES){
		case 2:
			clrPos = 8;
			break;
		case 1: 
			clrPos = 5;
			break;
		default:
			clrPos = 2;
	}
	
	clockStr[clrPos] = ' ';
	if(DAYNIGHT_CLOCK_HIDE_AM_PM)
		clockStr[clrPos] = 0;
	clockStr[clrPos+1] = 'A';
	if((Floor(h/12)>0||h==11)&&h!=23){
		clockStr[clrPos+1] = 'P';
	}
	clockStr[clrPos+2] = 'M';
	clockStr[clrPos+3] = 0;
	
	Screen->DrawString(DAYNIGHT_CLOCK_LAYER, DAYNIGHT_CLOCK_X, DAYNIGHT_CLOCK_Y, FONT_DAYNIGHT_CLOCK, C_DAYNIGHT_CLOCK, -1, TF_NORMAL, clockStr, 128, SHD_DAYNIGHT_CLOCK_SHADOWTYPE, C_DAYNIGHT_CLOCK_SHADOW);
}

//Place this FFC to configure Day/Night settings for the current DMap
//D0: Which DMap to configure settings for (-1 for the current DMap)
//D1: Palette for daytime
//D2: Palette for sunset
//D3: Palette for nighttime
//D4: Palette for sunrise
//D5: Midi for daytime music (negative for enhanced music, using a ZQuest string)
//D6: Midi for nighttime music (negative for enhanced music, using a ZQuest string)
ffc script DayNight_ConfigureDMap{
	void run(int whichDMap, int dayPal, int sunsetPal, int nightPal, int sunrisePal, int dayMusic, int nightMusic){
		if(whichDMap<0)
			whichDMap = Game->GetCurDMap();
		
		int i = _DN_START+_DN_BLOCK*whichDMap;
		
		DayNight[i+_DN_DAYPAL] = dayPal;
		DayNight[i+_DN_SUNSETPAL] = sunrisePal;
		DayNight[i+_DN_NIGHTPAL] = nightPal;
		DayNight[i+_DN_SUNRISEPAL] = sunrisePal;
		DayNight[i+_DN_MIDIDAY] = dayMusic;
		DayNight[i+_DN_MIDINIGHT] = nightMusic;
	}
}

//Place down on a screen to change warps based on the time of day
//D0: If 0, change a tile warp, if 1 change a side warp
//D1: Which warp to change:
//		0 - A
//		1 - B
//		2 - C
//		3 - D
//D2: Starting time for the warp change (decimal places are used for minutes)
//D3: Ending time for the warp change (decimal places are used for minutes)
//D4: Which DMap to warp to (-1 to leave unchanged)
//D5: Which screen to warp to (in decimal) (-1 to leave unchanged)
ffc script DayNight_ChangeWarp{
	void run(int tileOrSideWarp, int warpID, int startTime, int endTime, int whichDMap, int whichScreen){
		warpID = Clamp(warpID, 0, 3);
		
		int startingDMap;
		int startingScreen;
		if(tileOrSideWarp){
			startingDMap = Screen->GetSideWarpDMap(warpID);
			startingScreen = Screen->GetSideWarpScreen(warpID);
		}
		else{
			startingDMap = Screen->GetTileWarpDMap(warpID);
			startingScreen = Screen->GetTileWarpScreen(warpID);
		}
		int newDMap = startingDMap;
		int newScreen = startingScreen;
		if(whichDMap>-1)
			newDMap = whichDMap;
		if(whichScreen>-1)
			newScreen = whichScreen;
		
		int startHour = Clamp(Floor(startTime), 1, 24);
		int startMinute = Clamp(Floor(((startTime-startHour)*100)), 0, 59);
		
		int endHour = Clamp(Floor(endTime), 1, 24);
		int endMinute = Clamp(Floor(((endTime-endHour)*100)), 0, 59);
		
		bool useNew;
		bool wasNew;
		
		int h; int m; int s;
		while(true){
			h = DayNight[_DN_HOUR];
			m = DayNight[_DN_MINUTE];
			s = DayNight[_DN_SECOND];
			if(DayNight_GetTimeDifference(h, m, s, startHour, startMinute, 0)>0&&DayNight_GetTimeDifference(h, m, s, endHour, endMinute, 0)<0){
				useNew = true;
			}
			else{
				useNew = false;
			}
			
			if(useNew&&!wasNew){
				if(tileOrSideWarp){
					Screen->SetSideWarp(warpID, newScreen, newDMap, Screen->GetSideWarpType(warpID));
				}
				else{
					Screen->SetTileWarp(warpID, newScreen, newDMap, Screen->GetTileWarpType(warpID));
				}
				wasNew = true;
			}
			else if(!useNew&&wasNew){
				if(tileOrSideWarp){
					Screen->SetSideWarp(warpID, startingScreen, startingDMap, Screen->GetSideWarpType(warpID));
				}
				else{
					Screen->SetTileWarp(warpID, startingScreen, startingDMap, Screen->GetTileWarpType(warpID));
				}
				wasNew = false;
			}
			
			Waitframe();
		}
	}
}

//Place down on a screen to trigger screen secrets based on the time of day
//D0: Starting time for the secret (decimal places are used for minutes)
//D1: Ending time for the secret (decimal places are used for minutes)
//D2: Set to 1 if the secret is permanent
//D3: Sound to play when the secret triggers
ffc script DayNight_TriggerSecrets{
	void run(int startTime, int endTime, int perm, int sfx){
		int h = DayNight[_DN_HOUR];
		int m = DayNight[_DN_MINUTE];
		int s = DayNight[_DN_SECOND];
		
		int startHour = Clamp(Floor(startTime), 1, 24);
		int startMinute = Clamp(Floor(((startTime-startHour)*100)), 0, 59);
		
		int endHour = Clamp(Floor(endTime), 1, 24);
		int endMinute = Clamp(Floor(((endTime-endHour)*100)), 0, 59);
		
		bool triggered;
		if(DayNight_GetTimeDifference(h, m, s, startHour, startMinute, 0)>0&&DayNight_GetTimeDifference(h, m, s, endHour, endMinute, 0)<0){
			triggered = true;
		}
		else{
			triggered = false;
		}
		
		if(triggered){
			Screen->TriggerSecrets();
			if(perm)
				Screen->State[ST_SECRET] = true;
			Quit();
		}
		
		while(true){
			h = DayNight[_DN_HOUR];
			m = DayNight[_DN_MINUTE];
			s = DayNight[_DN_SECOND];
			
			if(DayNight_GetTimeDifference(h, m, s, startHour, startMinute, 0)>0&&DayNight_GetTimeDifference(h, m, s, endHour, endMinute, 0)<0){
				triggered = true;
			}
			else{
				triggered = false;
			}
			
			if(triggered){
			Screen->TriggerSecrets();
			if(perm)
				Screen->State[ST_SECRET] = true;
			if(sfx>0)
				Game->PlaySound(sfx);
			Quit();
		}
			
			Waitframe();
		}
	}
}

//This script sets the clock to a certain time when you enter the screen, for use in cutscenes
//D0: Hour
//D1: Minute
//D2: Second
ffc script DayNight_SetTime{
	void run(int hours, int minutes, int seconds){
		DayNight[_DN_HOUR] = Clamp(hours, 1, 24);
		DayNight[_DN_MINUTE] = Clamp(minutes, 0, 59);
		DayNight[_DN_SECOND] = Clamp(seconds, 0, 59);
	}
}