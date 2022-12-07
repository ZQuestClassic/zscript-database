const int JUMPBUTTON_BUTTON = 0; //Which button makes Link jump
									//	0 - L
									//	1 - R
									//	2 - Ex1
									//	3 - Ex2
									//	4 - Ex3
									//	5 - Ex4


const int I_HIGHJUMP = 143; //Item ID for High Jump
const int I_DOUBLEJUMP = 144; //Item ID for Double Jump
const int I_SPACEJUMP = 145; //Item ID for Space Jump
								
const int JUMPBUTTON_ONLY_SIDEVIEW = 0; //If 1, the jump button only works in sideview
const int JUMPBUTTON_DECAY_IS_PERCENTAGE = 0; //If 1, jump decay is a percentage instead of a fixed value
const int JUMPBUTTON_IGNORE_SWEETSPOTS = 0; //If 1, double jump/space jump have no sweetspots and you can always do the jump
					
//SFX for the three jump types					
const int SFX_JUMPBUTTON_JUMP = 45;
const int SFX_JUMPBUTTON_DOUBLEJUMP = 51;
const int SFX_JUMPBUTTON_SPACEJUMP = 45;
						
const int JUMPBUTTON_JUMP_HEIGHT = 3.0; //Jump height of regular jump
const int JUMPBUTTON_HIGH_JUMP_HEIGHT = 4.0; //Jump height of high jump
const int JUMPBUTTON_DOUBLE_JUMP_HEIGHT = 2.6; //Jump height of second jump
const int JUMPBUTTON_SPACE_JUMP_HEIGHT = 0; //Jump height of space jump

const int JUMPBUTTON_JUMP_DECAY = 0.4; //Jump lost when not holding the button
const int JUMPBUTTON_PRESSDOWN_DECAY = 0.4; //Jump lost when holding down
const int JUMPBUTTON_TERMINAL_VELOCITY = 3.2; //Terminal velocity as set in ZQuest
const int JUMPBUTTON_TERMINAL_VELOCITY_DOWNINPUT = 4.0; //Terminal velocity when holding down in sideview (if you want it to exceed the normal one)

//Min and max jump values where Link can double jump
const int JUMPBUTTON_DOUBLE_JUMP_RANGE_MIN = -4;
const int JUMPBUTTON_DOUBLE_JUMP_RANGE_MAX = 1;

//Min and max jump values where Link can space jump
const int JUMPBUTTON_SPACE_JUMP_RANGE_MIN = -4;
const int JUMPBUTTON_SPACE_JUMP_RANGE_MAX = -1;

//Frames before space jump works when missing the window
const int JUMPBUTTON_SPACE_JUMP_COOLDOWN = 120; 

//Frames after walking off a ledge where Link can still jump 
const int JUMPBUTTON_JUMP_FORGIVENESS_FRAMES = 12;

int JumpButton[16];
const int _JB_WASJUMPING = 0;
const int _JB_ONSIDEPLATFORM = 1;
const int _JB_DOUBLEJUMPUSED = 2; 
const int _JB_COOLDOWN = 3;
const int _JB_COYOTEJUMP = 4;
const int _JB_JUMPTYPE = 5;

void JumpButton_Update(){
	if(Link->Action==LA_SCROLLING)
		return;
	if(!IsSideview()&&JUMPBUTTON_ONLY_SIDEVIEW)
		return;
	
	if(JumpButton[_JB_COYOTEJUMP]>0)
			--JumpButton[_JB_COYOTEJUMP];
		
	//Check if on the platform
	if(JumpButton_OnPlatform()||JumpButton[_JB_COYOTEJUMP]){
		//Don't reset timers if we entered this statement through the "Coyote Jump" timer
		if(JumpButton_OnPlatform()){
			JumpButton[_JB_JUMPTYPE] = 0;
			JumpButton[_JB_DOUBLEJUMPUSED] = 0;
			JumpButton[_JB_COOLDOWN] = JUMPBUTTON_SPACE_JUMP_COOLDOWN;
			JumpButton[_JB_COYOTEJUMP] = JUMPBUTTON_JUMP_FORGIVENESS_FRAMES;
		}
		if(JumpButton_PressJumpButton()&&JumpButton_CanJump()){
			Game->PlaySound(SFX_JUMPBUTTON_JUMP);
			//Jumping doesn't give the safety frames walking off a ledge does
			JumpButton[_JB_COYOTEJUMP] = 0;
			JumpButton[_JB_WASJUMPING] = 1;
			JumpButton[_JB_JUMPTYPE] = 1;
			if(Link->Item[I_HIGHJUMP])
				Link->Jump = JUMPBUTTON_HIGH_JUMP_HEIGHT;
			else
				Link->Jump = JUMPBUTTON_JUMP_HEIGHT;
		}
	}
	else{
		//Count down the cooldown for a missed sweet spot
		if(JumpButton[_JB_COOLDOWN]>0)
			--JumpButton[_JB_COOLDOWN];
		
		//Space jump item lets Link jump infinitely
		if(Link->Item[I_SPACEJUMP]){
			if(JumpButton_PressJumpButton()){
				if(JUMPBUTTON_IGNORE_SWEETSPOTS||(Link->Jump>=JUMPBUTTON_SPACE_JUMP_RANGE_MIN&&Link->Jump<=JUMPBUTTON_SPACE_JUMP_RANGE_MAX)||JumpButton[_JB_COOLDOWN]==0){
					Game->PlaySound(SFX_JUMPBUTTON_SPACEJUMP);
					//If space jump height is 0, use jump height and make it affected by high jump
					if(JUMPBUTTON_SPACE_JUMP_HEIGHT==0){
						if(Link->Item[I_HIGHJUMP])
							Link->Jump = JUMPBUTTON_HIGH_JUMP_HEIGHT;
						else
							Link->Jump = JUMPBUTTON_JUMP_HEIGHT;
					}
					else
						Link->Jump = JUMPBUTTON_SPACE_JUMP_HEIGHT;
					JumpButton[_JB_JUMPTYPE] = 3;
					JumpButton[_JB_COOLDOWN] = JUMPBUTTON_SPACE_JUMP_COOLDOWN;
					JumpButton[_JB_WASJUMPING] = 1;
				}
			}
		}
		//Otherwise double jump lets him jump a second time
		else if(Link->Item[I_DOUBLEJUMP]){
			if(JumpButton_PressJumpButton()){
				if(!JumpButton[_JB_DOUBLEJUMPUSED]&&(JUMPBUTTON_IGNORE_SWEETSPOTS||(Link->Jump>=JUMPBUTTON_DOUBLE_JUMP_RANGE_MIN&&Link->Jump<=JUMPBUTTON_DOUBLE_JUMP_RANGE_MAX))){
					Game->PlaySound(SFX_JUMPBUTTON_DOUBLEJUMP);
					Link->Jump = JUMPBUTTON_DOUBLE_JUMP_HEIGHT;
					JumpButton[_JB_JUMPTYPE] = 2;
					JumpButton[_JB_WASJUMPING] = 1;
					JumpButton[_JB_DOUBLEJUMPUSED] = 1;
				}
			}
		}
	}

	//Make jumps decay when the button is released early
	if(Link->Jump>0){
		if(JUMPBUTTON_JUMP_DECAY!=0){
			if(!JumpButton_InputJumpButton()||!JumpButton[_JB_WASJUMPING]&&JumpButton[_JB_JUMPTYPE]){
				JumpButton[_JB_WASJUMPING] = 0;
				if(JUMPBUTTON_DECAY_IS_PERCENTAGE){
					Link->Jump -= Max(Link->Jump - Abs(Link->Jump) * JUMPBUTTON_JUMP_DECAY, -JUMPBUTTON_TERMINAL_VELOCITY);
				}
				else{
					Link->Jump = Max(Link->Jump-JUMPBUTTON_JUMP_DECAY, -JUMPBUTTON_TERMINAL_VELOCITY);
				}
			}
		}
	}
	//Make falling speed up when holding down
	else{
		if(JUMPBUTTON_PRESSDOWN_DECAY!=0){
			if(Link->InputDown&&IsSideview()){
				if(JUMPBUTTON_DECAY_IS_PERCENTAGE){
					Link->Jump = Max(Link->Jump - Abs(Link->Jump) * JUMPBUTTON_PRESSDOWN_DECAY, -JUMPBUTTON_TERMINAL_VELOCITY_DOWNINPUT);
				}
				else{
					Link->Jump = Max(Link->Jump-JUMPBUTTON_PRESSDOWN_DECAY, -JUMPBUTTON_TERMINAL_VELOCITY_DOWNINPUT);
				}
			}
		}
	}
	JumpButton[_JB_ONSIDEPLATFORM] = 0;
}

bool JumpButton_PressJumpButton(){
	if(JUMPBUTTON_BUTTON==0){
		return Link->PressL;
	}
	else if(JUMPBUTTON_BUTTON==1){
		return Link->PressR;
	}
	else if(JUMPBUTTON_BUTTON==2){
		return Link->PressEx1;
	}
	else if(JUMPBUTTON_BUTTON==3){
		return Link->PressEx2;
	}
	else if(JUMPBUTTON_BUTTON==4){
		return Link->PressEx3;
	}
	else if(JUMPBUTTON_BUTTON==5){
		return Link->PressEx4;
	}
}
bool JumpButton_InputJumpButton(){
	if(JUMPBUTTON_BUTTON==0){
		return Link->InputL;
	}
	else if(JUMPBUTTON_BUTTON==1){
		return Link->InputR;
	}
	else if(JUMPBUTTON_BUTTON==2){
		return Link->InputEx1;
	}
	else if(JUMPBUTTON_BUTTON==3){
		return Link->InputEx2;
	}
	else if(JUMPBUTTON_BUTTON==4){
		return Link->InputEx3;
	}
	else if(JUMPBUTTON_BUTTON==5){
		return Link->InputEx4;
	}
}

//Returns whether Link is on a platform as far as the script is concerned
bool JumpButton_OnPlatform(){
	if(IsSideview()){
		return Link->Jump==0&&(JumpButton_OnSidePlatform(Link->X, Link->Y)||JumpButton[_JB_ONSIDEPLATFORM]);
	}
	return Link->Jump==0&&(Link->Z==0||JumpButton[_JB_ONSIDEPLATFORM]);
}

//Returns whether Link is unable to jump due to other causes
bool JumpButton_CanJump(){
	if(Link->Action!=LA_NONE&&Link->Action!=LA_WALKING&&Link->Action!=LA_GOTHURTLAND)
		return false;
	return true;
}

//Copy of the std function to be sure we're using the right version
bool JumpButton_OnSidePlatform(int x, int y) {
    return ((Screen->isSolid(x+4,y+16) || Screen->isSolid(x+12,y+16)) && Screen->Flags[SF_ROOMTYPE]&4);
}

//Used for communication between scripts to tell this one if Link is on a scripted platform
void JumpButton_OnSidePlatformOverride(){
	JumpButton[_JB_ONSIDEPLATFORM] = 1;
}

global script JumpButtonExample{
	void run(){
		while(true){
			JumpButton_Update();
			Waitdraw();
			Waitframe();
		}
	}
}