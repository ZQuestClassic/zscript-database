//Script originally by Elmensajero. 

import "include/std.zh"

//Change these values to match your item setup
const int GBS_SMALL=93;
const int GBS_MAGIC=8;
const int GBS_MIRROR=37;
const int GBS_FAKESMALL=123;
const int GBS_FAKEMAGIC=124;
const int GBS_FAKEMIRROR=125;
const int SFX_GBSHIELD=65;

int ButtonPressed;
bool shieldon;
int lastdir;
int gbsound;

global script Slot_2{
    void run(){
       while(true){
			GBShield();
            Waitdraw();
			GBShieldDraw();
            Waitframe();
        }
    }
}

void GBShield(){
	lastdir=Hero->Dir; //Direction to face when strafing
	if((ButtonPressed==1 && Hero->InputA && !shieldon)
	|| (ButtonPressed==2 && Hero->InputB && !shieldon)
	|| (ButtonPressed==3 && Hero->InputEx1 && !shieldon)
	|| (ButtonPressed==4 && Hero->InputEx2 && !shieldon)){ //Enable shield when button is pressed
		shieldon=true;
		gbsound=SFX_GBSHIELD;
		
		//If the Hero has the fake shield item, give him the real shield...
		if(Hero->Item[GBS_FAKEMIRROR]) Hero->Item[GBS_MIRROR]=true;
		else if(Hero->Item[GBS_FAKEMAGIC]) Hero->Item[GBS_MAGIC]=true;
		else if(Hero->Item[GBS_FAKESMALL]) Hero->Item[GBS_SMALL]=true;
		else{
			gbsound=0;
			shieldon=false;
		}
		if(gbsound>0) Game->PlaySound(SFX_GBSHIELD);
	}
	else if((ButtonPressed==1 && !Hero->InputA && shieldon)
	|| (ButtonPressed==2 && !Hero->InputB && shieldon)
	|| (ButtonPressed==3 && !Hero->InputEx1 && shieldon)
	|| (ButtonPressed==4 && !Hero->InputEx2 && shieldon)){ //Remove shield when button is released
		Hero->Item[GBS_MIRROR]=false;
		Hero->Item[GBS_MAGIC]=false;
		Hero->Item[GBS_SMALL]=false;
		shieldon=false;
		ButtonPressed = 0;
	}
}

void GBShieldDraw(){
     if(ButtonPressed>0 && shieldon 
	 && Hero->Action!=LA_SWIMMING 
	 && Hero->Action!=LA_DROWNING 
	 && Hero->Action!=LA_ATTACKING 
	 && Hero->Action!=LA_CHARGING 
	 && Hero->Action!=LA_SPINNING){ //Strafe while the button is held down              
          Hero->Dir=lastdir;
     }
}

item script GB_Shield{
	void run(){
		if(Hero->InputA) ButtonPressed = 1;
		else if(Hero->InputB) ButtonPressed = 2;
		else if (Hero->InputEx1) ButtonPressed = 3;
		else if (Hero->InputEx2) ButtonPressed = 4;
	}
}