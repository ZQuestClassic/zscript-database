const int ANTIPAUSEBUFFER_DELAY_ON_MASH = 0; //If 1, additional delay is added after mashing, else inputs are eaten instead

const int ANTIPAUSEBUFFER_DELAY = 4; //Frame delay before the subscreen/map opens

const int ANTIPAUSEBUFFER_COOLDOWN = 16; //Delay after closing the subscreen/map before it can be opened again

const int ANTIPAUSEBUFFER_MASHTIME = 48; //Frames where the script detects mashing if the subscreen is opened twice
const int ANTIPAUSEBUFFER_MASHTIMEPENALTY = 64; //Frames where the mashing penalty is applied

const int ANTIPAUSEBUFFER_MASHDELAY = 48; //Frame delay/cooldown added to the subscreen/map after mashing

int PauseBufferGlobal[16];

const int _PB_STARTDELAY = 0;
const int _PB_MAPDELAY = 1;
const int _PB_STARTCOOLDOWN = 2;
const int _PB_MAPCOOLDOWN = 3;
const int _PB_MASHCOUNTER = 4;
const int _PB_MASHPENALTYCOUNTER = 5;

void AntiPauseBuffer_Init(){
	PauseBufferGlobal[_PB_STARTDELAY] = 0;
	PauseBufferGlobal[_PB_MAPDELAY] = 0;
	PauseBufferGlobal[_PB_STARTCOOLDOWN] = 0;
	PauseBufferGlobal[_PB_MAPCOOLDOWN] = 0;
	PauseBufferGlobal[_PB_MASHCOUNTER] = 0;
	PauseBufferGlobal[_PB_MASHPENALTYCOUNTER] = 0;
}

void AntiPauseBuffer_Update(){
	//Set timers for delaying button presses
	int startDelay = ANTIPAUSEBUFFER_DELAY;
	int mapDelay = ANTIPAUSEBUFFER_DELAY;
	if(PauseBufferGlobal[_PB_MASHPENALTYCOUNTER]&&ANTIPAUSEBUFFER_DELAY_ON_MASH){
		startDelay += ANTIPAUSEBUFFER_MASHDELAY;
		mapDelay += ANTIPAUSEBUFFER_MASHDELAY;
	}
	
	//Prevent button presses while on cooldown
	if(PauseBufferGlobal[_PB_STARTCOOLDOWN]){
		--PauseBufferGlobal[_PB_STARTCOOLDOWN];
		Link->PressStart = false; Link->InputStart = false;
	}
	if(PauseBufferGlobal[_PB_MAPCOOLDOWN]){
		--PauseBufferGlobal[_PB_MAPCOOLDOWN];
		Link->PressMap = false; Link->InputMap = false;
	}
	
	//When Link presses Start, delay the press or apply cooldown
	if(Link->PressStart||Link->InputStart){
		if(startDelay){
			if(Link->PressStart){
				if(PauseBufferGlobal[_PB_STARTDELAY]==0){
					PauseBufferGlobal[_PB_STARTDELAY] = startDelay;
				}
			}
			Link->PressStart = false; Link->InputStart = false;
		}
		else{
			if(Link->PressStart)
				AntiPauseBuffer_OnMenuOpen();
		}
	}
	//When Link presses Map, delay the press or apply cooldown
	if(Link->PressMap||Link->InputMap){
		if(mapDelay){
			if(Link->PressMap){
				if(PauseBufferGlobal[_PB_MAPDELAY]==0){
					PauseBufferGlobal[_PB_MAPDELAY] = mapDelay;
				}
			}
			Link->PressMap = false; Link->InputMap = false;
		}
		else{
			if(Link->PressMap)
				AntiPauseBuffer_OnMapOpen();
		}
	}
	
	//Delay start presses based on the timer
	if(PauseBufferGlobal[_PB_STARTDELAY]){
		--PauseBufferGlobal[_PB_STARTDELAY];
		if(!PauseBufferGlobal[_PB_STARTDELAY]){
			AntiPauseBuffer_OnMenuOpen();
		}
	}
	//Delay map presses based on the timer
	if(PauseBufferGlobal[_PB_MAPDELAY]){
		--PauseBufferGlobal[_PB_MAPDELAY];
		if(!PauseBufferGlobal[_PB_MAPDELAY]){
			AntiPauseBuffer_OnMapOpen();
		}
	}
	
	if(PauseBufferGlobal[_PB_MASHCOUNTER])
		--PauseBufferGlobal[_PB_MASHCOUNTER];
	if(PauseBufferGlobal[_PB_MASHPENALTYCOUNTER])
		--PauseBufferGlobal[_PB_MASHPENALTYCOUNTER];
}

void AntiPauseBuffer_OnMenuOpen(){
	if(PauseBufferGlobal[_PB_MASHCOUNTER])
		PauseBufferGlobal[_PB_MASHPENALTYCOUNTER] = ANTIPAUSEBUFFER_MASHTIMEPENALTY;
		
	int startCooldown = ANTIPAUSEBUFFER_COOLDOWN;
	if(PauseBufferGlobal[_PB_MASHPENALTYCOUNTER]&&!ANTIPAUSEBUFFER_DELAY_ON_MASH){
		startCooldown += ANTIPAUSEBUFFER_MASHDELAY;
	}
	
	PauseBufferGlobal[_PB_STARTCOOLDOWN] = startCooldown;
	PauseBufferGlobal[_PB_MASHCOUNTER] = ANTIPAUSEBUFFER_MASHTIME;
	Link->PressStart = true; Link->InputStart = true;
}

void AntiPauseBuffer_OnMapOpen(){
	if(PauseBufferGlobal[_PB_MASHCOUNTER])
		PauseBufferGlobal[_PB_MASHPENALTYCOUNTER] = ANTIPAUSEBUFFER_MASHTIMEPENALTY;
		
	int mapCooldown = ANTIPAUSEBUFFER_COOLDOWN;
	if(PauseBufferGlobal[_PB_MASHPENALTYCOUNTER]&&!ANTIPAUSEBUFFER_DELAY_ON_MASH){
		mapCooldown += ANTIPAUSEBUFFER_MASHDELAY;
	}
	
	PauseBufferGlobal[_PB_MAPCOOLDOWN] = mapCooldown;
	PauseBufferGlobal[_PB_MASHCOUNTER] = ANTIPAUSEBUFFER_MASHTIME;
	Link->PressMap = true; Link->InputMap = true;
}

global script NoMashies{
	void run(){
		AntiPauseBuffer_Init();
		while(true){
			AntiPauseBuffer_Update();
			
			Waitdraw();
			Waitframe();
		}
	}
}