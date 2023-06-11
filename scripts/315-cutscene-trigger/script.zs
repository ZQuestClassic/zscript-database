const int CUTSCENETRIGGER_SHOW_HITBOXES = 0; //For debugging problems with the script's hitboxes, set this to 1.
const int C_CUTSCENETRIGGER_HITBOX = 0x01; //Color for the debug hitboxes
const int C_CUTSCENETRIGGER_HITBOX_INACTIVE = 0x81; //Color for disabled debug hitboxes

const int D_CUTSCENETRIGGER = 0; //Screen->D used for cutscene triggers

//D0: The DMap to warp to for the cutscene
//D1: The screen to warp to IN DECIMAL. Screens in ZQuest are numbered in hex but FFCs only take arguments
//	  in decimal, so you'll have to convert.
//D2: Width of the trigger hitbox
//D3: Height of the trigger hitbox
//D4: Set this to a number 1-17 to make the cutscene only play once. By giving FFCs different D4 arguments, 
//	  you can have multiple triggers for different permanent cutscenes on a screen.
//D5: If you want the trigger to check for a flag under Link, set this to the number of the flag. 
//	  If you want it check for a flag just being on the screen, set to the flag + 1000
//    If you want it to check for an item, set this to a negative Item ID.
//    If you want it to check for not having an item, set to the negative Item ID - 1000
//D6: The X position to try to walk Link to. 0 for no target point.
//D7: The Y position to try to walk Link to. 0 for no target point.
//A. Delay: Set to >0 if you can activate this trigger immediately even when entering the screen on top of it
ffc script CutsceneTrigger{
	void run(int newDMap, int newScreen, int w, int h, int oneUse, int checkItemorFlag, int targetX, int targetY){
		int dbit;
		if(oneUse>0){
			dbit = 1<<(oneUse-1);
		}
		if(this->Delay==0){
			//If Link starts standing on the cutscene hitbox, wait for him to step off
			while(Link->X+8 >= this->X && Link->X+8 <= this->X+w-1 && Link->Y+12 >= this->Y && Link->Y+12 <= this->Y+h-1 && CanTriggerCutscene(checkItemorFlag)){
				if(CUTSCENETRIGGER_SHOW_HITBOXES){
					Screen->Rectangle(6, this->X-1, this->Y-1, this->X+w-1+1, this->Y+h-1+1, C_CUTSCENETRIGGER_HITBOX, 1, 0, 0, 0, false, 64);
					Screen->Rectangle(6, this->X, this->Y, this->X+w-1, this->Y+h-1, C_CUTSCENETRIGGER_HITBOX, 1, 0, 0, 0, false, 128);
					Screen->Rectangle(6, this->X+1, this->Y+1, this->X+w-1-1, this->Y+h-1-1, C_CUTSCENETRIGGER_HITBOX, 1, 0, 0, 0, true, 64);
				}
				Waitframe();
			}
		}
		//Check if the cutscene has already been triggered
		if(oneUse&&Screen->D[D_CUTSCENETRIGGER]&dbit){
			Quit();
		}
		while(true){
			int c = C_CUTSCENETRIGGER_HITBOX;
			if(!CanTriggerCutscene(checkItemorFlag))
				c = C_CUTSCENETRIGGER_HITBOX_INACTIVE;
			if(CUTSCENETRIGGER_SHOW_HITBOXES){
				Screen->Rectangle(6, this->X-1, this->Y-1, this->X+w-1+1, this->Y+h-1+1, c, 1, 0, 0, 0, false, 64);
				Screen->Rectangle(6, this->X, this->Y, this->X+w-1, this->Y+h-1, c, 1, 0, 0, 0, false, 128);
				Screen->Rectangle(6, this->X+1, this->Y+1, this->X+w-1-1, this->Y+h-1-1, c, 1, 0, 0, 0, false, 64);
			}
			//Find if Link has collided with the trigger hitbox
			if(Link->X+8 >= this->X && Link->X+8 <= this->X+w-1 && Link->Y+12 >= this->Y && Link->Y+12 <= this->Y+h-1 ){
				if(CUTSCENETRIGGER_SHOW_HITBOXES){
					Screen->Rectangle(6, this->X+2, this->Y+2, this->X+w-1-2, this->Y+h-1-2, c, 1, 0, 0, 0, true, 64);
				}
				//If Link meets one the requirements to trigger the cutscene, break out of the loop
				if(CanTriggerCutscene(checkItemorFlag))
					break;
			}
			Waitframe();
		}
		if(targetX>0||targetY>0){
			//Move Link either until he's in position or 4 seconds have passed
			for(int i=0; i<=240&&(Link->X!=targetX||Link->Y!=targetY); i++){
				//Prevent moving around while moving Link into position
				Link->InputStart = false; Link->PressStart = false;
				Link->InputMap = false; Link->PressMap = false;
				NoAction();
				
				//Apply inputs that should be active
				if(Abs(Link->X-targetX)<=2){
					Link->X = targetX;
				}
				else{
					if(Link->X<targetX)
						Link->InputRight = true;
					else if(Link->X>targetX)
						Link->InputLeft = true;
				}
				if(Abs(Link->Y-targetY)<=2){
					Link->Y = targetY;
				}
				else{
					if(Link->Y<targetY)
						Link->InputDown = true;
					else if(Link->Y>targetY)
						Link->InputUp = true;
				}
				Waitframe();
			}
		}
		if(oneUse){
			Screen->D[D_CUTSCENETRIGGER] |= dbit;
		}
		Link->PitWarp(newDMap, newScreen);
	}
	bool CanTriggerCutscene(int checkItemorFlag){
		//If Link meets one the requirements to trigger the cutscene, return true
		if(checkItemorFlag==0){
			return true;
		}
		//If the checkItemorFlag argument is negative, check for an item
		else if(checkItemorFlag<0){
			if(checkItemorFlag<-1000){
				checkItemorFlag += 1000;
				if(!Link->Item[Abs(checkItemorFlag)])
					return true;
			}
			else{
				if(Link->Item[Abs(checkItemorFlag)])
					return true;
			}
		}
		//Else check for a screen flag
		else{
			//If >1000, the trigger becomes active even if Link isn't standing on the flag
			if(checkItemorFlag>1000){
				checkItemorFlag -= 1000;
				for(int i=0; i<176; ++i){
					if(ComboFI(i, checkItemorFlag))
						return true;
				}
			}
			//Otherwise check if Link is standing on the flag
			else{
				if(ComboFI(Link->X+8, Link->Y+12, checkItemorFlag))
					return true;
			}
		}
		return false;
	}
}

//It's dangerous to make unscripted cutscenes that give Link control while they're playing, take this!
ffc script InputDisable{
	void run(){
		while(true){
			Link->InputStart = false; Link->PressStart = false;
			Link->InputMap = false; Link->PressMap = false;
			NoAction();
			Waitframe();
		}
	}
}

//For playing sounds in cutscenes
//D0: SFX to play
//D1: Delay in frames
ffc script PlaySoundWithDelay{
	void run(int sfx, int delay){
		Waitframes(delay);
		Game->PlaySound(sfx);
	}
}

//For playing messages in cutscenes
//D0: Message string to play
//D1: Delay in frames
ffc script PlayMessageWithDelay{
	void run(int msg, int delay){
		Waitframes(delay);
		Screen->Message(msg);
	}
}

//Okay I probably don't really need all these little scripts, but in making non-scripted cutscenes I got a little nitpicky :P
//D0: Direction to set Link to
ffc script SetLinkDirection{
	void run(int dir){
		Link->Dir = dir;
	}
}